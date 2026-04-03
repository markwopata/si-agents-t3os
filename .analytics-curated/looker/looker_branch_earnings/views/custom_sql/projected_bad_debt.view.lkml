view: projected_bad_debt {
  derived_table: {
    sql:
    select pbd.invoice_id,
       pbd.expected_bad_debt_date,
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
      where 1=1
           and coalesce(pbd.PAID_DATE, dateadd(month, 3, (select trunc::date from ANALYTICS.GS.PLEXI_PERIODS where display = {% parameter report_period %} )))
              > dateadd(month, 8, pbd.BILLING_APPROVED_DATE)
           and coalesce(pbd.PAID_DATE, dateadd(month, 1, (select trunc::date from ANALYTICS.GS.PLEXI_PERIODS where display = {% parameter report_period %} )))
               <= dateadd(month, 9, pbd.BILLING_APPROVED_DATE)
       ;;
  }

  parameter: report_period {
    label: "Period"
    type: string
    suggest_explore: plexi_periods
    suggest_dimension: plexi_periods.display
  }

  measure: invoice_amount {
    type: sum
    value_format_name: usd
    sql: ${amount} ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: expected_bad_debt_date {
    type: date
    convert_tz: no
    sql: ${TABLE}.expected_bad_debt_date ;;
  }

  dimension: expected_bad_debt_month {
    label: "Expected Bad Debt Month"
    type: string
    sql: ${TABLE}.expected_bad_debt_month ;;
  }

  dimension: market_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."MARKET_ID" ;;
    primary_key: yes
  }

  dimension: billing_approved_date {
    type: date
    convert_tz: no
    sql: ${TABLE}."BILLING_APPROVED_DATE" ;;
  }

  dimension: invoice_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: invoice_number {
    type: string
    html: <a style="color:blue" href="https://admin.equipmentshare.com/#/home/transactions/invoices/{{invoice_id._value}}" target="_blank">{{value}}</a> ;;
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }

  dimension: customer_name {
    type: string
    html: {% if legal_audit_flag._value == 'true' %}
          <p style="color:tomato">
          {% else %}
          <p>
          {% endif %}
          {{value}}</p>
          ;;
    description: "Orange indicates a customer sent to legal/collections"
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: salesperson {
    type: string
    sql: ${TABLE}."SALESPERSON" ;;
  }

  dimension: amount {
    type: number
    value_format_name: usd
    sql: ${TABLE}."AMOUNT" ;;
  }

  dimension: period_published {
    label: "Plexi Period Published"
    type: string
    sql: (select period_published from ${plexi_periods.SQL_TABLE_NAME} where display = {% parameter report_period %}) ;;
  }

  dimension: legal_audit_flag {
    type: string
    sql:${TABLE}."LEGAL_AUDIT_FLAG" ;;
  }

set: detail {
  fields: [
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
