view: dim_companies {
  sql_table_name: "PLATFORM"."GOLD"."V_COMPANIES" ;;

  # PRIMARY KEY
  dimension: company_key {
    primary_key: yes
    type: string
    sql: ${TABLE}."COMPANY_KEY" ;;
    hidden: yes
  }

  # NATURAL KEYS
  dimension: company_source {
    type: string
    sql: ${TABLE}."COMPANY_SOURCE" ;;
    description: "Source system for company data"
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
    description: "Natural company ID"
    value_format_name: id
  }

  # COMPANY DETAILS
  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
    description: "Company name"
    link: {
      label: "Company Details"
      url: "/dashboards/company_profile?company_id={{ value }}"
    }
  }

  dimension: company_timezone {
    type: string
    sql: ${TABLE}."COMPANY_TIMEZONE" ;;
    description: "Company timezone"
  }

  # COMPANY FLAGS
  dimension: company_has_fleet {
    type: yesno
    sql: ${TABLE}."COMPANY_HAS_FLEET" ;;
    description: "Company has fleet management"
  }

  dimension: company_has_fleet_cam {
    type: yesno
    sql: ${TABLE}."COMPANY_HAS_FLEET_CAM" ;;
    description: "Company has fleet camera systems"
  }

  dimension: company_do_not_rent {
    type: yesno
    sql: ${TABLE}."COMPANY_DO_NOT_RENT" ;;
    description: "Company marked as do not rent"
  }

  dimension: company_has_msa {
    type: yesno
    sql: ${TABLE}."COMPANY_HAS_MSA" ;;
    description: "Company has Master Service Agreement"
  }

  dimension: company_has_rentals {
    type: yesno
    sql: ${TABLE}."COMPANY_HAS_RENTALS" ;;
    description: "Company has rental history"
  }

  dimension: company_is_eligible_for_payouts {
    type: yesno
    sql: ${TABLE}."COMPANY_IS_ELIGIBLE_FOR_PAYOUTS" ;;
    description: "Company eligible for payouts"
  }

  dimension: company_is_rsp_partner {
    type: yesno
    sql: ${TABLE}."COMPANY_IS_RSP_PARTNER" ;;
    description: "Company is RSP partner"
  }

  dimension: company_is_telematics_service_provider {
    type: yesno
    sql: ${TABLE}."COMPANY_IS_TELEMATICS_SERVICE_PROVIDER" ;;
    description: "Company is telematics service provider"
  }

  dimension: company_is_national_account {
    type: yesno
    sql: ${TABLE}."COMPANY_IS_NATIONAL_ACCOUNT" ;;
    description: "Company is national account"
  }

  # FINANCIAL
  dimension: company_credit_limit {
    type: number
    sql: ${TABLE}."COMPANY_CREDIT_LIMIT" ;;
    description: "Company credit limit"
    value_format_name: usd
  }

  dimension: company_net_terms {
    type: string
    sql: ${TABLE}."COMPANY_NET_TERMS" ;;
    description: "Company payment terms"
  }

  dimension: company_rental_billing_cycle_strategy {
    type: string
    sql: ${TABLE}."COMPANY_RENTAL_BILLING_CYCLE_STRATEGY" ;;
    description: "Rental billing cycle strategy"
  }

  # NEW PREFERENCE FLAGS
  dimension: company_preferences_bad_debt {
    type: yesno
    sql: ${TABLE}."COMPANY_PREFERENCES_BAD_DEBT" ;;
    description: "Company has bad debt preferences"
    group_label: "Company Preferences"
  }

  dimension: company_preferences_cycle_billing_only {
    type: yesno
    sql: ${TABLE}."COMPANY_PREFERENCES_CYCLE_BILLING_ONLY" ;;
    description: "Company prefers cycle billing only"
    group_label: "Company Preferences"
  }

  dimension: company_preferences_disable_monthly_statements {
    type: yesno
    sql: ${TABLE}."COMPANY_PREFERENCES_DISABLE_MONTHLY_STATEMENTS" ;;
    description: "Monthly statements disabled for company"
    group_label: "Company Preferences"
  }

  dimension: company_preferences_general_services_administration {
    type: yesno
    sql: ${TABLE}."COMPANY_PREFERENCES_GENERAL_SERVICES_ADMINISTRATION" ;;
    description: "Company is GSA customer"
    group_label: "Company Preferences"
  }

  dimension: company_preferences_internal_company {
    type: yesno
    sql: ${TABLE}."COMPANY_PREFERENCES_INTERNAL_COMPANY" ;;
    description: "Company is internal"
    group_label: "Company Preferences"
  }

  dimension: company_preferences_in_bankruptcy {
    type: yesno
    sql: ${TABLE}."COMPANY_PREFERENCES_IN_BANKRUPTCY" ;;
    description: "Company is in bankruptcy"
    group_label: "Company Preferences"
  }

  dimension: company_preferences_is_paperless_billing {
    type: yesno
    sql: ${TABLE}."COMPANY_PREFERENCES_IS_PAPERLESS_BILLING" ;;
    description: "Company prefers paperless billing"
    group_label: "Company Preferences"
  }

  dimension: company_preferences_legal_audit {
    type: yesno
    sql: ${TABLE}."COMPANY_PREFERENCES_LEGAL_AUDIT" ;;
    description: "Company under legal audit"
    group_label: "Company Preferences"
  }

  dimension: company_preferences_managed_billing {
    type: yesno
    sql: ${TABLE}."COMPANY_PREFERENCES_MANAGED_BILLING" ;;
    description: "Company has managed billing"
    group_label: "Company Preferences"
  }

  dimension: company_preferences_is_national_account {
    type: yesno
    sql: ${TABLE}."COMPANY_PREFERENCES_IS_NATIONAL_ACCOUNT" ;;
    description: "Company is national account (from preferences)"
    group_label: "Company Preferences"
  }

  dimension: company_preferences_primary_billing_contact_user_id {
    type: number
    sql: ${TABLE}."COMPANY_PREFERENCES_PRIMARY_BILLING_CONTACT_USER_ID" ;;
    description: "Primary billing contact user ID"
    group_label: "Company Preferences"
  }

  dimension: company_preferences_rental_billing_cycle_strategy {
    type: string
    sql: ${TABLE}."COMPANY_PREFERENCES_RENTAL_BILLING_CYCLE_STRATEGY" ;;
    description: "Rental billing cycle strategy from preferences"
    group_label: "Company Preferences"
  }

  # MEASURES
  measure: count {
    type: count
    description: "Number of companies"
    drill_fields: [company_name, company_id, company_source]
  }

  measure: total_credit_limit {
    type: sum
    sql: ${TABLE}."COMPANY_CREDIT_LIMIT" ;;
    description: "Total credit limit across companies"
    value_format_name: usd
  }

  # TIMESTAMP
  dimension_group: company_recordtimestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."COMPANY_RECORDTIMESTAMP" AS TIMESTAMP_NTZ) ;;
    description: "When this company record was created"
  }
}
