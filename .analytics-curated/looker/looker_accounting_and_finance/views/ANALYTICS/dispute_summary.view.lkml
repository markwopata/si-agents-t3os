view: dispute_summary {
  sql_table_name: "ANALYTICS"."TREASURY"."DISPUTE_SUMMARY" ;;

  ############ DIMENSIONS ############

  dimension: branch_id {
    type: string
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: invoice_no {
    type: string
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  dimension: collector {
    type: string
    sql: ${TABLE}."COLLECTOR" ;;
  }

  dimension: branch_name {
    type: string
    sql: ${TABLE}."BRANCH_NAME" ;;
  }

  dimension: created_by_email {
    type: string
    sql: ${TABLE}."CREATED_BY_EMAIL" ;;
  }

  dimension: created_by_user_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."CREATED_BY_USER_ID" ;;
  }

  dimension_group: created_month {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."CREATED_MONTH" ;;
  }

  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: date_resolved {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_RESOLVED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: days_to_resolve {
    type: number
    value_format_name: decimal_2
    sql: ${TABLE}."DAYS_TO_RESOLVE" ;;
  }

  dimension: dispute_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."DISPUTE_ID" ;;
  }

  dimension: resolved_by_email {
    type: string
    sql: ${TABLE}."RESOLVED_BY_EMAIL" ;;
  }

  dimension: resolved_by_user_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."RESOLVED_BY_USER_ID" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  dimension: created_by_title {
    type: string
    sql: ${TABLE}."CREATED_BY_TITLE" ;;
  }

  dimension: resolved_by_title {
    type: string
    sql: ${TABLE}."RESOLVED_BY_TITLE" ;;
  }

  dimension: general_manager {
    type: string
    sql: ${TABLE}."GENERAL_MANAGER" ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  ############ MEASURES ############

  measure: count {
    type: count
    value_format_name: decimal_0
    drill_fields: [trx_details*]
  }

measure: open_count {
 type: count
  value_format_name: decimal_0
 drill_fields: [trx_details*]
  filters: [status: "open"]
 }

  measure: resolved_count {
    type: count
    value_format_name: decimal_0
    drill_fields: [trx_details*]
    filters: [status: "resolved"]
  }

measure: average_time_to_resolve {
  label: "Average Days to Resolve"
  type: average
  value_format_name: decimal_1
  drill_fields: [trx_details*]
  sql: days_to_resolve ;;
  filters: [status: "resolved"]
}


  ############ DRILL FIELDS ############
  set: trx_details {
    fields: [dispute_id,invoice_no,collector,status,branch_id,branch_name,region,general_manager,created_by_user_id,created_by_title,created_by_email,resolved_by_user_id,resolved_by_email,resolved_by_title,date_created_date,date_resolved_date,days_to_resolve]
  }

}
