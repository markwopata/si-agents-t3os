
view: secondary_rev_for_reps {
  sql_table_name: analytics.bi_ops.secondary_rev_rep ;;


  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: pk {
    type: string
    primary_key: yes
    sql:  concat(${TABLE}."DATE" , ${TABLE}."INVOICE_ID",${TABLE}."SECONDARY_SALESPERSON_ID", ${TABLE}."RENTAL_ID", ${TABLE}."PERCENT_DISCOUNT")  ;;
  }
  dimension_group: date {
    type: time
    sql: ${TABLE}."DATE" ;;
  }

  dimension: invoice_id {
    type: string
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: rental_id {
    type: string
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: primary_salesperson_id {
    type: string
    sql: ${TABLE}."PRIMARY_SALESPERSON_ID" ;;
  }

  dimension: secondary_salesperson_id {
    type: string
    sql: ${TABLE}."SECONDARY_SALESPERSON_ID" ;;
  }

  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
    value_format_name: usd_0
  }

  measure: total_amount {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
  }

  measure: billing_approved_amount  {
    type: sum
    label: "Total Secondary Revenue"
    sql: CASE WHEN ${date_created_tf} = FALSE AND ${line_item_type_id} IN (6,8,108,109) THEN ${amount} ELSE 0 END ;;
    value_format_name: usd_0
   ## sql_distinct_key: concat(${pk}, ${kpi_daily_joined_historical.pk}) ;;
  }

  dimension: line_item_type_id {
    type: number
    sql: ${TABLE}."LINE_ITEM_TYPE_ID" ;;
  }

  dimension: line_item_id {
    type: number
    sql: ${TABLE}."LINE_ITEM_ID" ;;
  }

  dimension: credit_note_line_item_id {
    type: number
    sql: ${TABLE}."CREDIT_NOTE_LINE_ITEM_ID" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: date_created_tf {
    type: yesno
    sql: ${TABLE}."DATE_CREATED_TF" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: rate_tier {
    type: number
    sql: ${TABLE}."RATE_TIER" ;;
  }

  dimension: final_equipment_class {
    type: string
    sql: ${TABLE}."FINAL_EQUIPMENT_CLASS" ;;
  }

  dimension: percent_discount {
    type: number
    sql: ${TABLE}."PERCENT_DISCOUNT" ;;
    value_format_name: percent_1
  }

  dimension: business_segment_name {
    type: string
    sql: ${TABLE}."BUSINESS_SEGMENT_NAME" ;;
  }

  dimension: segment_sort {
    type: number
    sql: ${TABLE}."SEGMENT_SORT" ;;
  }

  set: detail {
    fields: [
      market_id,
      market_region_xwalk.market_name,
      company_id,
      es_companies.company_name,
      invoice_id,
      primary_salesperson_id,
      final_equipment_class,
      total_amount,
      percent_discount
    ]
  }
}
