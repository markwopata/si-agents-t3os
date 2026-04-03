SELECT 
    company_key
    , company_source
    , company_id
    , company_name
    , company_has_fleet
    , company_has_fleet_cam
    , company_timezone
    , company_credit_limit
    , company_do_not_rent
    , company_has_msa
    , company_has_rentals
    , company_net_terms
    , company_is_eligible_for_payouts
    , company_is_rsp_partner
    , company_is_telematics_service_provider

    , company_credit_status
    , company_is_new_account
    , company_has_orders
    , company_conversion_status
    , company_activity_status
    , company_lifetime_rental_status
    , company_is_sub_renter_only
    
    , company_is_national_account
    , company_rental_billing_cycle_strategy
    , company_preferences_bad_debt
    , company_preferences_cycle_billing_only
    , company_preferences_disable_monthly_statements
    , company_preferences_general_services_administration
    , company_preferences_internal_company
    , company_preferences_in_bankruptcy
    , company_preferences_is_paperless_billing
    , company_preferences_legal_audit
    , company_preferences_managed_billing
    , company_preferences_is_national_account
    , company_preferences_primary_billing_contact_user_id
    , company_preferences_rental_billing_cycle_strategy

    , company_is_vip
    , company_is_current_vip
    , company_is_soft_deleted
    , company_is_do_not_use
    , company_is_duplicate
    , company_is_employee
    , company_is_es_internal
    , company_is_misc
    , company_is_prospect
    , company_is_spam
    , company_is_test
    , company_merged_to_company_id
    , company_fleet_mimic_link
    , company_analytics_mimic_link

    , _created_recordtimestamp
    , _updated_recordtimestamp 

from {{ ref('dim_companies_bi') }}