-- * captures the first credit application per company that has a salesperson assigned

{{ config(
    materialized='incremental',
    unique_key=['company_id'],
    incremental_strategy='append'
) }}

with
    all_apps as (
        select
            valid.company_id,
            valid.camr_id,
            details.date_created_ct
        from {{ ref('int_credit_app_lookup_valid_applications') }} valid
        join {{ ref('int_credit_app_base') }} details
            on valid.camr_id = details.camr_id
        where valid.company_id IS NOT NULL
            and details.salesperson_user_id IS NOT NULL
        {% if is_incremental() -%}
        and valid.company_id not in (select company_id from {{ this }})
        {% endif -%}
    )

select
    company_id,
    camr_id,

    {{ get_current_timestamp() }} as _created_recordtimestamp,
    {{ get_current_timestamp() }} as _updated_recordtimestamp
from all_apps
qualify row_number() over (partition by company_id order by date_created_ct asc) = 1
