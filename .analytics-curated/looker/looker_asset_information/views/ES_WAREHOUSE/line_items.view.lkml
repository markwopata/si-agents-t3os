view: line_items {
  sql_table_name: "ANALYTICS"."PUBLIC"."V_LINE_ITEMS"
    ;;
  drill_fields: [line_item_id]

  dimension: line_item_id {
    # primary_key: yes
    type: number
    sql: ${TABLE}."LINE_ITEM_ID" ;;
  }

  dimension: pkey {
    primary_key: yes
    type: string
    sql: HASH(${line_item_id}, ${credit_note_line_item_id}) ;;
  }

  dimension: credit_note_line_item_id {
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
    sql: ${TABLE}."NUMBER_OF_UNITS" ;;
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

  dimension: created_current_month {
    type: yesno
    sql: date_part(month,${line_items.date_created_raw})  = date_part(month,(date_trunc('month', current_date)))
      and date_part(year,${line_items.date_created_raw})  = date_part(year,(date_trunc('year', current_date))) ;;
  }

  dimension: created_current_year {
    type: yesno
    sql: date_part(year,${line_items.date_created_raw})  = date_part(year,(date_trunc('year', current_date))) ;;
  }

  dimension: approved_current_month {
    type: yesno
    sql: date_part(month,${invoices.billing_approved_raw})  = date_part(month,(date_trunc('month', current_date)))
      and date_part(year,${invoices.billing_approved_raw})  = date_part(year,(date_trunc('year', current_date))) ;;
  }

  dimension: approved_current_year {
    type: yesno
    sql: date_part(year,${invoices.billing_approved_raw})  = date_part(year,(date_trunc('year', current_date))) ;;
  }

  dimension: created_rolling_30 {
    type: yesno
    sql: ${invoices.date_created_raw} >= dateadd('day', -30, current_date) ;;
  }

  dimension: approved_rolling_30 {
    type: yesno
    sql: ${invoices.billing_approved_raw} >= dateadd('day', -30, current_date) ;;
  }

  measure: rental_revenue_approved_YTD {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [approved_current_year: "yes", line_item_type_id: "6, 8, 108, 109"]
  }

  measure: rental_revenue_created_YTD {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [created_current_year: "yes", line_item_type_id: "6, 8, 108, 109"]
  }

  measure: rental_revenue_approved_MTD {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [approved_current_month: "yes", line_item_type_id: "6, 8, 108, 109"]
  }

  measure: rental_revenue_approved_30 {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [approved_rolling_30: "yes", line_item_type_id: "6, 8, 108, 109"]
  }

  measure: count {
    type: count
    drill_fields: [line_item_id, invoices.invoice_id]
  }

  measure: total_revenue_pump_and_power {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd
    filters: [invoices.billing_approved: "yes",
      line_item_type_id: "6, 8, 108, 109",
      amount: "> 0"]
    drill_fields: [pump_and_power_detail*]
  }

  measure: fuel_revenue_pump_and_power {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd
    filters: [invoices.billing_approved: "yes",
      line_item_type_id: "2,7,16,5",
      amount: "> 0"]
    drill_fields: [fuel_pump_and_power_detail*]
  }

  measure: total_rental_revenue {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [line_item_type_id: "6, 8, 108, 109"]
    drill_fields: [invoice_id, link_to_invoice, date_created_date, rental_id, asset_id, amount]
  }

  dimension: link_to_invoice {
    label: "Link to Invoice"
    type: string
    html: <font color="blue "><u><a href="https://admin.equipmentshare.com/#/home/transactions/invoices/search?query={{invoice_id}}" target="_blank">Link to Admin</a></font></u> ;;
    sql: ${invoice_id}  ;;
  }

  set: pump_and_power_detail {
    fields: [
      assets.asset_id,
      pump_and_power_equipment_classes.name,
      market_region_xwalk.market_name,
      invoices.invoice_no,
      link_to_invoice,
      invoices.billing_approved_date,
      total_rental_revenue
    ]
  }

  set: fuel_pump_and_power_detail {
    fields: [
      assets.asset_id,
      pump_and_power_equipment_classes.name,
      market_region_xwalk.market_name,
      invoices.invoice_no,
      link_to_invoice,
      invoices.billing_approved_date,
      fuel_revenue_pump_and_power
    ]
  }
}
