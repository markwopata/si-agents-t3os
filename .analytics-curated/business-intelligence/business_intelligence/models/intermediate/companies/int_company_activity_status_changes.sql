{{ config(
    materialized='incremental',
    unique_key=['company_id', 'dbt_valid_from'],
    incremental_strategy='delete+insert'
) }}

-- get all activity status changes for updated companies
with activity_status_changes as (
    select
        company_id,
        lag(company_activity_status) over (
            partition by company_id order by dbt_valid_from
        ) as previous_status,
        company_activity_status as new_status,
        lag(dbt_valid_from) over (
            partition by company_id order by dbt_valid_from
        ) as previous_dbt_valid_from,
        dbt_valid_from
    from {{ ref('snapshot_company_activity_status') }}
    where company_id in (
        select distinct company_id
        from {{ ref('snapshot_company_activity_status') }}
        where ({{ filter_source_updates(column_name='dbt_valid_from', buffer_amount=1, time_unit='day', append_only=true) }})
    )
)

select
    company_id,
    previous_status,
    new_status,
    previous_dbt_valid_from,
    dbt_valid_from,
    datediff(day, previous_dbt_valid_from::date, dbt_valid_from::date) as days_in_previous_status,
    case
        when previous_status in ('Dormant', 'Inactive') and new_status = 'Active'
        then true
        else false
    end as is_reactivated,
    
    {{ get_current_timestamp() }} AS _updated_recordtimestamp
    
from activity_status_changes
where previous_status is not null -- exclude the first record per company (no previous status yet)
-- only include latest status changes
and ({{ filter_source_updates(column_name='dbt_valid_from', buffer_amount=1, time_unit='day', append_only=true) }})