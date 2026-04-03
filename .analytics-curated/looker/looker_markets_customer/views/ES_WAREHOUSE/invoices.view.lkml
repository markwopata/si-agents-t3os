view: invoices {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."INVOICES"
    ;;
  drill_fields: [invoice_id]

  dimension: invoice_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
    value_format_name: id
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

  dimension: billed_amount {
    type: number
    sql: ${TABLE}."BILLED_AMOUNT" ;;
  }

  dimension: billing_approved {
    type: yesno
    sql: ${TABLE}."BILLING_APPROVED" ;;
  }

  dimension: billing_approved_by_user_id {
    type: number
    sql: ${TABLE}."BILLING_APPROVED_BY_USER_ID" ;;
  }

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

  dimension: billing_provider_id {
    type: number
    sql: ${TABLE}."BILLING_PROVIDER_ID" ;;
  }

  dimension: created_by_user_id {
    type: number
    sql: ${TABLE}."CREATED_BY_USER_ID" ;;
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

  dimension_group: due {
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
    sql: CAST(${TABLE}."DUE_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: end {
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
    sql: CAST(${TABLE}."END_DATE" AS TIMESTAMP_NTZ) ;;
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
  }

  dimension: invoice_no {
    type: string
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  dimension: line_item_amount {
    type: number
    sql: ${TABLE}."LINE_ITEM_AMOUNT" ;;
  }

  dimension: order_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension: owed_amount {
    type: number
    sql: ${TABLE}."OWED_AMOUNT" ;;
  }

  dimension: paid {
    type: yesno
    sql: ${TABLE}."PAID" ;;
  }

  dimension_group: paid {
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
    sql: CAST(${TABLE}."PAID_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: private_note {
    type: string
    sql: ${TABLE}."PRIVATE_NOTE" ;;
  }

  dimension: public_note {
    type: string
    sql: ${TABLE}."PUBLIC_NOTE" ;;
  }

  dimension: reference {
    type: string
    sql: ${TABLE}."REFERENCE" ;;
  }

  dimension: rental_amount {
    type: number
    sql: ${TABLE}."RENTAL_AMOUNT" ;;
  }

  dimension: rpp_amount {
    type: number
    sql: ${TABLE}."RPP_AMOUNT" ;;
  }

  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: sent {
    type: yesno
    sql: ${TABLE}."SENT" ;;
  }

  dimension: ship_from {
    type: string
    sql: ${TABLE}."SHIP_FROM" ;;
  }

  dimension: ship_from_branch_id {
    type: number
    sql: ${ship_from}:branch_id::number ;;
    value_format_name: id
  }

  dimension_group: start {
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
    sql: CAST(${TABLE}."START_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: tax_amount {
    type: number
    sql: ${TABLE}."TAX_AMOUNT" ;;
  }

  dimension: xero_id {
    type: string
    sql: ${TABLE}."XERO_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [invoice_id, orders.order_id, line_items.count]
  }

  measure: first_invoice {
    type: min
    sql: ${invoice_id} ;;
  }

  dimension: created_date_month_only {
    type: number
    sql: date_part(month,${date_created_raw}) ;;
  }

  dimension: billing_approved_is_month_to_date {
    type: yesno
    sql: date_part(day,${billing_approved_raw}) <= date_part(day,current_timestamp) ;;
  }

  measure: Total_Outstanding {
    type: sum
    value_format_name: usd
    sql: ${owed_amount} ;;
    drill_fields: [date_created_date,companies.name, track_link, due_date,invoice_no,owed_amount]
    filters: [paid: "no",
      billing_approved: "yes"]
  }

  measure: Total_Revenue {
    type: sum
    sql: ${billed_amount} ;;
    value_format_name: usd
    filters: [billing_approved: "yes"]
    drill_fields: [date_created_date,companies.name, track_link, due_date,invoice_no,billed_amount]
  }

  measure: dso {
    type: number
    sql: (${Total_Outstanding}/case when ${Total_Revenue} = 0 then null else ${Total_Revenue} end)*180 ;;
    value_format_name: decimal_0
    drill_fields: [dso_detail*]
  }

  dimension: track_link {
    label: "Track Link"
    type: string
    html: <font color="blue "><u><a href="https://app.estrack.com/#/home/dashboard/invoices/{{invoice_id}}?status=outstanding" target="_blank">Track</a></font></u> ;;
    sql: ${invoice_id}  ;;
  }

  dimension: invoice_link {
    label: "Invoice Link to Admin"
    type: string
    html: <font color="blue "><u><a href="https://admin.equipmentshare.com/#/home/transactions/invoices/search?query={{invoice_no}}" target="_blank">{{ invoice_no._value }}</a></font></u> ;;
    sql: ${invoice_no}  ;;
  }

  dimension: month_abbreviation {
    type: string
    sql:
    case when ${created_date_month_only} = 1 then 'Jan'
    when ${created_date_month_only} = 2 then 'Feb'
    when ${created_date_month_only} = 3 then 'Mar'
    when ${created_date_month_only} = 4 then 'Apr'
    when ${created_date_month_only} = 5 then 'May'
    when ${created_date_month_only} = 6 then 'Jun'
    when ${created_date_month_only} = 7 then 'Jul'
    when ${created_date_month_only} = 8 then 'Aug'
    when ${created_date_month_only} = 9 then 'Sep'
    when ${created_date_month_only} = 10 then 'Oct'
    when ${created_date_month_only} = 11 then 'Nov'
    when ${created_date_month_only} = 12 then 'Dec' end
    ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  set: dso_detail {
    fields: [
      market_region_xwalk.market_name,
      invoice_date,
      invoice_no,
      Total_Outstanding,
      Total_Revenue
    ]
  }
}
