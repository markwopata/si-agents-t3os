view: dim_quotes {
  sql_table_name: "BUSINESS_INTELLIGENCE"."GOLD"."DIM_QUOTES" ;;

  dimension_group: _created_recordtimestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."_CREATED_RECORDTIMESTAMP" ;;
  }
  dimension_group: _updated_recordtimestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."_UPDATED_RECORDTIMESTAMP" ;;
  }
  dimension: delivery_type {
    type: string
    sql: ${TABLE}."DELIVERY_TYPE" ;;
  }
  dimension: has_accessories {
    type: yesno
    sql: ${TABLE}."HAS_ACCESSORIES" ;;
  }
  dimension: has_equipment_rentals {
    type: yesno
    sql: ${TABLE}."HAS_EQUIPMENT_RENTALS" ;;
  }
  dimension: has_pdf {
    type: yesno
    sql: ${TABLE}."HAS_PDF" ;;
  }
  dimension: has_sale_items {
    type: yesno
    sql: ${TABLE}."HAS_SALE_ITEMS" ;;
  }
  dimension: is_guest_request {
    type: yesno
    sql: ${TABLE}."IS_GUEST_REQUEST" ;;
  }
  dimension: is_tax_exempt {
    type: yesno
    sql: ${TABLE}."IS_TAX_EXEMPT" ;;
  }
  dimension: missed_quote_reason {
    type: string
    sql: ${TABLE}."MISSED_QUOTE_REASON" ;;
  }
  dimension: missed_quote_reason_other {
    type: string
    sql: ${TABLE}."MISSED_QUOTE_REASON_OTHER" ;;
  }
  dimension: po_id {
    type: number
    sql: ${TABLE}."PO_ID" ;;
  }
  dimension: po_name {
    type: string
    sql: ${TABLE}."PO_NAME" ;;
  }
  dimension: project_type {
    type: string
    sql: ${TABLE}."PROJECT_TYPE" ;;
  }
  dimension: quote_id {
    type: string
    sql: ${TABLE}."QUOTE_ID" ;;
  }
  dimension: quote_key {
    type: string
    sql: ${TABLE}."QUOTE_KEY" ;;
  }
  dimension: quote_number {
    type: number
    sql: ${TABLE}."QUOTE_NUMBER" ;;
  }
  dimension: quote_source {
    type: string
    sql: ${TABLE}."QUOTE_SOURCE" ;;
  }
  dimension: quote_status {
    type: string
    sql: ${TABLE}."QUOTE_STATUS" ;;
  }
  measure: count {
    type: count
    drill_fields: [po_name]
  }
}
