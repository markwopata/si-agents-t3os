view: finance_status_bob {
  sql_table_name: "FLEET"."FINANCE_STATUS_BOB" ;;

  dimension_group: _fivetran_synced {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
  }
  dimension: abl_category {
    type: string
    sql: ${TABLE}."ABL_CATEGORY" ;;
  }
  dimension: asset_class {
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: bob {
    type: string
    sql: ${TABLE}."BOB" ;;
  }
  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }
  dimension: core_vs_non_core {
    type: string
    sql: ${TABLE}."CORE_VS_NON_CORE" ;;
  }
  dimension: days_until_due {
    type: number
    sql: ${TABLE}."DAYS_UNTIL_DUE" ;;
  }
  dimension_group: due {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DUE_DATE" ;;
  }
  dimension: due_days_buckets_monthly {
    type: string
    sql: ${TABLE}."DUE_DAYS_BUCKETS_MONTHLY" ;;
  }
  dimension: factory_build_specs {
    type: string
    sql: ${TABLE}."FACTORY_BUILD_SPECS" ;;
  }
  dimension: finance_status {
    type: string
    sql: ${TABLE}."FINANCE_STATUS" ;;
  }
  dimension: financing_designation_ {
    type: string
    sql: ${TABLE}."FINANCING_DESIGNATION_" ;;
  }
  dimension_group: invoice {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."INVOICE_DATE" ;;
  }
  dimension: invoice_number_fleet {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER_FLEET" ;;
  }
  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }
  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }
  dimension: order_number_fleet {
    type: string
    sql: ${TABLE}."ORDER_NUMBER_FLEET" ;;
  }
  dimension: order_status {
    type: string
    sql: ${TABLE}."ORDER_STATUS" ;;
  }
  dimension: paid_vs_nonpaid_own {
    type: string
    sql: ${TABLE}."PAID_VS_NONPAID_OWN" ;;
  }
  dimension: payment_ {
    type: number
    sql: ${TABLE}."PAYMENT_" ;;
  }
  dimension: payment_month {
    type: string
    sql: ${TABLE}."PAYMENT_MONTH" ;;
  }
  dimension: pending_schedule {
    type: string
    sql: ${TABLE}."PENDING_SCHEDULE" ;;
  }
  dimension_group: purchase_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."PURCHASE_CREATED_DATE" ;;
  }
  dimension: purchase_order_number {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_NUMBER" ;;
  }
  dimension: recon_status_with_shipment_verification {
    type: string
    sql: ${TABLE}."RECON_STATUS_WITH_SHIPMENT_VERIFICATION" ;;
  }
  dimension: reconciliation_status {
    type: string
    sql: ${TABLE}."RECONCILIATION_STATUS" ;;
  }
  dimension: serial_number_vin {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER_VIN" ;;
  }
  dimension: statement_verified {
    type: string
    sql: ${TABLE}."STATEMENT_VERIFIED" ;;
  }
  dimension: total_purchase_price {
    type: number
    sql: ${TABLE}."TOTAL_PURCHASE_PRICE" ;;
  }
  dimension: ttile_status_for_vehicles_ {
    type: string
    sql: ${TABLE}."TTILE_STATUS_FOR_VEHICLES_" ;;
  }
  dimension: vendor_id {
    type: number
    sql: ${TABLE}."VENDOR_ID" ;;
  }
  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }
  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
  }
  measure: count {
    type: count
    drill_fields: [market_name, vendor_name]
  }
}
