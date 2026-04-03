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
    # hidden: yes
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

  dimension: net_line_amount {
    type: number
    sql: ${amount} - ${credit_amount} ;;
  }

  measure: total_retail_credits {
    type: sum
    sql: ${credit_amount} ;;
    value_format_name: usd_0
  }

  measure: total_new_fleet_credits {
    type: sum
    sql: ${credit_amount} ;;
    filters: [line_item_type_id: "24, 111"]
    value_format_name: usd_0
  }

  measure: total_used_fleet_credits {
    type: sum
    sql: ${credit_amount} ;;
    filters: [line_item_type_id: "81, 110"]
    value_format_name: usd_0
  }

  measure: total_dealship_fleet_credits {
    type: sum
    sql: ${credit_amount} ;;
    filters: [line_item_type_id: "80, 120, 125, 141, 152, 153"]
    value_format_name: usd_0
  }

  measure: total_own_credits {
    type: sum
    sql: ${credit_amount} ;;
    filters: [line_item_type_id: "123, 127"]
    value_format_name: usd_0
  }

  measure: total_lsd_credits {
    type: sum
    sql: ${credit_amount} ;;
    filters: [line_item_type_id: "118, 126"]
    value_format_name: usd_0
  }

  measure: total_rpo_credits {
    type: sum
    sql: ${credit_amount} ;;
    filters: [line_item_type_id: "50"]
    value_format_name: usd_0
  }

  measure: under_10k_credits {
    type: sum
    sql: ${credit_amount} ;;
    filters: [line_item_type_id: "145, 146, 147, 148, 149, 150"]
    value_format_name: usd_0
  }

  measure: count {
    type: count
    drill_fields: [credit_note_line_item_id, credit_notes.credit_note_id]
  }






}
