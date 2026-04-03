view: dim_quotes {
  sql_table_name: "BUSINESS_INTELLIGENCE"."GOLD"."V_DIM_QUOTES" ;;

  dimension_group: _created_recordtimestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."_CREATED_RECORDTIMESTAMP" ;;
    hidden: yes
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
    primary_key: yes
    hidden: yes
  }

  dimension: quote_number {
    type: string
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

  # dimension: lead_source {
  #   type: string
  #   sql: case when ${quote_source} = 'Retail' then 'Online'
  #             when ${quote_source} = 'ESMax' and ${quote_created_by_employee.employee_title} ilike 'customer support%' then 'Customer Support'
  #             else 'Other';;
  # }

  measure: count_expired {
    label: "Expired Quotes"
    type: count
    filters: [quote_status: "Expired"]
    description: "Count of quotes with Expired status"
  }

  measure: count_missed_quote {
    label: "Missed Quotes"
    type: count
    filters: [quote_status: "Missed Quote"]
    description: "Count of quotes with Missed Quote status"
  }

  measure: count_open {
    label: "Open Quotes"
    type: count
    filters: [quote_status: "Open"]
    description: "Count of quotes with Open status"
  }

  measure: count_unknown {
    type: count
    filters: [quote_status: "Unknown"]
    description: "Count of quotes with Unknown status"
  }

  measure: count_order_created {
    label: "Order Created"
    type: count
    filters: [quote_status: "Order Created"]
    description: "Count of quotes with Order Created status"
  }

  measure: count_escalated {
    label: "Currently Escalated"
    type: count
    filters: [quote_status: "Escalated"]
    description: "Count of quotes with Escalated status"
  }

  measure: count {
    type: count
  }
}
