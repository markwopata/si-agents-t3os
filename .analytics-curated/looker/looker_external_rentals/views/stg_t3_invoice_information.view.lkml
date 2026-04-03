view: stg_t3_invoice_information {
  sql_table_name: BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__INVOICE_INFORMATION ;;


  # Primary key - combining multiple fields since this is denormalized data
  dimension: primary_key {
    type: string
    primary_key: yes
    sql: concat(${rental_id}, '_', ${invoice_no}, '_', ${line_item_type_name}) ;;
    hidden: yes
  }

  # Date dimensions - preserving original timeframe groupings and formats
  dimension_group: billing_approved {
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
    sql: CAST(${TABLE}."BILLING_APPROVED_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: invoice {
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
    sql: CAST(${TABLE}."INVOICE_DATE" AS TIMESTAMP_NTZ) ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  # String dimensions - preserving original labels and properties
  dimension: invoice_no {
    type: string
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  dimension: line_item_type_name {
    type: string
    sql: ${TABLE}."LINE_ITEM_TYPE_NAME" ;;
    label: "Charge Type"
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
    value_format_name: id
  }

  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
    value_format_name: id
  }

  dimension: custom_name {
    label: "Asset"
    type: string
    sql: ${TABLE}."CUSTOM_NAME" ;;
  }

  dimension: asset_class {
    label: "Class"
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
    view_label: "Class"
  }

  dimension: purchase_order_name {
    label: "PO"
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_NAME" ;;
    full_suggestions: yes
  }

  dimension: location_nickname {
    label: "Jobsite"
    type: string
    sql: ${TABLE}."LOCATION_NICKNAME" ;;
  }

  dimension: job_name {
    type: string
    sql: ${TABLE}."JOB_NAME" ;;
  }

  dimension: phase_name {
    type: string
    sql: ${TABLE}."JOB_NAME" ;;
  }

  # ID dimensions for potential joins (hidden from end users)
  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
    hidden: yes
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
    hidden: yes
  }

  # Measure dimensions that were originally measures in line_items view
  dimension: line_item_amount_raw {
    type: number
    sql: ${TABLE}."LINE_ITEM_AMOUNT" ;;
    hidden: yes
  }

  dimension: total_tax_raw {
    type: number
    sql: ${TABLE}."TOTAL_TAX" ;;
    hidden: yes
  }

  # Measures - preserving original formatting and labels
  measure: line_item_amount {
    type: sum
    sql: ${line_item_amount_raw} ;;
    value_format_name: usd
  }

  measure: total_tax {
    group_label: "Total Tax"
    label: "Tax"
    type: sum
    sql: ${total_tax_raw} ;;
    value_format_name: usd
  }

  # Count measure
  measure: count {
    type: count
    drill_fields: [rental_id, invoice_no, custom_name, asset_class, purchase_order_name]
  }

  # Additional measures that might be useful
  measure: average_line_item_amount {
    type: average
    sql: ${line_item_amount_raw} ;;
    value_format_name: usd
  }

  measure: total_amount_with_tax {
    type: number
    sql: ${line_item_amount} + ${total_tax} ;;
    value_format_name: usd
  }
}
