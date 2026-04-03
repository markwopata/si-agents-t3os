view: credit_note_line_items {
  sql_table_name: "PUBLIC"."CREDIT_NOTE_LINE_ITEMS"
    ;;
  drill_fields: [credit_note_line_item_id]

  dimension: credit_note_line_item_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."CREDIT_NOTE_LINE_ITEM_ID" ;;
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

  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
  }

  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: credit_amount {
    type: number
    sql: ${TABLE}."CREDIT_AMOUNT" ;;
  }

  dimension: credit_note_id {
    type: number
    sql: ${TABLE}."CREDIT_NOTE_ID" ;;
  }

  dimension: credit_tax_amount {
    type: number
    sql: ${TABLE}."CREDIT_TAX_AMOUNT" ;;
  }

  dimension: credit_tax_rate_percentage {
    type: number
    sql: ${TABLE}."CREDIT_TAX_RATE_PERCENTAGE" ;;
  }

  dimension_group: date_created {
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
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: date_updated {
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

  dimension: line_item_id {
    type: number
    sql: ${TABLE}."LINE_ITEM_ID" ;;
  }

  dimension: line_item_type_id {
    type: number
    # hidden: yes
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

  dimension: price_per_unit {
    type: number
    sql: ${TABLE}."PRICE_PER_UNIT" ;;
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
    drill_fields: [credit_note_line_item_id, line_item_types.name, line_item_types.line_item_type_id]
  }
}
