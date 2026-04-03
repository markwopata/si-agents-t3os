  -- depends_on: {{ ref('stg_heap___sync_info') }}

{{ config(
    materialized='ephemeral'
    , incremental_strategy = 'append'
    , cluster_by=['event_table_name', 'sync_started', 'synced_to_time']
    , unique_key=['event_table_name', 'sync_started', 'synced_to_time']
) }}

with 

source as (

    select distinct 
        event_table_name,
        sync_started,
        sync_ended,
        synced_to_time,
        inserted_row_count
     from {{ ref('stg_heap___sync_info') }}

     {%- if is_incremental() %}
        where _dbt_updated_timestamp::date = current_date
     {%- endif %}

),

renamed as (

    select
        event_table_name,
        sync_started,
        sync_ended,
        lead(synced_to_time) over (partition by event_table_name order by synced_to_time desc) as prev_synced_to_time,
        synced_to_time,
        inserted_row_count,
        {{ dbt_run_started_at_formatted() }}

    from source
)

select * from renamed