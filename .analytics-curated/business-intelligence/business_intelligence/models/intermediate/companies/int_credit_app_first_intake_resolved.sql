-- Combines standard and automated intake application resolution paths
-- Standard apps: uses grace period window logic (from int_credit_app_lookup_grace_period), no order comparison
-- Automated intake apps: uses order vs second app comparison (from int_credit_app_automated_intake_activity)

{{ config(
    materialized='incremental',
    unique_key=['company_id'],
    incremental_strategy='merge',
    merge_exclude_columns = ['_created_recordtimestamp']
) }}

with
    -- Resolve automated intake applications (self-signup or auto-processed)
    -- Prioritize order if exists, otherwise take latest credit app
    -- First qualify to get the best record per company, then filter for salesperson
    automated_intake_with_salesperson as (
        select * from (
            select
                company_id,
                camr_id,
                date_created_ct,
                date_received_ct,
                date_completed_ct,
                salesperson_user_id,
                source,
                app_status,
                app_type,
                notes,
                is_locked

            from {{ ref('int_credit_app_automated_intake_activity') }}
            where ({{ filter_transformation_updates(column_name='_updated_recordtimestamp') }})
            qualify row_number() over (
                partition by company_id
                order by (source = 'Order') DESC, date_created_ct desc
            ) = 1
        )
        where salesperson_user_id IS NOT NULL
    ),

    -- Standard intake apps: just need to pull fields from the camr_id
    standard_intake_with_salesperson as (
        select * from (
            select
                c.company_id,
                c.camr_id,
                details.date_created_ct,
                details.date_received_ct,
                details.date_completed_ct,
                details.salesperson_user_id,
                details.source,
                details.app_status,
                details.app_type,
                details.notes,
                c.is_locked

            from {{ ref('int_credit_app_lookup_grace_period') }} c
            join {{ ref('int_credit_app_base') }} details
                on c.camr_id = details.camr_id
            where {{ filter_transformation_updates(column_name='c._updated_recordtimestamp') }}
        )
        where salesperson_user_id IS NOT NULL
    ),

    -- Union both paths
    combined as (
        select * from automated_intake_with_salesperson
        union all
        select * from standard_intake_with_salesperson
    )

select
    company_id,
    camr_id,
    source,
    app_status,
    app_type,
    CAST(COALESCE(date_received_ct, date_created_ct) AS DATE) as first_account_date_ct,
    date_created_ct,
    date_received_ct,
    date_completed_ct,
    salesperson_user_id,
    notes,
    is_locked,

    {{ get_current_timestamp() }} as _created_recordtimestamp,
    {{ get_current_timestamp() }} as _updated_recordtimestamp

from combined
