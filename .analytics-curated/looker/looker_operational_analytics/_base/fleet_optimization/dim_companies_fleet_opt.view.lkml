view: dim_companies_fleet_opt {
  sql_table_name: "FLEET_OPTIMIZATION"."GOLD"."DIM_COMPANIES_FLEET_OPT" ;;

  dimension: company_credit_limit {
    type: number
    sql: ${TABLE}."COMPANY_CREDIT_LIMIT" ;;
  }
  dimension: company_do_not_rent {
    type: yesno
    sql: ${TABLE}."COMPANY_DO_NOT_RENT" ;;
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
  dimension: company_has_rentals {
    type: yesno
    sql: ${TABLE}."COMPANY_HAS_RENTALS" ;;
  }
  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
    value_format_name: id
  }
  dimension: company_is_eligible_for_payouts {
    type: yesno
    sql: ${TABLE}."COMPANY_IS_ELIGIBLE_FOR_PAYOUTS" ;;
  }
  dimension: company_is_equipmentshare_company {
    type: yesno
    sql: ${TABLE}."COMPANY_IS_EQUIPMENTSHARE_COMPANY" ;;
  }
  dimension: company_is_ies_company {
    type: yesno
    sql: ${TABLE}."COMPANY_IS_IES_COMPANY" ;;
  }
  dimension: company_is_reporting_company {
    type: yesno
    sql: ${TABLE}."COMPANY_IS_REPORTING_COMPANY" ;;
  }
  dimension: company_is_rsp_partner {
    type: yesno
    sql: ${TABLE}."COMPANY_IS_RSP_PARTNER" ;;
  }
  dimension: company_is_telematics_service_provider {
    type: yesno
    sql: ${TABLE}."COMPANY_IS_TELEMATICS_SERVICE_PROVIDER" ;;
  }
  dimension: company_key {
    primary_key: yes
    type: string
    sql: ${TABLE}."COMPANY_KEY" ;;
  }
  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }
  dimension: company_net_terms {
    type: string
    sql: ${TABLE}."COMPANY_NET_TERMS" ;;
  }
  dimension_group: company_recordtimestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."COMPANY_RECORDTIMESTAMP" ;;
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
