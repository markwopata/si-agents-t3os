{%- macro filter_incremental_with_buffer_day(column_name, buffer_days=1) -%}

    {%- if is_incremental() -%}
        {{ column_name }} > (
            SELECT DATE_TRUNC('day', DATEADD(DAY, -{{ buffer_days }}, MAX(_updated_recordtimestamp)))
            FROM {{ this }}
        )
    {%- else -%}
        {# On initial load, Load all history on initial (except today) #}
        {{ column_name }} < DATE_TRUNC('day', CURRENT_TIMESTAMP())
    {%- endif -%}
{%- endmacro -%}