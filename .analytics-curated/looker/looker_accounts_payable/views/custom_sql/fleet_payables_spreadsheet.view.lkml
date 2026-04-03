view: fleet_payables_spreadsheet {
  sql_table_name: "FLEET"."FLEET_PAYABLES_SPREADSHEET" ;;

  dimension_group: _fivetran_synced {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: _row {
    type: number
    primary_key: yes
    sql: ${TABLE}."_ROW" ;;
  }
  dimension: abl_rating {
    type: string
    sql: ${TABLE}."ABL_RATING" ;;
  }
  dimension: analyst_assigned {
    type: string
    sql: ${TABLE}."ANALYST_ASSIGNED" ;;
  }
  dimension_group: approval_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."APPROVAL_DATE" ;;
  }
  dimension: approval_status {
    type: string
    sql: ${TABLE}."APPROVAL_STATUS" ;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: book_of_business {
    type: string
    sql: ${TABLE}."BOOK_OF_BUSINESS" ;;
  }
  dimension: class {
    type: string
    sql: ${TABLE}."CLASS" ;;
  }
  dimension: core_designation {
    type: string
    sql: ${TABLE}."CORE_DESIGNATION" ;;
  }
  dimension: customer_paid {
    type: string
    sql: ${TABLE}."CUSTOMER_PAID" ;;
  }
  dimension_group: date_of_workflow_update {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_OF_WORKFLOW_UPDATE" ;;
  }
  dimension_group: date_to_be_paid {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_TO_BE_PAID" ;;
  }
  dimension: days_past_due {
    type: number
    sql: ${TABLE}."DAYS_PAST_DUE" ;;
  }
  dimension_group: due_date {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DUE_DATE" ;;
  }
  dimension: factory_build_specs {
    type: string
    sql: ${TABLE}."FACTORY_BUILD_SPECS" ;;
  }
  dimension: finance_designation {
    type: string
    sql: ${TABLE}."FINANCE_DESIGNATION" ;;
  }
  dimension: finance_status {
    type: string
    sql: ${TABLE}."FINANCE_STATUS" ;;
  }
  dimension: ft_vendor_id {
    type: number
    sql: ${TABLE}."FT_VENDOR_ID" ;;
  }
  dimension_group: invoice_date {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."INVOCIE_DATE" ;;
  }
  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOCIE_NUMBER" ;;
  }
  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }
  dimension: market {
    type: string
    sql: ${TABLE}."MARKET" ;;
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }
  dimension: order_number {
    type: string
    sql: ${TABLE}."ORDER_NUMBER" ;;
  }
  dimension: order_status {
    type: string
    sql: ${TABLE}."ORDER_STATUS" ;;
  }
  dimension: recon_status_w_statement_verification {
    type: string
    sql: ${TABLE}."RECON_STATUS_W_STATEMENT_VERIFICATION" ;;
  }
  dimension: reconciliation_status {
    type: string
    sql: ${TABLE}."RECONCILIATION_STATUS" ;;
  }
  dimension_group: release_date {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."RELEASE_DATE" ;;
  }
  dimension: sage_vendor_id {
    type: string
    sql: ${TABLE}."SAGE_VENDOR_ID" ;;
  }
  dimension: sent_to_ap {
    type: string
    sql: ${TABLE}."SENT_TO_AP" ;;
  }
  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }
  dimension: total_oec {
    type: number
    sql: ${TABLE}."TOTAL_OEC" ;;
  }
  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }
  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
  }
  measure: sum_total_oec {
    type: sum
    sql: ${TABLE}."TOTAL_OEC" ;;
  }
  measure: count {
    type: count
    drill_fields: [vendor_name]
  }
}
