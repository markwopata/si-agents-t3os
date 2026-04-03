{%- macro deduplicate(primary_key, sort_timestamp) -%}

{%- if model_exists() is not none -%}

    {{ log("Running macro deduplicate on " ~ this) }}

    {# Set query to identify dupes #}
    {%- set find_dupes_query -%}
        SELECT {{ primary_key }}, COUNT(*)
        FROM {{ this }}
        GROUP BY {{ primary_key }} 
        HAVING count(*) > 1
    {%- endset -%}

    {%- set delete_dupes_query -%}
        DELETE FROM {{ this }}
            WHERE  {{ primary_key }} || '|' ||  {{ sort_timestamp }} IN (
            SELECT {{ primary_key }} || '|' ||  {{ sort_timestamp }}
            FROM (
                SELECT *, 
                    ROW_NUMBER() OVER (PARTITION BY {{ primary_key }} order by {{ sort_timestamp }}) as row_num
                FROM {{ this }}
            )
            WHERE row_num > 1
        );
    {%- endset -%}


    {# Run the query #}
    {%- set results = run_query(find_dupes_query) -%}

    {# Check if there are results #}
    {%- if results and results|length > 0 -%}
        {%- do log("Dupes found:", info=True) -%}
        {%- for row in results -%}
            {# Log each row of the results #}
            {% do log("Primary Key: " ~ row[0] ~ ", Count: " ~ row[1], info=True) %}
        {% endfor -%}

        {%- do log("Running dupe deletion query...", info=True) -%}
            {%- do run_query(delete_dupes_query) -%}
    {%- else -%}
        {% do log("No duplicates found", info=True) %}
    {%- endif -%}

{%- else -%}
    {%- do log("Table: " ~ this ~ " does not exist. Skipping deduplicate pre-hook", info=True) -%}
{%- endif -%}

{%- endmacro -%}