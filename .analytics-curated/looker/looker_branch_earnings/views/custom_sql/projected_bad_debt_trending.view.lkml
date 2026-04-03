view: projected_bad_debt_trending {
  derived_table: {
    sql:
      with base as (
        select
          pbd.invoice_id,
          pbd.expected_bad_debt_date,
          date_trunc('month', pbd.expected_bad_debt_date) as expected_bad_debt_month_date,
          pbd.expected_bad_debt_month,
          pbd.market_id,
          pbd.billing_approved_date,
          pbd.paid_date,
          pbd.invoice_number,
          pbd.customer_name,
          pbd.salesperson,
          pbd.amount,
          pbd.legal_audit_flag
        from analytics.branch_earnings.projected_bad_debt pbd
        where pbd.expected_bad_debt_date is not null
      ),

      expanded as (
      select
      b.*,
      dateadd(month, 0, b.expected_bad_debt_month_date) as anchor_month_date
      from base b

      union all

      select
      b.*,
      dateadd(month, -1, b.expected_bad_debt_month_date) as anchor_month_date
      from base b

      union all

      select
      b.*,
      dateadd(month, -2, b.expected_bad_debt_month_date) as anchor_month_date
      from base b
      )

      select *
      from expanded
      ;;
  }

  dimension: invoice_anchor_pk {
    hidden: yes
    primary_key: yes
    type: string
    sql:
      concat(
        ${TABLE}.invoice_id::varchar,
        '-',
        to_char(${TABLE}.anchor_month_date, 'YYYY-MM-DD')
      )
    ;;
  }

  measure: invoice_amount {
    type: sum
    value_format_name: usd
    sql: ${amount} ;;
  }

  measure: bad_debt_risk_amount {
    label: "Bad Debt Risk Amount"
    type: sum
    value_format_name: usd
    sql: ${amount} * 0.5 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension_group: anchor_month_date {
    label: "Anchor Month"
    type: time
    timeframes: [date, month, month_name, quarter, year]
    convert_tz: no
    sql: ${TABLE}.anchor_month_date ;;
  }

  dimension_group: expected_bad_debt_date {
    type: time
    timeframes: [date, month, month_name, quarter, year]
    convert_tz: no
    sql: ${TABLE}.expected_bad_debt_date ;;
  }

  dimension: billing_approved_date {
    type: date
    convert_tz: no
    sql: ${TABLE}.billing_approved_date ;;
  }

  dimension_group: paid_date {
    type: time
    timeframes: [date, month, quarter, year]
    convert_tz: no
    sql: ${TABLE}.paid_date ;;
  }

  dimension: expected_bad_debt_month {
    label: "Expected Bad Debt Month"
    type: string
    sql: ${TABLE}.expected_bad_debt_month ;;
  }

  dimension: month_offset_from_anchor {
    label: "Month Offset From Anchor"
    type: number
    sql:
      datediff(
        month,
        ${TABLE}.anchor_month_date,
        date_trunc('month', ${TABLE}.expected_bad_debt_date)
      )
    ;;
  }

  dimension: month_bucket_from_anchor {
    label: "Month Bucket From Anchor"
    type: string
    sql:
      case
        when datediff(month, ${TABLE}.anchor_month_date, date_trunc('month', ${TABLE}.expected_bad_debt_date)) = 0 then 'Selected Month'
        when datediff(month, ${TABLE}.anchor_month_date, date_trunc('month', ${TABLE}.expected_bad_debt_date)) = 1 then 'Next Month'
        when datediff(month, ${TABLE}.anchor_month_date, date_trunc('month', ${TABLE}.expected_bad_debt_date)) = 2 then 'Month +2'
        else 'Outside Window'
      end
    ;;
  }

  dimension: market_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.market_id ;;
  }

  dimension: invoice_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.invoice_id ;;
  }

  dimension: invoice_number {
    type: string
    html: <a style="color:blue" href="https://admin.equipmentshare.com/#/home/transactions/invoices/{{invoice_id._value}}" target="_blank">{{value}}</a> ;;
    sql: ${TABLE}.invoice_number ;;
  }

  dimension: customer_name {
    type: string
    html:
      {% if legal_audit_flag._value == 'true' %}
        <p style="color:tomato">
      {% else %}
        <p>
      {% endif %}
      {{value}}</p>
    ;;
    description: "Orange indicates a customer sent to legal/collections"
    sql: ${TABLE}.customer_name ;;
  }

  dimension: salesperson {
    type: string
    sql: ${TABLE}.salesperson ;;
  }

  dimension: amount {
    type: number
    value_format_name: usd
    sql: ${TABLE}.amount ;;
  }

  dimension: legal_audit_flag {
    type: string
    sql: ${TABLE}.legal_audit_flag ;;
  }

  set: detail {
    fields: [
      month_bucket_from_anchor,
      expected_bad_debt_date_date,
      expected_bad_debt_month,
      market_id,
      billing_approved_date,
      invoice_id,
      invoice_number,
      customer_name,
      salesperson,
      amount
    ]
  }
}
