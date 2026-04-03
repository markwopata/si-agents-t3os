{{ config(
    materialized='incremental'
    , incremental_strategy = 'append'
    , cluster_by=['status', 'start_time', 'finish_time']
    , unique_key=['status', 'start_time', 'finish_time']
) }}

with 

source as (

    select * from {{ source('heap', '_sync_history') }}

),

renamed as (

    select
        status,
        start_time,
        finish_time,
        error, 
        next_scheduled_sync_at,
        {{ dbt_run_started_at_formatted() }}

    from source

)

select * from renamed as r

{% if is_incremental() %}

where start_time > ( select max(start_time) from {{ this }} )

and not exists ( 
    {{ get_incremental_helper_where_not_exists('r') }}
)


{% endif %}