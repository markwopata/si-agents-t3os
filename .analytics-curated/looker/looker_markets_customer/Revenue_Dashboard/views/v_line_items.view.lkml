view: v_line_items {
  derived_table: {
    sql:
select
l.*,
t.name as line_item_type
from analytics.public.v_line_items l
inner join es_warehouse.public.line_item_types t
on l.line_item_type_id = t.line_item_type_id;;
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

  dimension: credit_note_id {
    type: number
    sql: ${TABLE}."CREDIT_NOTE_ID" ;;
  }

  dimension: credit_note_line_item_id {
    type: number
    sql: ${TABLE}."CREDIT_NOTE_LINE_ITEM_ID" ;;
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

  dimension_group: gl_billing_approved {
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
    sql: CAST(${TABLE}."GL_BILLING_APPROVED_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: gl_date_created {
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
    sql: CAST(${TABLE}."GL_DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: line_item_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."LINE_ITEM_ID" ;;
  }

  dimension: line_item_type_id {
    type: number
    sql: ${TABLE}."LINE_ITEM_TYPE_ID" ;;
  }

  dimension: is_rental_line_item {
    type: yesno
    sql: ${line_item_type_id} in (6, 8, 108, 109) ;;
  }

  dimension: line_item_type {
    type: string
    sql: ${TABLE}."LINE_ITEM_TYPE" ;;
  }

  dimension: number_of_units {
    type: number
    sql: ${TABLE}."NUMBER_OF_UNITS" ;;
  }

  dimension: override_market_tax_rate {
    type: yesno
    sql: ${TABLE}."OVERRIDE_MARKET_TAX_RATE" ;;
  }

  dimension: part_id {
    type: number
    sql: ${TABLE}."PART_ID" ;;
  }

  dimension: payouts_processed {
    type: yesno
    sql: ${TABLE}."PAYOUTS_PROCESSED" ;;
  }

  dimension: price_per_unit {
    type: number
    sql: ${TABLE}."PRICE_PER_UNIT" ;;
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
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

  # - - - - - MEASURES - - - - -

  measure: count {
    type: count
    drill_fields: []
  }

  measure: total_amount {
    type: sum
    value_format_name: usd_0
    sql: ${amount} ;;
    drill_fields: [
      date_created_date,
      invoice_id,
      line_item_type,
      amount
    ]
  }

   # - - - - - Total Buckets - - - - -

  measure: total_30 {
    type: sum
    value_format_name: usd_0
    sql: ${amount} ;;
    filters: [gl_billing_approved_date: "30 days ago for 30 days"]
    drill_fields: [gl_billing_approved_date, total_amount]
  }

  measure: total_60 {
    type: sum
    value_format_name: usd_0
    sql: ${amount} ;;
    filters: [gl_billing_approved_date: "60 days ago for 60 days"]
    drill_fields: [gl_billing_approved_date, total_amount]
  }

  measure: total_90 {
    type: sum
    value_format_name: usd_0
    sql: ${amount} ;;
    filters: [gl_billing_approved_date: "90 days ago for 90 days"]
    drill_fields: [gl_billing_approved_date, total_amount]
  }

  measure: total_120 {
    type: sum
    value_format_name: usd_0
    sql: ${amount} ;;
    filters: [gl_billing_approved_date: "120 days ago for 120 days"]
    drill_fields: [gl_billing_approved_date, total_amount]
  }

  measure: total_365 {
    type: sum
    value_format_name: usd_0
    sql: ${amount} ;;
    filters: [gl_billing_approved_date: "365 days ago for 365 days"]
    drill_fields: [gl_billing_approved_date, total_amount]
  }

  measure: total_last_year {
    type: sum
    value_format_name: usd_0
    sql: ${amount} ;;
    filters: [gl_billing_approved_date: "last year"]
    drill_fields: [gl_billing_approved_date, total_amount]
  }

  # - - - - - To Date - - - - -

  measure: month_to_date {
    type: sum
    value_format_name: usd_0
    sql: ${amount} ;;
    filters: [gl_billing_approved_date: "this month"]
    drill_fields: [gl_billing_approved_date, total_amount]
  }

  measure: year_to_date {
    type: sum
    value_format_name: usd_0
    sql: ${amount} ;;
    filters: [gl_billing_approved_date: "this year"]
    drill_fields: [gl_billing_approved_date, total_amount]
  }

  # - - - - - Comparison Buckets - - - - -

  measure: last_month_this_time {
    type: sum
    value_format_name: usd_0
    # (line item date created) on or after (beginning of the last month) AND on or before (one month ago)
    sql:  IFF(${gl_billing_approved_date} >= dateadd('month', -1, date_trunc('month', current_date())) AND ${gl_billing_approved_date} <= dateadd('month', -1, current_date()), ${amount}, null);;
    drill_fields: [gl_billing_approved_date, total_amount]
  }

  measure: last_year_this_time {
    type: sum
    value_format_name: usd_0
    sql: IFF(${gl_billing_approved_date} >= dateadd('year', -1, date_trunc('year', current_date())) AND ${gl_billing_approved_date} <= dateadd('year', -1, current_date()), ${amount}, null);;
    drill_fields: [gl_billing_approved_date, total_amount]
  }

  # - - - - - Other Measures - - - - -

  measure: total_assets {
    type: count_distinct
    sql: ${asset_id} ;;
    drill_fields: [asset_id, last_month_this_time, last_year_this_time, total_last_year, year_to_date]
  }
}
