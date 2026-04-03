  -- depends_on: {{ ref('stg_heap___sync_info_distinct') }}
  -- depends_on: {{ ref('stg_heap__user_migrations') }}

{{ config(
    materialized='incremental'
    , incremental_strategy = 'append'
    , cluster_by=['event_id', 'heap_user_id', 'session_id', 'pageview_time']
    , unique_key=['event_id', 'heap_user_id', 'session_id', 'pageview_time']
    , pre_hook=[ "{{ sync_migrated_heap_users() }}"]
    , post_hook=["{{ sync_heap_late_arriving_data() }}"]
) }}

with 

source as (

    select * from {{ source('heap', 'pageviews') }}

),

renamed as (

    select
        user_id as heap_user_id,
        event_id,
        session_id,
        time as pageview_time,
        library,
        platform,
        device_type,
        country,
        region,
        city,
        ip,
        referrer,
        landing_page,
        landing_page_query,
        landing_page_hash,
        browser,
        search_keyword,
        utm_source,
        utm_campaign,
        utm_medium,
        utm_term,
        utm_content,
        device,
        carrier,
        app_name,
        app_version,
        domain,
        query,
        path,
        hash,
        title,
        view_controller,
        screen_a11y_id,
        screen_a11y_label,
        target_a11y_label,
        heap_device_id,
        heap_previous_page,
        heap_app_name,
        heap_app_version,
        heap_device,
        app_type_,
        browser_type,
        platform_type_os_,
        {{ dbt_run_started_at_formatted() }}

    from source

)

select * from renamed as r

{% if is_incremental() -%}

where pageview_time > (
     {{ get_incremental_helper_heap_data_from_sync_info(table_name='pageviews') }}
)
and not exists ( 
    {{ get_incremental_helper_where_not_exists('r') }}
)

{%- endif -%}