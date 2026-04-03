view: invoices {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."INVOICES"
    ;;
  drill_fields: [invoice_id]

  dimension: invoice_id {
    primary_key: yes
    type: number
    value_format_name: id
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: invoice_id_with_link_to_invoice {
    label: "Invoice ID"
    type: string
    sql: ${invoice_id} ;;
    html: <font color="blue "><u><a href="https://admin.equipmentshare.com/#/home/transactions/invoices/{{ invoice_id._value }}" target="_blank">{{ invoice_id._value }}</a></font></u> ;;
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

  dimension: invoice_pending {
    type: string
    sql: case when ${billing_approved} = 'No' and ${invoice_no} is not null then 'Pending'
          ELSE 'Not Pending'
          END;;
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

  dimension: invoice_no_with_link {
    type: string
    sql: ${invoice_no} ;;
    html: <font color="blue "><u><a href="https://admin.equipmentshare.com/#/home/transactions/invoices/{{ invoice_id._value }}" target="_blank">{{ invoice_no._value }}</a></font></u> ;;
  }

  dimension: line_item_amount {
    type: number
    sql: ${TABLE}."LINE_ITEM_AMOUNT" ;;
  }

  dimension: order_id {
    type: number
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

  dimension: purchase_order_id {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_ID" ;;
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

  dimension: zip_code_shipped_to {
    type: number
    value_format_name: id
    sql: ${TABLE}."SHIP_TO":"address"."zip_code" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [invoice_id]
  }

  measure: total_billed {
    type: sum
    sql: ${billed_amount} ;;
    value_format: "$#,##0.00"
    drill_fields: [work_orders.asset_id, markets.name, asset_owner.name, total_billed_by_invoice]
  }

  measure: total_billed_by_invoice {
    type: sum
    sql: ${billed_amount} ;;
    drill_fields: [invoice_no, work_orders.asset_id, billing_approved_date, billed_amount]
  }

  dimension_group: billing_approved_time {
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

  filter: date_filter {
    description: "Use this date filter in combination with the timeframes dimension for dynamic date filtering"
    type: date
  }

  dimension_group: filter_start_date {
    type: time
    timeframes: [raw]
    sql: CASE WHEN {% date_start date_filter %} IS NULL THEN '1970-01-01' ELSE NULLIF({% date_start date_filter %}, '2099-12-31')::timestamp END;;
#MySQL: CASE WHEN {% date_start date_filter %} IS NULL THEN '1970-01-01' ELSE  TIMESTAMP(NULLIF({% date_start date_filter %}, 0)) END;;
  }

  dimension_group: filter_end_date {
    type: time
    timeframes: [raw]
    sql: CASE WHEN {% date_end date_filter %} IS NULL THEN CURRENT_DATE ELSE NULLIF({% date_end date_filter %}, '2099-12-31')::timestamp END;;
# MySQL: CASE WHEN {% date_end date_filter %} IS NULL THEN NOW() ELSE TIMESTAMP(NULLIF({% date_end date_filter %}, 0)) END;;
  }

  dimension: interval {
    type: number
    sql: DATEDIFF(seconds, ${filter_start_date_raw}, ${filter_end_date_raw});;
# MySQL: TIMESTAMPDIFF(second, ${filter_end_date_raw}, ${filter_start_date_raw});;
  }

  dimension: previous_start_date {
    type: date
    sql: DATEADD(seconds, -${interval}, ${filter_start_date_raw})  ;;
# MySQL: DATE_ADD(${filter_start_date_raw}, interval ${interval} second) ;;
  }

  dimension: timeframes {
    description: "Use this field in combination with the date filter field for dynamic date filtering"
    suggestions: ["period","previous period"]
  type: string
  case:  {
    when:  {
      sql: ${billing_approved_raw} BETWEEN ${filter_start_date_raw} AND  ${filter_end_date_raw};;
      label: "Period"
    }
    when: {
      sql: ${billing_approved_raw} BETWEEN ${previous_start_date} AND ${filter_start_date_raw} ;;
      label: "Previous Period"
    }
    else: "Not in time period"
  }
}

  dimension: this_period {
    type: yesno
    sql: ${timeframes} = 'Period' ;;
  }

  dimension: last_period {
    type: yesno
    sql: ${timeframes} = 'Previous Period' ;;
  }

  dimension: days_since_beginning_of_period {
    type: number
    sql: iff(${timeframes} = 'Not in time period', null
      , iff(${timeframes} = 'Period', DATEDIFF(DAY, ${filter_start_date_raw}, ${billing_approved_raw})
        , DATEDIFF(DAY, ${previous_start_date}, ${billing_approved_raw})));;
  }

  dimension: admin_link_to_invoice {
    label: "Link to Invoice"
    type: string
    html: <font color="blue "><u><a href="https://admin.equipmentshare.com/#/home/transactions/invoices/search?query={{invoice_id}}" target="_blank">Admin</a></font></u> ;;
    sql: ${invoice_id}  ;;
  }

# -------------------- rolling 30 days section --------------------
  dimension:  last_30_days{
    type: yesno
    sql:  ${billing_approved_date} <= current_date AND ${billing_approved_date} >= (current_date - INTERVAL '30 days')
      ;;
  }

  dimension:  30_60_days{
    type: yesno
    sql:  ${billing_approved_date} <= (current_date - INTERVAL '30 days') AND ${billing_approved_date} >= (current_date - INTERVAL '60 days')
      ;;
  }
  # -------------------- end rolling 30 days section --------------------



  parameter: date_granularity {
    type: string
    default_value: "Weekly"
    allowed_value: {
      label: "Weekly"
      value: "Weekly"
    }
    allowed_value: {
      label: "Monthly"
      value: "Monthly"
    }
    allowed_value: {
      label: "Quarterly"
      value: "Quarterly"
    }
    allowed_value: {
      label: "Yearly"
      value: "Yearly"
    }
  }

  dimension: date_granularity_selection {
    type: string
    sql:
    CASE
      WHEN {% parameter date_granularity %} = 'Weekly' THEN TO_CHAR(DATE_TRUNC('WEEK', ${TABLE}.billing_approved_date), 'YYYY-MM-DD')
      WHEN {% parameter date_granularity %} = 'Monthly' THEN TO_CHAR(DATE_TRUNC('MONTH', ${TABLE}.billing_approved_date), 'YYYY-MM')
      -- WHEN {% parameter time_grain_toggle %} = 'Quarter' THEN TO_CHAR(DATE_TRUNC('QUARTER', ${TABLE}.billing_approved_date), 'YYYY "Q"Q')
      WHEN {% parameter date_granularity %} = 'Quarterly' THEN
  TO_CHAR(DATE_TRUNC('QUARTER', ${TABLE}.billing_approved_date), 'YYYY') || '-Q' || EXTRACT(QUARTER FROM ${TABLE}.billing_approved_date)
      WHEN {% parameter date_granularity %} = 'Yearly' THEN TO_CHAR(DATE_TRUNC('YEAR', ${TABLE}.billing_approved_date), 'YYYY')
    END ;;
  }

  ## ka-work on comparing last year to this year and flagging high purchase customers that have stopped spending

  # dimension_group: current {
  #     type: time
  #     datatype: timestamp
  #     sql: CURRENT_TIMESTAMP() ;;
  #     hidden: yes # This is mainly for use in other dimension definitions
  #     timeframes: [day_of_week_index, hour_of_day, day_of_year]
  # }

  # dimension_group: bap_comparison {
  #   type: time
  #   datatype: timestamp
  #   sql: ${TABLE}.billing_approved_date ;;
  #   hidden: yes # This is mainly for use in other dimension definitions
  #   timeframes: [day_of_week_index, hour_of_day, day_of_year]
  # }

  # dimension: is_ytd {
  #   group_label: "Is period-to-date?"
  #   label: "Is YtD?"
  #   description: "Is year-to-date? Whether the date in question is earlier within its year than the current date. Useful for filtering to comparable parts of the current period and a past period"
  #   type: yesno
  #   sql: ${bap_comparison_day_of_year} < ${current_day_of_year} ;;
  # }

  # dimension: is_comparison_range {
  #   type: yesno
  #   sql: year(${TABLE}.billing_approved_date) = year(current_date())
  #         or
  #       year(${TABLE}.billing_approved_date) = year(dateadd(year, -1, current_date()))  ;;
  # }

  # dimension: this_year {
  #   type: yesno
  #   sql: year(${TABLE}.billing_approved_date) = year(current_date()) ;;
  # }

  # dimension: last_year {
  #   type: yesno
  #   sql: year(${TABLE}.billing_approved_date) = year(dateadd(year, -1, current_date())) ;;
  # }

}
