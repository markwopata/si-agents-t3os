{%- macro filter_incremental_with_buffer_minute(column_name, buffer_minutes=10) -%}

    {%- if is_incremental() -%}
        {{ column_name }} > (
            SELECT DATEADD(MINUTE, -{{ buffer_minutes }}, MAX(_updated_recordtimestamp))
            FROM {{ this }}
        )
    {%- else -%}
        1 = 1
    {%- endif -%}
{%- endmacro -%}