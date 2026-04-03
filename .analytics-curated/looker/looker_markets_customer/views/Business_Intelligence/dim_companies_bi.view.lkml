view: dim_companies_bi {
  sql_table_name: "BUSINESS_INTELLIGENCE"."GOLD"."DIM_COMPANIES_BI" ;;

  dimension_group: _created_recordtimestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."_CREATED_RECORDTIMESTAMP" ;;
  }
  dimension_group: _updated_recordtimestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."_UPDATED_RECORDTIMESTAMP" ;;
  }
  dimension: company_activity_status {
    type: string
    sql: ${TABLE}."COMPANY_ACTIVITY_STATUS" ;;
  }
  dimension: company_analytics_mimic_link {
    type: string
    sql: ${TABLE}."COMPANY_ANALYTICS_MIMIC_LINK" ;;
  }
  dimension: company_conversion_status {
    type: string
    sql: ${TABLE}."COMPANY_CONVERSION_STATUS" ;;
  }
  dimension: company_credit_limit {
    type: number
    sql: ${TABLE}."COMPANY_CREDIT_LIMIT" ;;
  }
  dimension: company_credit_status {
    type: string
    sql: ${TABLE}."COMPANY_CREDIT_STATUS" ;;
  }
  dimension: company_do_not_rent {
    type: yesno
    sql: ${TABLE}."COMPANY_DO_NOT_RENT" ;;
  }
  dimension: company_fleet_mimic_link {
    type: string
    sql: ${TABLE}."COMPANY_FLEET_MIMIC_LINK" ;;
  }
  dimension: company_has_fleet {
    type: yesno
    sql: ${TABLE}."COMPANY_HAS_FLEET" ;;
  }
  dimension: company_has_fleet_cam {
    type: yesno
    sql: ${TABLE}."COMPANY_HAS_FLEET_CAM" ;;
  }
  dimension: company_has_msa {
    type: yesno
    sql: ${TABLE}."COMPANY_HAS_MSA" ;;
  }
  dimension: company_has_orders {
    type: yesno
    sql: ${TABLE}."COMPANY_HAS_ORDERS" ;;
  }
  dimension: company_has_rentals {
    type: yesno
    sql: ${TABLE}."COMPANY_HAS_RENTALS" ;;
  }
  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }
  dimension: company_is_current_vip {
    type: yesno
    sql: ${TABLE}."COMPANY_IS_CURRENT_VIP" ;;
  }
  dimension: company_is_do_not_use {
    type: yesno
    sql: ${TABLE}."COMPANY_IS_DO_NOT_USE" ;;
  }
  dimension: company_is_duplicate {
    type: yesno
    sql: ${TABLE}."COMPANY_IS_DUPLICATE" ;;
  }
  dimension: company_is_eligible_for_payouts {
    type: yesno
    sql: ${TABLE}."COMPANY_IS_ELIGIBLE_FOR_PAYOUTS" ;;
  }
  dimension: company_is_employee {
    type: yesno
    sql: ${TABLE}."COMPANY_IS_EMPLOYEE" ;;
  }
  dimension: company_is_es_internal {
    type: yesno
    sql: ${TABLE}."COMPANY_IS_ES_INTERNAL" ;;
  }
  dimension: company_is_misc {
    type: yesno
    sql: ${TABLE}."COMPANY_IS_MISC" ;;
  }
  dimension: company_is_national_account {
    type: yesno
    sql: ${TABLE}."COMPANY_IS_NATIONAL_ACCOUNT" ;;
  }
  dimension: company_is_new_account {
    type: yesno
    sql: ${TABLE}."COMPANY_IS_NEW_ACCOUNT" ;;
  }
  dimension: company_is_prospect {
    type: yesno
    sql: ${TABLE}."COMPANY_IS_PROSPECT" ;;
  }
  dimension: company_is_rsp_partner {
    type: yesno
    sql: ${TABLE}."COMPANY_IS_RSP_PARTNER" ;;
  }
  dimension: company_is_soft_deleted {
    type: yesno
    sql: ${TABLE}."COMPANY_IS_SOFT_DELETED" ;;
  }
  dimension: company_is_spam {
    type: yesno
    sql: ${TABLE}."COMPANY_IS_SPAM" ;;
  }
  dimension: company_is_sub_renter_only {
    type: yesno
    sql: ${TABLE}."COMPANY_IS_SUB_RENTER_ONLY" ;;
  }
  dimension: company_is_telematics_service_provider {
    type: yesno
    sql: ${TABLE}."COMPANY_IS_TELEMATICS_SERVICE_PROVIDER" ;;
  }
  dimension: company_is_test {
    type: yesno
    sql: ${TABLE}."COMPANY_IS_TEST" ;;
  }
  dimension: company_is_vip {
    type: yesno
    sql: ${TABLE}."COMPANY_IS_VIP" ;;
  }
  dimension: company_key {
    type: string
    sql: ${TABLE}."COMPANY_KEY" ;;
  }
  dimension: company_merged_to_company_id {
    type: number
    sql: ${TABLE}."COMPANY_MERGED_TO_COMPANY_ID" ;;
  }
  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }
  dimension: company_name_id {
    type: string
    sql: CONCAT(${company_name}, ' - ', ${company_id}) ;;
  }
  dimension: company_name_id_link {
    label: "Customer Name, ID, NA Icon"
    type: string
    sql: ${company_name} ;;

    html:
    <a href="https://equipmentshare.looker.com/dashboards/28?Company+Name=-EMPTY-&Company+ID={{ company_id._value | url_encode }}"
       target="_blank"
       style="color:#0063f3; text-decoration:underline;">
      {{ rendered_value }} ➔
    </a>
    <br>
    <span style="color:#8C8C8C;">
      ID: {{ company_id._value }}
    </span>
  ;;
  }
  dimension: company_net_terms {
    type: string
    sql: ${TABLE}."COMPANY_NET_TERMS" ;;
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
  dimension: company_preferences_in_bankruptcy {
    type: yesno
    sql: ${TABLE}."COMPANY_PREFERENCES_IN_BANKRUPTCY" ;;
  }
  dimension: company_preferences_internal_company {
    type: yesno
    sql: ${TABLE}."COMPANY_PREFERENCES_INTERNAL_COMPANY" ;;
  }
  dimension: company_preferences_is_national_account {
    type: yesno
    sql: ${TABLE}."COMPANY_PREFERENCES_IS_NATIONAL_ACCOUNT" ;;
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
  dimension: company_preferences_primary_billing_contact_user_id {
    type: number
    sql: ${TABLE}."COMPANY_PREFERENCES_PRIMARY_BILLING_CONTACT_USER_ID" ;;
  }
  dimension: company_preferences_rental_billing_cycle_strategy {
    type: string
    sql: ${TABLE}."COMPANY_PREFERENCES_RENTAL_BILLING_CYCLE_STRATEGY" ;;
  }
  dimension: company_rental_billing_cycle_strategy {
    type: string
    sql: ${TABLE}."COMPANY_RENTAL_BILLING_CYCLE_STRATEGY" ;;
  }
  dimension: company_source {
    type: string
    sql: ${TABLE}."COMPANY_SOURCE" ;;
  }
  dimension: company_timezone {
    type: string
    sql: ${TABLE}."COMPANY_TIMEZONE" ;;
  }
  measure: count {
    type: count
    drill_fields: [company_name]
  }
}
