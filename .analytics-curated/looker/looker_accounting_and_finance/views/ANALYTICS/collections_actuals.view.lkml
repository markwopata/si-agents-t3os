view: collections_actuals {
  sql_table_name: "ANALYTICS"."TREASURY"."COLLECTIONS_ACTUALS" ;;

################## PRIMARY KEY ##################
  dimension: key {
    type: string
    primary_key: yes
    sql: ${TABLE}."MONTH_"||'-'||${TABLE}."INVOICE_NO" ;;
  }

################## DATES ##################

  dimension_group: month_ {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."MONTH_" ;; }

  dimension: month_num {
    type: number
    sql: MONTH(${TABLE}."MONTH_") ;;
  }

  ################## DIMENSIONS ##################

  dimension: invoice_no {
    type: string
    sql: ${TABLE}."REGION_DISTRICT" ;;
  }

  dimension: salesperson_user_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: salesperson_name {
    type: string
    sql: ${TABLE}."SALESPERSON_NAME" ;;
  }

  dimension: customer_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }

  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: branch_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: branch_name {
    type: string
    sql: ${TABLE}."BRANCH_NAME" ;;
  }

  dimension: region_district {
    type: string
    sql: ${TABLE}."REGION_DISTRICT" ;;
  }

  dimension: collector {
    type: string
    sql: ${TABLE}."COLLECTOR" ;;
  }

################## MEASURES ##################

  measure: mtd_revenue {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."MTD_REVENUE" ;;
  }

  measure: total_ar {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."TOTAL_AR" ;;
  }

  measure: current_ar {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."CURRENT_AR" ;;
  }

  measure: past_due_ar {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."PAST_DUE_AR" ;;
  }

  measure: revenue {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."MTD_REVENUE" ;;
    filters: [month__quarter: "this quarter"]
  }

  measure: beginning_ar {
    label: "Beginning A/R"
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."TOTAL_AR" ;;
    filters: [month__quarter: "last quarter",month_num: "3,6,9,12"]
  }

  measure: ending_ar {
    label: "Ending A/R"
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."TOTAL_AR" ;;
    filters: [month__date: "this month"]
  }

  measure: collections {
    type: number
    value_format_name: usd_0
    sql: ${beginning_ar} + ${revenue} - ${ending_ar} ;;
  }

}
