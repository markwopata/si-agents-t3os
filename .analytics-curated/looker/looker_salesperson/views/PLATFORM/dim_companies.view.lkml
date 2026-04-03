
view: dim_companies {
  sql_table_name: platform.gold.dim_companies ;;


  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: company_key {
    type: string
    sql: ${TABLE}."COMPANY_KEY" ;;
  }

  dimension: company_source {
    type: string
    sql: ${TABLE}."COMPANY_SOURCE" ;;
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: company_has_fleet {
    type: yesno
    sql: ${TABLE}."COMPANY_HAS_FLEET" ;;
  }

  dimension: company_has_fleet_cam {
    type: yesno
    sql: ${TABLE}."COMPANY_HAS_FLEET_CAM" ;;
  }

  dimension: company_timezone {
    type: string
    sql: ${TABLE}."COMPANY_TIMEZONE" ;;
  }

  dimension: company_credit_limit {
    type: number
    sql: ${TABLE}."COMPANY_CREDIT_LIMIT" ;;
  }

  dimension: company_do_not_rent {
    type: yesno
    sql: ${TABLE}."COMPANY_DO_NOT_RENT" ;;
  }

  dimension: company_has_msa {
    type: yesno
    sql: ${TABLE}."COMPANY_HAS_MSA" ;;
  }

  dimension: company_has_rentals {
    type: yesno
    sql: ${TABLE}."COMPANY_HAS_RENTALS" ;;
  }

  dimension: company_net_terms {
    type: string
    sql: ${TABLE}."COMPANY_NET_TERMS" ;;
  }

  dimension: company_is_eligible_for_payouts {
    type: yesno
    sql: ${TABLE}."COMPANY_IS_ELIGIBLE_FOR_PAYOUTS" ;;
  }

  dimension: company_is_rsp_partner {
    type: yesno
    sql: ${TABLE}."COMPANY_IS_RSP_PARTNER" ;;
  }

  dimension: company_is_telematics_service_provider {
    type: yesno
    sql: ${TABLE}."COMPANY_IS_TELEMATICS_SERVICE_PROVIDER" ;;
  }

  dimension: company_is_national_account {
    type: yesno
    sql: ${TABLE}."COMPANY_IS_NATIONAL_ACCOUNT" ;;
  }

  dimension: company_rental_billing_cycle_strategy {
    type: string
    sql: ${TABLE}."COMPANY_RENTAL_BILLING_CYCLE_STRATEGY" ;;
  }

  dimension: company_preferences_bad_debt {
    type: yesno
    sql: ${TABLE}."COMPANY_PREFERENCES_BAD_DEBT" ;;
  }

  dimension: company_preferences_cycle_billing_only {
    type: yesno
    sql: ${TABLE}."COMPANY_PREFERENCES_CYCLE_BILLING_ONLY" ;;
  }

  dimension: company_preferences_disable_monthly_statements {
    type: yesno
    sql: ${TABLE}."COMPANY_PREFERENCES_DISABLE_MONTHLY_STATEMENTS" ;;
  }

  dimension: company_preferences_general_services_administration {
    type: yesno
    sql: ${TABLE}."COMPANY_PREFERENCES_GENERAL_SERVICES_ADMINISTRATION" ;;
  }

  dimension: company_preferences_internal_company {
    type: yesno
    sql: ${TABLE}."COMPANY_PREFERENCES_INTERNAL_COMPANY" ;;
  }

  dimension: company_preferences_in_bankruptcy {
    type: yesno
    sql: ${TABLE}."COMPANY_PREFERENCES_IN_BANKRUPTCY" ;;
  }

  dimension: company_preferences_is_paperless_billing {
    type: yesno
    sql: ${TABLE}."COMPANY_PREFERENCES_IS_PAPERLESS_BILLING" ;;
  }

  dimension: company_preferences_legal_audit {
    type: yesno
    sql: ${TABLE}."COMPANY_PREFERENCES_LEGAL_AUDIT" ;;
  }

  dimension: company_preferences_managed_billing {
    type: yesno
    sql: ${TABLE}."COMPANY_PREFERENCES_MANAGED_BILLING" ;;
  }

  dimension: company_preferences_is_national_account {
    type: yesno
    sql: ${TABLE}."COMPANY_PREFERENCES_IS_NATIONAL_ACCOUNT" ;;
  }

  dimension: company_preferences_primary_billing_contact_user_id {
    type: number
    sql: ${TABLE}."COMPANY_PREFERENCES_PRIMARY_BILLING_CONTACT_USER_ID" ;;
  }

  dimension: company_preferences_rental_billing_cycle_strategy {
    type: string
    sql: ${TABLE}."COMPANY_PREFERENCES_RENTAL_BILLING_CYCLE_STRATEGY" ;;
  }

  dimension_group: company_recordtimestamp {
    type: time
    sql: ${TABLE}."COMPANY_RECORDTIMESTAMP" ;;
  }

  set: detail {
    fields: [
        company_key,
  company_source,
  company_id,
  company_name,
  company_has_fleet,
  company_has_fleet_cam,
  company_timezone,
  company_credit_limit,
  company_do_not_rent,
  company_has_msa,
  company_has_rentals,
  company_net_terms,
  company_is_eligible_for_payouts,
  company_is_rsp_partner,
  company_is_telematics_service_provider,
  company_is_national_account,
  company_rental_billing_cycle_strategy,
  company_preferences_bad_debt,
  company_preferences_cycle_billing_only,
  company_preferences_disable_monthly_statements,
  company_preferences_general_services_administration,
  company_preferences_internal_company,
  company_preferences_in_bankruptcy,
  company_preferences_is_paperless_billing,
  company_preferences_legal_audit,
  company_preferences_managed_billing,
  company_preferences_is_national_account,
  company_preferences_primary_billing_contact_user_id,
  company_preferences_rental_billing_cycle_strategy,
  company_recordtimestamp_time
    ]
  }
}
