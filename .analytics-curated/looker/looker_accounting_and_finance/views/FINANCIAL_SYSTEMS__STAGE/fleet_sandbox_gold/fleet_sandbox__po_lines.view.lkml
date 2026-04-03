view: fleet_sandbox__po_lines {
  sql_table_name: "FLEET_GOLD"."FLEET_SANDBOX__PO_LINES" ;;

  dimension: amount_aftermarket_oec {
    type: number
    sql: ${TABLE}."AMOUNT_AFTERMARKET_OEC" ;;
  }
  dimension: amount_freight_cost {
    type: number
    sql: ${TABLE}."AMOUNT_FREIGHT_COST" ;;
  }
  dimension: amount_net_price {
    type: number
    sql: ${TABLE}."AMOUNT_NET_PRICE" ;;
  }
  dimension: amount_rebate {
    type: number
    sql: ${TABLE}."AMOUNT_REBATE" ;;
  }
  dimension: amount_registration_cost {
    type: number
    sql: ${TABLE}."AMOUNT_REGISTRATION_COST" ;;
  }
  dimension: amount_sales_tax {
    type: number
    sql: ${TABLE}."AMOUNT_SALES_TAX" ;;
  }
  dimension: amount_tax {
    type: number
    sql: ${TABLE}."AMOUNT_TAX" ;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: attachments {
    type: string
    sql: ${TABLE}."ATTACHMENTS" ;;
  }
  dimension_group: date_current_promise {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_CURRENT_PROMISE" ;;
  }
  dimension_group: date_due {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_DUE" ;;
  }
  dimension_group: date_invoice {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_INVOICE" ;;
  }
  dimension_group: date_invoice_due {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_INVOICE_DUE" ;;
  }
  dimension_group: date_original_promise {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_ORIGINAL_PROMISE" ;;
  }
  dimension_group: date_paid {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_PAID" ;;
  }
  dimension_group: date_reconciliation_status {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_RECONCILIATION_STATUS" ;;
  }
  dimension_group: date_release {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_RELEASE" ;;
  }
  dimension_group: date_week_to_be_paid {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_WEEK_TO_BE_PAID" ;;
  }
  dimension: dot_unit_number {
    type: string
    sql: ${TABLE}."DOT_UNIT_NUMBER" ;;
  }
  dimension: email_submitter {
    type: string
    sql: ${TABLE}."EMAIL_SUBMITTER" ;;
  }
  dimension: factory_build_specifications {
    type: string
    sql: ${TABLE}."FACTORY_BUILD_SPECIFICATIONS" ;;
  }
  dimension: fhwt {
    type: number
    sql: ${TABLE}."FHWT" ;;
  }
  dimension: fk_archived_by_user_id {
    type: number
    sql: ${TABLE}."FK_ARCHIVED_BY_USER_ID" ;;
  }
  dimension: fk_company_id {
    type: number
    sql: ${TABLE}."FK_COMPANY_ID" ;;
  }
  dimension: fk_equipment_class_id {
    type: number
    sql: ${TABLE}."FK_EQUIPMENT_CLASS_ID" ;;
  }
  dimension: fk_equipment_make_id {
    type: number
    sql: ${TABLE}."FK_EQUIPMENT_MAKE_ID" ;;
  }
  dimension: fk_equipment_model_id {
    type: number
    sql: ${TABLE}."FK_EQUIPMENT_MODEL_ID" ;;
  }
  dimension: fk_market_id {
    type: number
    sql: ${TABLE}."FK_MARKET_ID" ;;
  }
  dimension: fk_po_header_id {
    type: number
    sql: ${TABLE}."FK_PO_HEADER_ID" ;;
  }
  dimension: fk_sage_record_id {
    type: number
    sql: ${TABLE}."FK_SAGE_RECORD_ID" ;;
  }
  dimension: fuel_card {
    type: string
    sql: ${TABLE}."FUEL_CARD" ;;
  }
  dimension: gvwr {
    type: number
    sql: ${TABLE}."GVWR" ;;
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
  dimension: line_number {
    type: number
    sql: ${TABLE}."LINE_NUMBER" ;;
  }
  dimension: model_year {
    type: number
    sql: ${TABLE}."MODEL_YEAR" ;;
  }
  dimension: name_equipment_class {
    type: string
    sql: ${TABLE}."NAME_EQUIPMENT_CLASS" ;;
  }
  dimension: name_equipment_make {
    type: string
    sql: ${TABLE}."NAME_EQUIPMENT_MAKE" ;;
  }
  dimension: name_equipment_model {
    type: string
    sql: ${TABLE}."NAME_EQUIPMENT_MODEL" ;;
  }
  dimension: name_submitter {
    type: string
    sql: ${TABLE}."NAME_SUBMITTER" ;;
  }
  dimension: note {
    type: string
    sql: ${TABLE}."NOTE" ;;
  }
  dimension: odometer {
    type: number
    sql: ${TABLE}."ODOMETER" ;;
  }
  dimension: payment_type {
    type: string
    sql: ${TABLE}."PAYMENT_TYPE" ;;
  }
  dimension: pending_schedule {
    type: string
    sql: ${TABLE}."PENDING_SCHEDULE" ;;
  }
  dimension: pk_po_line_id {
    type: number
    sql: ${TABLE}."PK_PO_LINE_ID" ;;
    primary_key: yes
  }
  dimension: po_number {
    type: string
    sql: ${TABLE}."PO_NUMBER" ;;
  }
  dimension: po_number_base {
    type: string
    sql: ${TABLE}."PO_NUMBER_BASE" ;;
  }
  dimension: qty_ordered {
    type: number
    sql: ${TABLE}."QTY_ORDERED" ;;
  }
  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }
  dimension: status_finance {
    type: string
    sql: ${TABLE}."STATUS_FINANCE" ;;
  }
  dimension: status_order {
    type: string
    sql: ${TABLE}."STATUS_ORDER" ;;
  }
  dimension: status_reconciliation {
    type: string
    sql: ${TABLE}."STATUS_RECONCILIATION" ;;
  }
  dimension: status_title {
    type: string
    sql: ${TABLE}."STATUS_TITLE" ;;
  }
  dimension_group: timestamp_archived {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TIMESTAMP_ARCHIVED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: timestamp_loaded {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TIMESTAMP_LOADED" AS TIMESTAMP_NTZ) ;;
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
  measure: count {
    type: count
  }
}
