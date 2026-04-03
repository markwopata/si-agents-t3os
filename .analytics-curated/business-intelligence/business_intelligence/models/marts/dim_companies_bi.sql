{{ config(
    materialized='table'
    , unique_key=['company_key']
) }} 

with orders_with_sub_renters as (
    select distinct sub_renter_company_id
    from {{ ref('platform', 'orders') }} o
    join {{ ref('platform', 'sub_renters') }} sr
        on sr.sub_renter_id = o.sub_renter_id
),

    -- if a company has only done business as a sub renter
    sub_renters_only as (
        select s.sub_renter_company_id
        from orders_with_sub_renters s
        where not exists (
            select 1
            from {{ ref('platform','orders') }} o
            where o.company_id = s.sub_renter_company_id
        )
    )

    SELECT 
        c.company_key
        , c.company_source
        , c.company_id
        , c.company_name
        , c.company_has_fleet
        , c.company_has_fleet_cam
        , c.company_timezone
        , c.company_credit_limit
        , c.company_do_not_rent
        , c.company_has_msa
        , c.company_has_rentals
        , c.company_net_terms
        , CASE
            WHEN c.company_net_terms IS NULL THEN NULL
            WHEN c.company_net_terms = 'Cash on Delivery' THEN 'COD'
            ELSE 'Credit'
        END as company_credit_status
        , c.company_is_eligible_for_payouts
        , c.company_is_rsp_partner
        , c.company_is_telematics_service_provider
        
        , c.company_is_national_account
        , c.company_rental_billing_cycle_strategy
        , c.company_preferences_bad_debt
        , c.company_preferences_cycle_billing_only
        , c.company_preferences_disable_monthly_statements
        , c.company_preferences_general_services_administration
        , c.company_preferences_internal_company
        , c.company_preferences_in_bankruptcy
        , c.company_preferences_is_paperless_billing
        , c.company_preferences_legal_audit
        , c.company_preferences_managed_billing
        , c.company_preferences_is_national_account
        , c.company_preferences_primary_billing_contact_user_id
        , c.company_preferences_rental_billing_cycle_strategy

        , COALESCE(c.company_id in (
            SELECT company_id from {{ ref('stg_seed_companies__vip') }} 
            ), FALSE) as company_is_vip
        , COALESCE(c.company_id in (
            SELECT company_id from {{ ref('stg_seed_companies__vip') }}
             where is_current_vip = TRUE), FALSE
             ) as company_is_current_vip
        , CASE WHEN f.flag = 'deleted' then true else false end as company_is_soft_deleted
        , CASE WHEN f.flag = 'do_not_use' then true else false end as company_is_do_not_use
        , CASE WHEN f.flag = 'duplicate' then true else false end as company_is_duplicate
        , CASE WHEN f.flag = 'employee' then true else false end as company_is_employee
        , CASE WHEN f.flag = 'es_internal' then true else false end as company_is_es_internal
        , CASE WHEN f.flag = 'misc' then true else false end as company_is_misc
        , CASE WHEN f.flag = 'prospect' then true else false end as company_is_prospect
        , CASE WHEN f.flag = 'spam' then true else false end as company_is_spam
        , CASE WHEN f.flag = 'test' then true else false end as company_is_test
        , m.to_company_id as company_merged_to_company_id

        , COALESCE(cf.is_new_account, FALSE) AS company_is_new_account
        , COALESCE(cf.has_orders, FALSE) AS company_has_orders
        , COALESCE(cf.conversion_status, 'Not Applicable') AS company_conversion_status
        , COALESCE(act.company_activity_status, 'Not Applicable') as company_activity_status
        , COALESCE(rs.lifetime_rental_status, 'Never Rented') as company_lifetime_rental_status
        , sr.sub_renter_company_id IS NOT NULL AS company_is_sub_renter_only
        , COALESCE(mimic.fleet_mimic_link, 'Not Applicable') as company_fleet_mimic_link
        , COALESCE(mimic.analytics_mimic_link, 'Not Applicable') as company_analytics_mimic_link

        , {{ get_current_timestamp() }} AS _created_recordtimestamp
        , {{ get_current_timestamp() }} AS _updated_recordtimestamp 

    FROM {{ ref('platform', 'dim_companies') }} c
    LEFT JOIN {{ ref('int_companies_seed_flagged') }} f 
        ON f.company_id = c.company_id
    LEFT JOIN {{ ref('int_companies_merged') }} m
        ON m.from_company_id = c.company_id
    LEFT JOIN {{ ref('int_company_conversion_flags') }} cf
        ON c.company_id = cf.company_id
    LEFT JOIN {{ ref('int_company_activity_status') }} act
        ON c.company_id = act.company_id
    LEFT JOIN {{ ref('int_company_lifetime_rental_status') }} rs
        ON c.company_id = rs.company_id
    LEFT JOIN sub_renters_only sr 
        ON sr.sub_renter_company_id = c.company_id
    LEFT JOIN {{ ref('int_company_mimic_links') }} mimic 
        ON mimic.company_id = c.company_id