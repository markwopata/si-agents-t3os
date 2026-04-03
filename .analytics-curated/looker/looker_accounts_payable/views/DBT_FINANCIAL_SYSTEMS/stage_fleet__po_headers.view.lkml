view: stage_fleet__po_headers {
  sql_table_name: "P2P_GOLD"."FLEET__PO_HEADERS" ;;

  dimension: email_approver {
    type: string
    sql: ${TABLE}."EMAIL_APPROVER" ;;
  }
  dimension: email_archiver {
    type: string
    sql: ${TABLE}."EMAIL_ARCHIVER" ;;
  }
  dimension: email_creator {
    type: string
    sql: ${TABLE}."EMAIL_CREATOR" ;;
  }
  dimension: email_submitter {
    type: string
    sql: ${TABLE}."EMAIL_SUBMITTER" ;;
  }
  dimension: fk_approved_by_user_id {
    type: number
    sql: ${TABLE}."FK_APPROVED_BY_USER_ID" ;;
  }
  dimension: fk_archived_by_user_id {
    type: number
    sql: ${TABLE}."FK_ARCHIVED_BY_USER_ID" ;;
  }
  dimension: fk_company_id {
    type: number
    sql: ${TABLE}."FK_COMPANY_ID" ;;
  }
  dimension: fk_created_by_user_id {
    type: number
    sql: ${TABLE}."FK_CREATED_BY_USER_ID" ;;
  }
  dimension: fk_market_id {
    type: number
    sql: ${TABLE}."FK_MARKET_ID" ;;
  }
  dimension: fk_submitted_by_user_id {
    type: number
    sql: ${TABLE}."FK_SUBMITTED_BY_USER_ID" ;;
  }
  dimension: id_vendor {
    type: string
    sql: ${TABLE}."ID_VENDOR" ;;
  }
  dimension: name_approver {
    type: string
    sql: ${TABLE}."NAME_APPROVER" ;;
  }
  dimension: name_archiver {
    type: string
    sql: ${TABLE}."NAME_ARCHIVER" ;;
  }
  dimension: name_creator {
    type: string
    sql: ${TABLE}."NAME_CREATOR" ;;
  }
  dimension: name_market {
    type: string
    sql: ${TABLE}."NAME_MARKET" ;;
  }
  dimension: name_payment_term {
    type: string
    sql: ${TABLE}."NAME_PAYMENT_TERM" ;;
  }
  dimension: name_submitter {
    type: string
    sql: ${TABLE}."NAME_SUBMITTER" ;;
  }
  dimension: note {
    type: string
    sql: ${TABLE}."NOTE" ;;
  }
  dimension: num_days {
    type: number
    sql: ${TABLE}."NUM_DAYS" ;;
  }
  dimension: pdf_uuid {
    type: string
    sql: ${TABLE}."PDF_UUID" ;;
  }
  dimension: pk_po_header_id {
    type: number
    sql: ${TABLE}."PK_PO_HEADER_ID" ;;
  }
  dimension: po_number_base {
    type: string
    sql: ${TABLE}."PO_NUMBER_BASE" ;;
  }
  dimension: sum_aftermarket_oec {
    type: number
    sql: ${TABLE}."SUM_AFTERMARKET_OEC" ;;
  }
  dimension: sum_freight_cost {
    type: number
    sql: ${TABLE}."SUM_FREIGHT_COST" ;;
  }
  dimension: sum_net_price {
    type: number
    sql: ${TABLE}."SUM_NET_PRICE" ;;
  }
  dimension: sum_rebate {
    type: number
    sql: ${TABLE}."SUM_REBATE" ;;
  }
  dimension: sum_registration_cost {
    type: number
    sql: ${TABLE}."SUM_REGISTRATION_COST" ;;
  }
  dimension: sum_sales_tax {
    type: number
    sql: ${TABLE}."SUM_SALES_TAX" ;;
  }
  dimension: sum_tax {
    type: number
    sql: ${TABLE}."SUM_TAX" ;;
  }
  dimension: sum_total_oec {
    type: number
    sql: ${TABLE}."SUM_TOTAL_OEC" ;;
  }
  dimension_group: timestamp_approved {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TIMESTAMP_APPROVED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: timestamp_archived {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TIMESTAMP_ARCHIVED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: timestamp_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TIMESTAMP_CREATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: timestamp_loaded {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TIMESTAMP_LOADED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: timestamp_modified {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TIMESTAMP_MODIFIED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: timestamp_submitted {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TIMESTAMP_SUBMITTED" AS TIMESTAMP_NTZ) ;;
  }
  measure: count {
    type: count
  }
}
