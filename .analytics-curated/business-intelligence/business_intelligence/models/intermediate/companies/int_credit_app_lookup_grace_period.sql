-- depends_on: {{ ref('int_credit_app_base') }}

-- * captures the final state of credit applications after a grace period

{%- set grace_period_days = 5 -%}

{{ config(
    materialized='incremental',
    unique_key=['company_id'],
    incremental_strategy='merge',
    merge_exclude_columns = ['_created_recordtimestamp']
) }}

with
    {% if is_incremental() -%}
    -- Get companies to evaluate: updated applications
    updated_company_ids as (
        -- New companies with recent credit app activity
        select distinct company_id
        from {{ ref('int_credit_app_lookup_valid_applications') }}
        where {{ filter_transformation_updates('_updated_recordtimestamp') }}
        and company_id not in (select distinct company_id from {{ this }})  -- New company

        union
        
        -- Re-evaluate unlocked companies on every run (is_locked changes based on time, not new records)
        select distinct company_id
        from {{ this }}
        where is_locked = false
    ),

    -- Track companies that got their first salesperson assignment (for force re-eval)
    new_salesperson_assignment as (
        select distinct company_id
        from {{ ref('int_credit_app_lookup_first_application_with_salesperson') }}
        where {{ filter_transformation_updates('_updated_recordtimestamp') }}
    ),
    {% endif -%}

    -- Identify STANDARD INTAKE companies (based on absolute first application)
    standard_intake_companies as (
        select
            fa.company_id
        from {{ ref('int_credit_app_lookup_first_application') }} fa
        join {{ ref('int_credit_app_base') }} details
            on fa.camr_id = details.camr_id
        where not (details.is_initial_web_self_signup = true or details.is_automated_entry = true)
    )

    -- All credit apps for STANDARD INTAKE companies (filtered early to avoid processing automated intake)
    , all_apps as (
        select
            valid.company_id,
            valid.camr_id,
            details.date_created_ct
        from {{ ref('int_credit_app_lookup_valid_applications') }} valid
        join {{ ref('int_credit_app_base') }} details
            on valid.camr_id = details.camr_id
        where valid.company_id in (select company_id from standard_intake_companies)
        {% if is_incremental() -%}
            and valid.company_id in (select company_id from updated_company_ids)
        {% endif -%}
    )

    -- For standard intake companies: prioritize first app with salesperson, fallback to first app
    , first_application as (
        select
            COALESCE(fa_sp.company_id, fa.company_id) as company_id,
            COALESCE(fa_sp.camr_id, fa.camr_id) as camr_id,
            details.date_created_ct,
            details.date_received_ct,
            details.date_completed_ct
        from {{ ref('int_credit_app_lookup_first_application') }} fa
        left join {{ ref('int_credit_app_lookup_first_application_with_salesperson') }} fa_sp
            on fa.company_id = fa_sp.company_id
        join {{ ref('int_credit_app_base') }} details
            on COALESCE(fa_sp.camr_id, fa.camr_id) = details.camr_id
        where fa.company_id in (select company_id from standard_intake_companies)
    ), 

    {% if is_incremental() -%}
    -- Find the latest record date for each company to check if grace period has ended
    company_latest_record as (
        select
            a.company_id,
            max(a.date_created_ct) as latest_record_date
        from all_apps a
        group by a.company_id
    ),

    -- Identify companies still within grace period OR newly got salesperson
    companies_to_reevaluate as (
        select
            clr.company_id,
            ad.date_created_ct
        from company_latest_record clr
        join first_application ad on clr.company_id = ad.company_id
        where clr.latest_record_date::date <= DATEADD(DAY, {{ grace_period_days }}, ad.date_created_ct::date)
            or clr.company_id in (select company_id from new_salesperson_assignment)  -- Force re-eval
    ),
    {% endif -%}

    -- Filter for companies that need to be processed
    filtered_apps as (
        select a.*
        from all_apps a
        {% if is_incremental() -%}
        left join {{ this }} t on a.company_id = t.company_id
        where (
            t.company_id is null  -- New company not in target yet
            or a.company_id in (select company_id from companies_to_reevaluate)  -- Still in grace period or newly assigned
        )
        {% endif -%}
    ),

    -- Takes the absolute latest record within grace period
    -- is_locked evaluated here using first_application's camr_id (which prioritizes first app with salesperson)
    final_record as (
        select
            a.company_id,
            a.camr_id,
            CASE
                WHEN fa_sp.camr_id IS NOT NULL
                    AND CURRENT_DATE > DATEADD(DAY, {{ grace_period_days }}, ad.date_created_ct::date)
                THEN true
                ELSE false
            END as is_locked
        from filtered_apps a
        join first_application ad on a.company_id = ad.company_id
        left join {{ ref('int_credit_app_lookup_first_application_with_salesperson') }} fa_sp
            on ad.camr_id = fa_sp.camr_id
        where a.date_created_ct::date <= DATEADD(DAY, {{ grace_period_days }}, ad.date_created_ct::date)
        qualify row_number() over (
            partition by a.company_id
            order by a.date_created_ct desc
        ) = 1
    )

select
    fr.company_id,
    fr.camr_id,
    fr.is_locked,

    {{ get_current_timestamp() }} as _created_recordtimestamp,
    {{ get_current_timestamp() }} as _updated_recordtimestamp

from final_record fr