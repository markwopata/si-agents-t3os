{{ config(
    materialized='table',
    unique_key=['company_id']
) }}

-- active salesperson reps tied to open quote for a company
with last_open_quote_with_active_salesperson as (
        select
            qc.company_id
            , stg.quote_id
            , stg.updated_date
            , stg.salesperson_user_id as quote_salesperson_user_id
            , em.market_id as quote_salesperson_employee_market_id
        from {{ ref('int_quote_customers') }} qc 
        join {{ ref('stg_quotes__quotes') }} stg
            on COALESCE(qc.quote_customer_id, 'Unknown') = COALESCE(stg.quote_customer_id, 'Unknown')

        left join {{ ref('int_bridge_user_employee') }} br 
            on stg.salesperson_user_id = br.user_id
        join {{ ref('dim_employees') }} e 
            on br.employee_id = e.employee_id
        join {{ ref('platform', 'dim_markets') }} em
            on e.market_key = em.market_key

        WHERE e.employee_status = 'Active'
        AND stg.quote_id in (select quote_id from {{ ref('int_company_open_quotes') }})

        qualify row_number() over (
            partition by qc.company_id
            order by stg.updated_date desc
        ) = 1
    )

-- market_id from credit apps does not serve any business purpose. It's only to fill in some gaps, if needed
    , credit_app as (
        select
            fi.camr_id
            , fi.company_id
            , fi.first_account_date_ct
            , fi.salesperson_user_id as credit_app_salesperson_user_id
            , e.employee_status as credit_app_salesperson_employee_status
            , em.market_id as credit_app_salesperson_employee_market_id
            , cam.market_id as credit_app_market_id
        from {{ ref('int_credit_app_first_intake_resolved') }} fi
        join (
            select
                valid.camr_id
                , valid.company_id
                , details.market_id
            from {{ ref('int_credit_app_lookup_valid_applications') }} valid
            join {{ ref('int_credit_app_base') }} details
                on valid.camr_id = details.camr_id
            qualify row_number() over (partition by valid.company_id order by details.date_created_ct) = 1
        ) cam
            ON cam.camr_id = fi.camr_id

        -- left joins because not all credit apps have salespeople / employees
        left join {{ ref('int_bridge_user_employee') }} br 
            on fi.salesperson_user_id = br.user_id
        left join {{ ref('dim_employees') }} e 
            on br.employee_id = e.employee_id
        left join {{ ref('platform', 'dim_markets') }} em
            on e.market_key = em.market_key
    )

    -- prioritizing credit app's salesperson's market id
    -- otherwise quote's salesperson's market id
    -- else the market id in the credit application itself
    , salesperson_market_resolved as (
        select 
            ca.company_id 
             , CASE 
                WHEN (ca.credit_app_salesperson_employee_status = 'Active' AND ca.credit_app_salesperson_employee_market_id IS NOT NULL )
                THEN ca.credit_app_salesperson_employee_market_id
                WHEN (qs.quote_salesperson_user_id IS NOT NULL AND qs.quote_salesperson_employee_market_id IS NOT NULL)
                THEN qs.quote_salesperson_employee_market_id
                WHEN ca.credit_app_market_id IS NULL THEN ca.credit_app_salesperson_employee_market_id
                ELSE ca.credit_app_market_id
            END::int as market_id
            , CASE 
                when ca.credit_app_salesperson_employee_status = 'Active' 
                then ca.credit_app_salesperson_user_id
                when qs.quote_salesperson_user_id is not null 
                then qs.quote_salesperson_user_id
                else NULL
            END as salesperson_user_id
                
        from credit_app ca
        left join last_open_quote_with_active_salesperson qs
        on ca.company_id = qs.company_id
        AND ca.first_account_date_ct >= '2024-03-04'
    )

select 
    fi.company_id
    , fi.first_account_date_ct
    , r.market_id
    , r.salesperson_user_id

    , {{ get_current_timestamp() }} AS _updated_recordtimestamp 

from {{ ref('int_credit_app_first_intake_resolved') }} fi
left join salesperson_market_resolved r 
    on fi.company_id = r.company_id
left join {{ ref('int_company_conversion_flags') }} cf 
    on fi.company_id = cf.company_id
WHERE NOT cf.is_new_account AND cf.conversion_status = 'Not Converted'