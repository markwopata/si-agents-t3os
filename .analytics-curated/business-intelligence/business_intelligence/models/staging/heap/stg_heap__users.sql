  -- depends_on: {{ ref('stg_heap___sync_info_distinct') }}
  -- depends_on: {{ ref('stg_heap__user_migrations') }}

{{ config(
    materialized='incremental'
    , incremental_strategy = 'merge'
    , unique_key=['heap_user_id']
    , cluster_by=['heap_user_id']
    , pre_hook=[
        "{{ sync_migrated_heap_users() }}",
        "{{ deduplicate(primary_key='heap_user_id', sort_timestamp='last_modified') }}"
        ]

) }}


with 

source as (

    select * from {{ source('heap', 'users') }}

),

renamed as (

    select
        user_id as heap_user_id,
        joindate as heap_join_date,
        last_modified,
        identity,
        handle,
        email as heap_email,
        company_name,
        user_name,
        company_timezone,
        user_timezone,
        company_id,
        _user_id as es_user_id,
        _email as es_email, 
        TO_DATE(user_created_at, 'MON DD, YYYY') as user_created_at,
        mimic_user,
        user_cohort,
        {{ dbt_run_started_at_formatted() }}

    from source

)

select * from renamed as r

{% if is_incremental() %}

where last_modified > ( {{ get_incremental_helper_heap_data_from_sync_info(table_name='users') }} )

{% endif %}