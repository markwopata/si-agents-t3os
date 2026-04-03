view: customer_rebate_agreements {
  sql_table_name: "RATE_ACHIEVEMENT"."CUSTOMER_REBATE_AGREEMENTS" ;;

  dimension: customer_id {
    type: number
    sql: ${TABLE}."CUSTOMER_ID" ;;
    value_format_name: id
  }
  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }
  dimension: customer_specific_rates {
    type: string
    sql: ${TABLE}."CUSTOMER_SPECIFIC_RATES" ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_CREATED" ;;
  }
  dimension: days_to_pay_with_grace_period {
    type: number
    sql: ${TABLE}."DAYS_TO_PAY_WITH_GRACE_PERIOD" ;;
  }
  dimension: grace_period {
    type: number
    sql: ${TABLE}."GRACE_PERIOD" ;;
  }
  dimension: is_retroactive {
    type: yesno
    sql: ${TABLE}."IS_RETROACTIVE" ;;
    html:

    {% if value == 'No' %}

    <p style="color: black; background-color: rgb(179, 47, 55); font-size:100%; text-align:center">{{ rendered_value }}</p>

    {% else %}

    <p style="color: black; font-size:100%; text-align:center">{{ rendered_value }}</p>

    {% endif %}
    ;;
  }
  dimension: parent_company_id {
    type: number
    sql: ${TABLE}."PARENT_COMPANY_ID" ;;
    value_format_name: id
  }
  dimension: parent_company_name {
    type: string
    sql: ${TABLE}."PARENT_COMPANY_NAME" ;;
  }
  dimension: payment_terms {
    type: string
    sql: ${TABLE}."PAYMENT_TERMS" ;;
  }
  dimension_group: rebate_end_period {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."REBATE_END_PERIOD" ;;
  }
  dimension: rebate_paid {
    type: string
    sql: ${TABLE}."REBATE_PAID" ;;
  }
  dimension: rebate_paid_amount {
    type: number
    sql: ${TABLE}."REBATE_PAID_AMOUNT" ;;
    value_format_name: usd_0
  }
  dimension: rebate_percent {
    type: number
    sql: ${TABLE}."REBATE_PERCENT" ;;
    value_format_name: percent_0
  }
  dimension_group: rebate_start_period {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."REBATE_START_PERIOD" ;;
  }
  dimension: revenue_lower_bound {
    type: number
    sql: ${TABLE}."REVENUE_LOWER_BOUND" ;;
    value_format_name: usd_0
  }
  dimension: revenue_upper_bound {
    type: number
    sql: ${TABLE}."REVENUE_UPPER_BOUND" ;;
    value_format_name: usd_0
  }
  dimension: tier_number {
    type: number
    sql: ${TABLE}."TIER_NUMBER" ;;

  }
  dimension: is_current_rebate {
    type: yesno
    sql: CURRENT_DATE() BETWEEN ${rebate_start_period_date} AND ${rebate_end_period_date} ;;
  }
  measure: count {
    type: count
    drill_fields: [customer_name, parent_company_name]
  }
}
