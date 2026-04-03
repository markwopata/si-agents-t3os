view: company_purchase_order_line_items {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."COMPANY_PURCHASE_ORDER_LINE_ITEMS" ;;
  drill_fields: [company_purchase_order_line_item_id]

  dimension: company_purchase_order_line_item_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."COMPANY_PURCHASE_ORDER_LINE_ITEM_ID" ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: aftermarket_oec {
    type: number
    sql: ${TABLE}."AFTERMARKET_OEC" ;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: attachments {
    type: string
    sql: ${TABLE}."ATTACHMENTS" ;;
  }
  dimension: company_purchase_order_id {
    type: number
    sql: ${TABLE}."COMPANY_PURCHASE_ORDER_ID" ;;
  }
  dimension: company_purchase_order_line_item_number {
    type: number
    sql: ${TABLE}."COMPANY_PURCHASE_ORDER_LINE_ITEM_NUMBER" ;;
  }
  dimension_group: current_promise {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."CURRENT_PROMISE_DATE" ;;
  }
  dimension_group: deleted {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DELETED_AT" AS TIMESTAMP_NTZ) ;;
  }
  dimension: deleted_by_user_id {
    type: number
    sql: ${TABLE}."DELETED_BY_USER_ID" ;;
  }
  dimension: dot_unit_number {
    type: string
    sql: ${TABLE}."DOT_UNIT_NUMBER" ;;
  }
  dimension_group: due_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DUE_DATE" ;;
  }
  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }
  dimension: equipment_model_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_MODEL_ID" ;;
  }
  dimension: factory_build_specifications {
    type: string
    sql: ${TABLE}."FACTORY_BUILD_SPECIFICATIONS" ;;
  }
  dimension: fhwt {
    type: number
    sql: ${TABLE}."FHWT" ;;
  }
  dimension: finance_status {
    type: string
    sql: ${TABLE}."FINANCE_STATUS" ;;
  }
  dimension: financial_schedule_id {
    type: number
    sql: ${TABLE}."FINANCIAL_SCHEDULE_ID" ;;
  }
  dimension: freight_cost {
    type: number
    sql: ${TABLE}."FREIGHT_COST" ;;
  }
  dimension: fuel_card {
    type: string
    sql: ${TABLE}."FUEL_CARD" ;;
  }
  dimension: gvwr {
    type: number
    sql: ${TABLE}."GVWR" ;;
  }
  dimension_group: invoice {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."INVOICE_DATE" ;;
  }
  dimension_group: invoice_due {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."INVOICE_DUE_DATE" ;;
  }
  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }
  dimension_group: license_expiration {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."LICENSE_EXPIRATION" ;;
  }
  dimension: license_plate {
    type: string
    sql: ${TABLE}."LICENSE_PLATE" ;;
  }
  dimension: license_state_id {
    type: number
    sql: ${TABLE}."LICENSE_STATE_ID" ;;
  }
  dimension: lienholder_on_title {
    type: string
    sql: ${TABLE}."LIENHOLDER_ON_TITLE" ;;
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: net_price {
    type: number
    sql: ${TABLE}."NET_PRICE" ;;
  }
  dimension: note {
    type: string
    sql: ${TABLE}."NOTE" ;;
  }
  dimension: odometer {
    type: number
    sql: ${TABLE}."ODOMETER" ;;
  }
  dimension: order_status {
    type: string
    sql: ${TABLE}."ORDER_STATUS" ;;
  }
  dimension_group: original_promise {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."ORIGINAL_PROMISE_DATE" ;;
  }
  dimension_group: paid {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."PAID_DATE" ;;
  }
  dimension: payment_type {
    type: string
    sql: ${TABLE}."PAYMENT_TYPE" ;;
  }
  dimension: pending_schedule {
    type: string
    sql: ${TABLE}."PENDING_SCHEDULE" ;;
  }
  dimension: quantity {
    type: number
    sql: ${TABLE}."QUANTITY" ;;
  }
  dimension: rebate {
    type: number
    sql: ${TABLE}."REBATE" ;;
  }
  dimension: reconciliation_status {
    type: string
    sql: ${TABLE}."RECONCILIATION_STATUS" ;;
  }
  dimension_group: reconciliation_status {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."RECONCILIATION_STATUS_DATE" ;;
  }
  dimension: registration_cost {
    type: number
    sql: ${TABLE}."REGISTRATION_COST" ;;
  }
  dimension_group: release {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."RELEASE_DATE" ;;
  }
  dimension: sage_record_id {
    type: number
    sql: ${TABLE}."SAGE_RECORD_ID" ;;
  }
  dimension: sales_tax {
    type: number
    sql: ${TABLE}."SALES_TAX" ;;
  }
  dimension: serial {
    type: string
    sql: ${TABLE}."SERIAL" ;;
  }
  dimension: tax {
    type: number
    sql: ${TABLE}."TAX" ;;
  }
  dimension: tire_rim_size {
    type: number
    sql: ${TABLE}."TIRE_RIM_SIZE" ;;
  }
  dimension: tire_size {
    type: string
    sql: ${TABLE}."TIRE_SIZE" ;;
  }
  dimension: title_processed {
    type: string
    sql: ${TABLE}."TITLE_PROCESSED" ;;
  }
  dimension: title_status {
    type: string
    sql: ${TABLE}."TITLE_STATUS" ;;
  }
  dimension: titled_owner {
    type: string
    sql: ${TABLE}."TITLED_OWNER" ;;
  }
  dimension: toll_transponder {
    type: string
    sql: ${TABLE}."TOLL_TRANSPONDER" ;;
  }
  dimension: vin {
    type: string
    sql: ${TABLE}."VIN" ;;
  }
  dimension_group: week_to_be_paid {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."WEEK_TO_BE_PAID" ;;
  }
  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
  }
}
