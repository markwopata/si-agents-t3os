{{ config(
    materialized='incremental',
    unique_key=['camr_id'],
    incremental_strategy='merge',
    merge_exclude_columns = ['_created_recordtimestamp']
) }}

with remove_duplicate_status as (

    select *
    from {{ ref('int_credit_app_base') }}
    where (app_status <> 'Duplicate' or app_status IS NULL)
    and {{ filter_transformation_updates('_updated_recordtimestamp') }}
    {% if is_incremental() -%}
    and camr_id not in (select camr_id from {{ this }})
    {% endif -%}
)

select
    camr_id
    , company_id

    , {{ get_current_timestamp() }} as _created_recordtimestamp
    , {{ get_current_timestamp() }} as _updated_recordtimestamp

from remove_duplicate_status