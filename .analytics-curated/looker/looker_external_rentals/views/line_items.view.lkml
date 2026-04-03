view: line_items {
  sql_table_name: "PUBLIC"."GLOBAL_LINE_ITEMS"
    ;;
  drill_fields: [line_item_id]

  dimension: line_item_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."LINE_ITEM_ID" ;;
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
    #sql: ${TABLE}."AMOUNT" ;;
    sql: ${TABLE}."TOTAL" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
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
    sql: CAST(${TABLE}."CREATED_DATE" AS TIMESTAMP_NTZ) ;;
  }

  # dimension_group: date_updated {
  #   type: time
  #   timeframes: [
  #     raw,
  #     time,
  #     date,
  #     week,
  #     month,
  #     quarter,
  #     year
  #   ]
  #   sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
  # }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: extended_data {
    type: string
    sql: ${TABLE}."EXTENDED_DATA" ;;
  }

  dimension: invoice_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: line_item_type_id {
    type: number
    sql: ${TABLE}."LINE_ITEM_TYPE_ID" ;;
  }

  dimension: number_of_units {
    type: number
    # sql: ${TABLE}."NUMBER_OF_UNITS" ;;
    sql: ${TABLE}."QUANTITY" ;;
  }

  dimension: part_id {
    type: number
    sql: ${TABLE}."PART_ID" ;;
  }

  dimension: price_per_unit {
    type: number
    sql: ${TABLE}."PRICE_PER_UNIT" ;;
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: domain_id {
    type: number
    sql: ${TABLE}."DOMAIN_ID" ;;
  }

  dimension: tax {
    type: number
    sql: ${TABLE}."TAX" ;;
  }

  measure: line_item_amount {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd
  }

  dimension: rental_revenue_flag {
    type: yesno
    sql: (${domain_id} = 0 and ${line_item_type_id} = 8) OR  (${domain_id} = 1 and ${line_item_type_id} = 1);;
  }

  measure: rental_revenue {
    label: "To Date Rental Spend"
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [rental_revenue_flag: "Yes"]
    # filters: [line_item_type_id: "8"]
  }

  measure: total_rental_forcast {
    label: "Total Rental Forecast"
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [line_item_type_id: "8"]
  }

  measure: total_tax {
    group_label: "Total Tax"
    label: "Tax"
    type: sum
    sql: ${tax} ;;
    value_format_name: usd
  }

  measure: count {
    type: count
    drill_fields: [line_item_id, invoices.invoice_id]
  }
}
