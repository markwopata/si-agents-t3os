view: company_purchase_order_line_items {
  sql_table_name: "PUBLIC"."COMPANY_PURCHASE_ORDER_LINE_ITEMS"
    ;;
  drill_fields: [company_purchase_order_line_item_id]

  dimension: company_purchase_order_line_item_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."COMPANY_PURCHASE_ORDER_LINE_ITEM_ID" ;;
  }

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
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
    # hidden: yes
    sql: ${TABLE}."COMPANY_PURCHASE_ORDER_ID" ;;
  }

  dimension: company_purchase_order_line_item_number {
    type: number
    sql: ${TABLE}."COMPANY_PURCHASE_ORDER_LINE_ITEM_NUMBER" ;;
  }

  dimension_group: deleted {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."DELETED_AT" AS TIMESTAMP_NTZ) ;;
  }

  dimension: dot_unit_number {
    type: string
    sql: ${TABLE}."DOT_UNIT_NUMBER" ;;
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

  dimension: freight_cost {
    type: number
    sql: ${TABLE}."FREIGHT_COST" ;;
  }

  dimension: fuel_card {
    type: string
    sql: ${TABLE}."FUEL_CARD" ;;
  }

  dimension_group: invoice {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."INVOICE_DATE" ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }

  dimension_group: license_expiration {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
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

  dimension: market_id {
    type: number
    # hidden: yes
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

  dimension: quantity {
    type: number
    sql: ${TABLE}."QUANTITY" ;;
  }

  dimension: reconciliation_status {
    type: string
    sql: ${TABLE}."RECONCILIATION_STATUS" ;;
  }

  dimension: registration_cost {
    type: number
    sql: ${TABLE}."REGISTRATION_COST" ;;
  }

  dimension_group: release {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."RELEASE_DATE" ;;
  }

  dimension: serial {
    type: string
    sql: ${TABLE}."SERIAL" ;;
  }

  dimension: tax {
    type: number
    sql: ${TABLE}."TAX" ;;
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

  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
  }

  measure: count {
    type: count
    drill_fields: [company_purchase_order_line_item_id, company_purchase_orders.company_purchase_order_id, markets.market_id, markets.canonical_name, markets.name]
  }
}
