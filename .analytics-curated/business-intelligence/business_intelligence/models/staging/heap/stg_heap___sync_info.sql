  -- depends_on: {{ ref('stg_heap___sync_history') }}

{{ config(
    materialized='incremental'
    , incremental_strategy = 'append'
    , cluster_by=['event_table_name', 'sync_started', 'synced_to_time']
    , unique_key=['event_table_name', 'sync_started', 'synced_to_time']
) }}

with 

source as (

    select * from {{ source('heap', '_sync_info') }}

),

renamed as (

    select
        event_table_name,
        sync_started,
        sync_ended,
        synced_to_time,
        inserted_row_count,
        {{ dbt_run_started_at_formatted() }}

    from source

)

select * from renamed as r

{% if is_incremental() %}

where sync_started > ( 
    select min(start_time) 
    from {{ ref('stg_heap___sync_history') }} 
    where _dbt_updated_timestamp::date = current_date
)

and not exists ( 
    {{ get_incremental_helper_where_not_exists('r') }}
)

{% endif %}