view: v_line_items {
  sql_table_name: "PUBLIC"."V_LINE_ITEMS" ;;

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: branch_id {
    type: string
    sql: ${TABLE}."BRANCH_ID" ;;
  }
  dimension: credit_note_id {
    type: number
    sql: ${TABLE}."CREDIT_NOTE_ID" ;;
  }
  dimension: credit_note_line_item_id {
    type: number
    sql: ${TABLE}."CREDIT_NOTE_LINE_ITEM_ID" ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }
  dimension: extended_data {
    type: string
    sql: ${TABLE}."EXTENDED_DATA" ;;
  }
  dimension_group: gl_billing_approved {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."GL_BILLING_APPROVED_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: gl_date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."GL_DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
  }
  dimension: invoice_no {
    type: string
    sql: ${TABLE}."INVOICE_NO" ;;
  }
  dimension: line_item_id {
    type: number
    sql: ${TABLE}."LINE_ITEM_ID" ;;
  }
  dimension: line_item_type {
    type: string
    sql: ${TABLE}."LINE_ITEM_TYPE" ;;
  }
  dimension: line_item_type_id {
    type: number
    sql: ${TABLE}."LINE_ITEM_TYPE_ID" ;;
  }
  dimension: number_of_units {
    type: number
    sql: ${TABLE}."NUMBER_OF_UNITS" ;;
  }
  dimension: override_market_tax_rate {
    type: yesno
    sql: ${TABLE}."OVERRIDE_MARKET_TAX_RATE" ;;
  }
  dimension: part_id {
    type: number
    sql: ${TABLE}."PART_ID" ;;
  }
  dimension: payouts_processed {
    type: yesno
    sql: ${TABLE}."PAYOUTS_PROCESSED" ;;
  }
  dimension: price_per_unit {
    type: number
    sql: ${TABLE}."PRICE_PER_UNIT" ;;
  }
  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
  }
  dimension: tax_amount {
    type: number
    sql: ${TABLE}."TAX_AMOUNT" ;;
  }
  dimension: tax_rate_id {
    type: number
    sql: ${TABLE}."TAX_RATE_ID" ;;
  }
  dimension: tax_rate_percentage {
    type: number
    sql: ${TABLE}."TAX_RATE_PERCENTAGE" ;;
  }
  dimension: taxable {
    type: yesno
    sql: ${TABLE}."TAXABLE" ;;
  }
  measure: count {
    type: count
  }
}
