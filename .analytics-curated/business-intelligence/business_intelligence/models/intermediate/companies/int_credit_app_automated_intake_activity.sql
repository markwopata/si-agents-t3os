{%- set grace_period_days = 5 -%}

{{ config(
    materialized='incremental',
    unique_key=['company_id'],
    incremental_strategy='delete+insert'
) }}

with
    -- Identify automated intake companies (self-signup or auto-processed)
    automated_intake_companies as (
        select
            fa.company_id,
            fa.camr_id
        from {{ ref('int_credit_app_lookup_first_application') }} fa
        join {{ ref('int_credit_app_base') }} details
            on fa.camr_id = details.camr_id
        where (details.is_initial_web_self_signup = true or details.is_automated_entry = true)
        -- Re-evaluation logic:
        -- 1. New companies (not yet in table)
        -- 2. Unlocked companies (is_locked = false) on every run (grace period may have expired)
        -- 3. Companies when first order changes (the order itself changed, not just reassignment)
        and (
            -- From credit app updates
            (
                ({{ filter_transformation_updates('fa._updated_recordtimestamp') }})
                {% if is_incremental() -%}
                and fa.company_id not in (select distinct company_id from {{ this }})  -- New company
                {% endif -%}
            )
            -- Re-evaluate unlocked companies on every run (is_locked flips based on time, not new records)
            {% if is_incremental() -%}
            or fa.company_id in (select distinct company_id from {{ this }} where is_locked = false)
            {% endif -%}
            -- From first order changes (order itself changed, causing first_order_with_salesperson to update)
            -- this will bypass the is_locked check since orders potentially can change
            or fa.company_id in (
                select distinct company_id
                from {{ ref('int_company_first_order_with_salesperson') }}
                where {{ filter_transformation_updates('_updated_recordtimestamp') }}
            )
        )
    ),

    -- Get credit app activity log
    -- Exclude first application only if it has no meaningful salesperson
    credit_app_activity as (
        select
            valid.company_id,
            valid.camr_id,
            details.date_created_ct,
            details.date_received_ct,
            details.date_completed_ct,
            details.salesperson_user_id,
            details.source,
            details.app_status,
            details.app_type,
            details.notes

        from {{ ref('int_credit_app_lookup_valid_applications') }} valid
        join {{ ref('int_credit_app_base') }} details
            on valid.camr_id = details.camr_id
        left join automated_intake_companies aic
            on valid.company_id = aic.company_id
            and valid.camr_id = aic.camr_id
        where valid.company_id in (select company_id from automated_intake_companies)
            -- Exclude first application record if it has no meaningful salesperson
            and not (
                aic.camr_id is not null  -- Is the first application
                and (details.salesperson_user_id is null or details.salesperson = 'Pending Rep Assignment')
            )
    ),

    -- Get first order activity (injected as a row in the timeline)
    first_order_activity as (
        select
            fo.company_id,
            NULL as camr_id,
            CONVERT_TIMEZONE('America/Chicago', fo.date_created)::timestamp_ntz as date_created_ct,
            NULL::date as date_received_ct,
            NULL::date as date_completed_ct,
            os.user_id as salesperson_user_id,
            'Order' as source,
            CASE
                WHEN c.net_terms_id = 1 THEN 'COD'
                WHEN c.net_terms_id != 1 THEN 'Approved'
                ELSE NULL
            END as app_status,
            CASE
                WHEN c.net_terms_id = 1 THEN 'COD'
                WHEN c.net_terms_id != 1 THEN 'Credit'
                ELSE NULL
            END as app_type,
            'First order with salesperson' as notes
        from {{ ref('int_company_first_order_with_salesperson') }} fo
        join {{ ref('platform', 'order_salespersons')}} os
            on os.order_id = fo.order_id and os.salesperson_type_id = 1
        left join {{ ref('platform', 'companies_pit') }} c
            on fo.company_id = c.company_id
            and (
                -- Exact match: order falls within this PIT record's time window
                (fo.date_created >= c._companies_effective_start_utc_datetime
                 and fo.date_created < c._companies_effective_end_utc_datetime)
                -- Fallback: order is before all PIT records, use earliest IF within 1 day 
                or (fo.date_created < c._companies_effective_start_utc_datetime
                    and c._companies_effective_start_utc_datetime = (
                        select min(_companies_effective_start_utc_datetime)
                        from {{ ref('platform', 'companies_pit') }} pit
                        where pit.company_id = c.company_id
                    )
                    and DATEDIFF(day, fo.date_created, c._companies_effective_start_utc_datetime) <= 30
                    )
            )
        where fo.company_id in (select company_id from automated_intake_companies)
    ),

    -- Combined activity log (credit apps + orders)
    activity_log as (
        select * from credit_app_activity
        union all
        select * from first_order_activity
    ),

    -- Get first meaningful activity for each company
    first_activity as (
        select
            company_id,
            MIN(date_created_ct) as date_created_ct
        from activity_log
        group by company_id
    ),

    -- Filter to records within grace period from first meaningful activity
    activity_period as (
        select al.*
        from activity_log al
        join first_activity fa on al.company_id = fa.company_id
        where al.date_created_ct::date <= DATEADD(DAY, {{ grace_period_days }}, fa.date_created_ct::date)
    )

select
    a.company_id,
    a.camr_id,
    a.date_created_ct,
    a.date_received_ct,
    a.date_completed_ct,
    a.salesperson_user_id,
    a.source,
    a.app_status,
    a.app_type,
    a.notes,

    -- Track if grace period window has closed (attribution is locked)
    CASE
        WHEN CURRENT_DATE > DATEADD(DAY, {{ grace_period_days }}, fa.date_created_ct::date) THEN true
        ELSE false
    END as is_locked,

    {{ get_current_timestamp() }} as _updated_recordtimestamp

from activity_period a
join first_activity fa on a.company_id = fa.company_id
