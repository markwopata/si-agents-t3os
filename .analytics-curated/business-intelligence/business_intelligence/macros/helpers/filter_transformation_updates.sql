{%- macro filter_transformation_updates(column_name) -%}
    {%- if is_incremental() -%}
        {{ column_name }} > (
            SELECT MAX(_updated_recordtimestamp)
            FROM {{ this }}
        )
    {%- else -%}
        1=1
    {%- endif -%}
{%- endmacro -%}