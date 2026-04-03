{#- lookback a year's worth of data -#}

{%- macro sync_heap_late_arriving_data() -%}

    {{ log("Running macro sync_heap_late_arriving_data on " ~ this) }}

    {#- get source -#}
    {%- set source_name = get_source_model( this.name ) -%}
    {%- if source_name | length > 0 -%}

        {# get the list of unique keys from the target model to isolate join parameters #}                 
        {%- set target_key_list = get_unique_keys_for_model(this.name) %}

        {# get the variable with the word 'time' in the field name in the target table #}
        {% set time_fields = [] %} 
        {% for item in target_key_list %}
            {% if 'time' in item %}
                {% do time_fields.append(item) %}
            {% endif %}
        {% endfor %}

        {% if time_fields | length > 0 %}
            {% set time_field = time_fields[0] %}
        {% else %}
            {% set time_field = none %}
        {% endif %}

        {# get dictionary of column mapping and join key mapping #}
        {%- set column_mapping_dict = get_source_to_target_mapping_dict() -%}
        {%- set join_key_dict = get_source_to_target_key_dict() %}

        {# unable to pass CTE to macro --> workaround #}
        {%- set first_cte -%}
            select * from {{ source('heap', source_name[0][1] ) }}
            where time::date >= DATEADD(year, -1, GETDATE())::date
        {%- endset -%}

        {%- set second_cte -%}
            select *
            from {{ this }}
            where {{ time_field }}::date >=  DATEADD(year, -1, GETDATE())::date
        {%- endset -%}

        INSERT INTO {{ this }}
        with records_to_be_inserted as (
            {{ get_records_in_table_a_not_in_table_b(table_a_ref=first_cte, table_b_ref=second_cte, join_keys=join_key_dict, null_identifier='heap_user_id') }}
        )
        select
            {% for col, alias in column_mapping_dict.items() %}
                {{ col }} AS {{ alias }},
            {% endfor %}
            {{ dbt_run_started_at_formatted() }}
        from records_to_be_inserted as r

    {%- endif -%}

{%- endmacro -%}