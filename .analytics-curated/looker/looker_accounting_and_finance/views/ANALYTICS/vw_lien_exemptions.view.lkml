view: vw_lien_exemptions {
  sql_table_name: "ANALYTICS"."TREASURY"."VW_LIEN_EXEMPTIONS" ;;

  ##### DIMENSIONS #####

  dimension: customer_id {
    value_format_name: id
    type: number
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }

  dimension: customer_name {
    type: string
    html: <a href= "https://admin.equipmentshare.com/#/home/companies/{{ vw_lien_exemptions.customer_id }}" target="_blank" style="color: #0063f3; text-decoration: underline;">{{ value }}</a> ;;
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: employee_name {
    type: string
    sql: ${TABLE}."EMPLOYEE_NAME" ;;
  }

  dimension: employee_title {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }

  dimension: final_collector {
    type: string
    sql: ${TABLE}."FINAL_COLLECTOR" ;;
  }

  dimension: internal_company {
    type: string
    sql: ${TABLE}."INTERNAL_COMPANY" ;;
  }

  dimension: has_msa {
    label: "Has MSA?"
    type: string
    sql: ${TABLE}."HAS_MSA" ;;
  }

  dimension: specialized_billing {
    type: string
    sql: ${TABLE}."SPECIALIZED_BILLING" ;;
  }

  dimension: direct_manager_name {
    label: "Collections Manager"
    type: string
    sql: ${TABLE}."DIRECT_MANAGER_NAME" ;;
  }

  dimension: tam {
    label: "TAM"
    type: string
    sql: ${TABLE}."TAM" ;;
  }

  dimension: dsm {
    label: "DSM"
    type: string
    sql: ${TABLE}."DSM" ;;
  }

  dimension: rsm {
    label: "RSM"
    type: string
    sql: ${TABLE}."RSM" ;;
  }

  dimension: national_account {
    type: string
    sql: ${TABLE}."NATIONAL_ACCOUNT" ;;
  }

  dimension: legal {
    type: string
    sql: ${TABLE}."LEGAL" ;;
  }

  dimension: lien_exemption {
    type: string
    sql: ${TABLE}."LIEN_EXEMPTION" ;;
  }

  dimension: managed_billing {
    type: string
    sql: ${TABLE}."MANAGED_BILLING" ;;
  }

  dimension: gsa {
    label: "GSA"
    type: string
    sql: ${TABLE}."GSA" ;;
  }

  dimension: market_id {
    value_format_name: id
    label: "Market ID"
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: region_district {
    type: string
    sql: ${TABLE}."REGION_DISTRICT" ;;
  }

  ##### MEASURES #####

 measure: applied_payments {
  label: "Last 90 Days Payments"
  value_format_name: usd
    type: sum
    sql: ${TABLE}."APPLIED_PAYMENTS" ;;
  }

  measure: days_0_30 {
    label: " 0 - 30 Days"
    value_format_name: usd
    type: sum
    sql: ${TABLE}."DAYS_0_30" ;;
  }

  measure: days_120_plus {
    label: "120+ Days"
    value_format_name: usd
    type: sum
    sql: ${TABLE}."DAYS_120_PLUS" ;;
  }

  measure: days_31_60 {
    label: "31 - 60 Days"
    value_format_name: usd
    type: sum
    sql: ${TABLE}."DAYS_31_60" ;;
  }

  measure: days_61_90 {
    label: "61 - 90 Days"
    value_format_name: usd
    type: sum
    sql: ${TABLE}."DAYS_61_90" ;;
  }

  measure: days_91_120 {
    label: "91 - 120 Days"
    value_format_name: usd
    type: sum
    sql: ${TABLE}."DAYS_91_120" ;;
  }

  measure: less_than_0 {
    label: "Current"
    value_format_name: usd
    type: sum
    sql: ${TABLE}."LESS_THAN_0" ;;
  }

  measure: revenue {
    label: "6 Month Revenue"
    value_format_name: usd
    type: sum
    sql: ${TABLE}."REVENUE" ;;
  }

  measure: total_ar {
    label: "Total AR"
    value_format_name: usd
    type: number
    sql:  ifnull(${less_than_0},0) +
          ifnull(${days_0_30},0) +
          ifnull(${days_31_60},0) +
          ifnull(${days_61_90},0) +
          ifnull(${days_91_120},0) +
          ifnull(${days_120_plus},0)   ;;
  }


  measure: dso {
    label: "6 Month DSO"
    value_format_name: decimal_1
    type: number
    sql: iff(${revenue} = 0,null, (${total_ar}/${revenue}) * 180)    ;;
  }


}
