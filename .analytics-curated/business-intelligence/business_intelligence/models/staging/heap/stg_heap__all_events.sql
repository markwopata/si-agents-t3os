{{ config(
    materialized='table'
    , cluster_by=['event_id', 'heap_user_id', 'session_id', 'event_time', 'event_table_name']
    , unique_key=['event_id', 'heap_user_id', 'session_id', 'event_time']
) }}

with 

source as (

    select * from {{ source('heap', 'all_events') }}

),

renamed as (

    select
        event_id,
        time as event_time,
        user_id as heap_user_id,
        session_id,
        event_table_name,
        {{ dbt_run_started_at_formatted() }}
        
    from source

)

select * from renamed as r