{%- macro get_incremental_helper_heap_data_from_sync_info(table_name) -%}

    select min(prev_synced_to_time) 
    from {{ ref('stg_heap___sync_info_distinct') }} 
    where EVENT_TABLE_NAME = '{{ table_name }}'
    and _dbt_updated_timestamp::date = current_date

{%- endmacro -%}