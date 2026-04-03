  -- depends_on: {{ ref('stg_heap___sync_info_distinct') }}
  -- depends_on: {{ ref('stg_heap__user_migrations') }}

{{ config(
    materialized='incremental'
    , incremental_strategy = 'append'
    , cluster_by=['event_id', 'heap_user_id', 'session_id', 'intercom_rate_conversation_time', 'conversation_id']
    , unique_key=['event_id', 'heap_user_id', 'session_id', 'intercom_rate_conversation_time', 'conversation_id']
    , pre_hook=[ "{{ sync_migrated_heap_users() }}"]
    , post_hook=["{{ sync_heap_late_arriving_data() }}"]
) }}

with

source as (

    select * from {{ source('heap', 'intercom_events_rate_conversation') }}

),

renamed as (

    select
        user_id as heap_user_id,
        event_id,
        session_id,
        time as intercom_rate_conversation_time,
        type,
        library,
        platform,
        device_type,
        country,
        region,
        city,
        ip,
        referrer,
        landing_page_query,
        landing_page_hash,
        target_text,
        heap_device_id,
        heap_previous_page,
        app_id,
        conversation_id,
        conversation_rating,
        platform_type_os_,
        {{ dbt_run_started_at_formatted() }}

    from source

)

select * from renamed as r

{% if is_incremental() -%}

where intercom_rate_conversation_time > (
     {{ get_incremental_helper_heap_data_from_sync_info(table_name='intercom_events_rate_conversation') }}
)
and not exists (
    {{ get_incremental_helper_where_not_exists('r') }}
)

{%- endif -%}