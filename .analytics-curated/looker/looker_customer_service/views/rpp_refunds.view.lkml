
view: rpp_refunds {
  derived_table: {
    sql: select
     concat(year(gl_billing_approved_date), ' - ', lpad(month(gl_billing_approved_date), 2,0)) as Year_Month
   , case when date_trunc(year, gl_billing_approved_date) = date_trunc(year, current_date()) then 1 else 0 end as ytd
   , case when gl_billing_approved_date >= dateadd(year, '-1', date_trunc(year, current_date())) and gl_billing_approved_date <= dateadd(year, '-1', current_date()) then 1 else 0 end as ytd_previous
   ,   *
      from
      analytics.public.v_line_items li
      where
      line_item_type_id = 9
      and
      amount < 0
      and
      gl_billing_approved_date >= dateadd(year, -3, current_date()) ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: invoice_no {
    type: string
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  dimension: year_month {
    label: "Year - Month"
    type: string
    sql: ${TABLE}."YEAR_MONTH" ;;
  }

  dimension: ytd {
    type: number
    sql: ${TABLE}."YTD" ;;
  }

  dimension: ytd_previous {
    type: number
    sql: ${TABLE}."YTD_PREVIOUS" ;;
  }

  dimension_group: gl_date_created {
    type: time
    sql: ${TABLE}."GL_DATE_CREATED" ;;
  }

  dimension_group: gl_billing_approved_date {
    type: time
    sql: ${TABLE}."GL_BILLING_APPROVED_DATE" ;;
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: line_item_id {
    type: number
    sql: ${TABLE}."LINE_ITEM_ID" ;;
  }

  dimension: line_item_type_id {
    type: number
    sql: ${TABLE}."LINE_ITEM_TYPE_ID" ;;
  }

  dimension: line_item_type {
    type: string
    sql: ${TABLE}."LINE_ITEM_TYPE" ;;
  }

  dimension_group: date_updated {
    type: time
    sql: ${TABLE}."DATE_UPDATED" ;;
  }

  dimension_group: date_created {
    type: time
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: extended_data {
    type: string
    sql: ${TABLE}."EXTENDED_DATA" ;;
  }

  dimension: branch_id {
    type: string
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: part_id {
    type: number
    sql: ${TABLE}."PART_ID" ;;
  }

  dimension: number_of_units {
    type: number
    sql: ${TABLE}."NUMBER_OF_UNITS" ;;
  }

  dimension: price_per_unit {
    type: number
    sql: ${TABLE}."PRICE_PER_UNIT" ;;
  }

  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
  }

  measure: amount_sum {
    type: sum
    sql: ${amount} * -1;;
    value_format: "$#,##0"
  }

  measure: taxable_sum {
    type: sum
    sql: ${tax_amount} * -1;;
    value_format: "$#,##0"
  }

  measure: total {
    type: sum
    sql: (${amount} + ${tax_amount}) * -1 ;;
    value_format: "$#,##0"
  }

  measure: ytd_total {
    group_label: "Timeframes"
    label: "YTD Total"
    type: sum
    sql: case when ${ytd} = 1 then (${amount} + ${tax_amount}) * -1 else 0 end ;;
    value_format: "$#,##0"
  }

  measure: previous_ytd_total {
    group_label: "Timeframes"
    label: "Previous YTD Total"
    type: sum
    sql: case when ${ytd_previous} = 1 then (${amount} + ${tax_amount}) * -1 else 0 end ;;
    value_format: "$#,##0"
  }

  dimension: taxable {
    type: yesno
    sql: ${TABLE}."TAXABLE" ;;
  }

  dimension: override_market_tax_rate {
    type: yesno
    sql: ${TABLE}."OVERRIDE_MARKET_TAX_RATE" ;;
  }

  dimension: tax_rate_id {
    type: number
    sql: ${TABLE}."TAX_RATE_ID" ;;
  }

  dimension: payouts_processed {
    type: yesno
    sql: ${TABLE}."PAYOUTS_PROCESSED" ;;
  }

  dimension: tax_rate_percentage {
    type: number
    sql: ${TABLE}."TAX_RATE_PERCENTAGE" ;;
  }

  dimension: tax_amount {
    type: number
    sql: ${TABLE}."TAX_AMOUNT" ;;
  }

  dimension: credit_note_line_item_id {
    type: number
    sql: ${TABLE}."CREDIT_NOTE_LINE_ITEM_ID" ;;
  }

  dimension: credit_note_id {
    type: number
    sql: ${TABLE}."CREDIT_NOTE_ID" ;;
  }

  dimension_group: _es_update_timestamp {
    type: time
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }

  set: detail {
    fields: [
        invoice_id,
  invoice_no,
  gl_date_created_time,
  gl_billing_approved_date_time,
  rental_id,
  line_item_id,
  line_item_type_id,
  line_item_type,
  date_updated_time,
  date_created_time,
  description,
  extended_data,
  branch_id,
  asset_id,
  part_id,
  number_of_units,
  price_per_unit,
  amount,
  taxable,
  override_market_tax_rate,
  tax_rate_id,
  payouts_processed,
  tax_rate_percentage,
  tax_amount,
  credit_note_line_item_id,
  credit_note_id,
  _es_update_timestamp_time
    ]
  }
}
