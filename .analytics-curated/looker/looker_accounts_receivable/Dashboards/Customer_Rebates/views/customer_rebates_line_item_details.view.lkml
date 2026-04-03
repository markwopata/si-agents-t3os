view: customer_rebates_line_item_details {
  sql_table_name: "RATE_ACHIEVEMENT"."CUSTOMER_REBATES_LINE_ITEM_DETAILS" ;;

  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
    value_format_name: usd_0
  }
  dimension_group: billing_approved {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."BILLING_APPROVED_DATE" ;;
  }
  dimension: billing_type {
    type: string
    sql: ${TABLE}."BILLING_TYPE" ;;
  }
  dimension: billing_type_extended {
    type: string
    sql: ${TABLE}."BILLING_TYPE_EXTENDED" ;;
  }
  dimension: branch {
    type: string
    sql: ${TABLE}."BRANCH" ;;
  }
  dimension: branch_id {
    type: string
    sql: ${TABLE}."BRANCH_ID" ;;
    value_format_name: id
  }
  dimension_group: contract_expiration {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."CONTRACT_EXPIRATION_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: credit_note_line_item_id {
    type: number
    sql: ${TABLE}."CREDIT_NOTE_LINE_ITEM_ID" ;;
    value_format_name: id
  }
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
  dimension_group: cutover {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."CUTOVER_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: cycle_length {
    type: number
    sql: ${TABLE}."CYCLE_LENGTH" ;;
  }
  dimension: cycles {
    type: string
    sql: ${TABLE}."CYCLES" ;;
  }
  dimension: daily_billing_flag {
    type: yesno
    sql: ${TABLE}."DAILY_BILLING_FLAG" ;;
  }
  dimension: days {
    type: string
    sql: ${TABLE}."DAYS" ;;
  }
  dimension_group: effective_start {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."EFFECTIVE_START_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: expected_total {
    type: number
    sql: ${TABLE}."EXPECTED_TOTAL" ;;
    value_format_name: usd_0
  }
  dimension_group: four_week_billing {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."FOUR_WEEK_BILLING_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: four_weeks {
    type: string
    sql: ${TABLE}."FOUR_WEEKS" ;;
  }
  dimension: group_name {
    type: string
    sql: ${TABLE}."GROUP_NAME" ;;
  }
  dimension: hours {
    type: string
    sql: ${TABLE}."HOURS" ;;
  }
  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
    value_format_name: id
  }
  dimension: is_paid_on_time {
    type: yesno
    sql: ${TABLE}."IS_PAID_ON_TIME" ;;
    html:

    {% if value == 'No' %}

    <p style="color: black; background-color: rgb(179, 47, 55); font-size:100%; text-align:center">{{ rendered_value }}</p>

    {% else %}

    <p style="color: black; font-size:100%; text-align:center">{{ rendered_value }}</p>

    {% endif %}
    ;;
  }
  dimension: is_rebate_eligible {
    type: yesno
    sql: ${TABLE}."IS_REBATE_ELIGIBLE" ;;
    html:

    {% if value == 'No' %}

    <p style="color: black; background-color: rgb(179, 47, 55); font-size:100%; text-align:center">{{ rendered_value }}</p>

    {% else %}

    <p style="color: black; font-size:100%; text-align:center">{{ rendered_value }}</p>

    {% endif %}
    ;;
  }
  dimension: is_valid_rate {
    type: yesno
    sql: ${TABLE}."IS_VALID_RATE" ;;
    html:

    {% if value == 'No' %}

    <p style="color: black; background-color: rgb(179, 47, 55); font-size:100%; text-align:center">{{ rendered_value }}</p>

    {% else %}

    <p style="color: black; font-size:100%; text-align:center">{{ rendered_value }}</p>

    {% endif %}
    ;;
  }
  dimension: is_valid_rate_calc {
    type: yesno
    sql: ${TABLE}."IS_VALID_RATE_CALC" ;;
  }
  dimension: line_item_id {
    type: number
    sql: ${TABLE}."LINE_ITEM_ID" ;;
    value_format_name: id
  }
  dimension: max_rebate_amount_possible {
    type: number
    sql: ${TABLE}."MAX_REBATE_AMOUNT_POSSIBLE" ;;
    value_format_name: usd_0
  }
  dimension: max_rebate_percent_possible {
    type: number
    sql: ${TABLE}."MAX_REBATE_PERCENT_POSSIBLE" ;;
    value_format_name: percent_0
  }
  dimension: months {
    type: string
    sql: ${TABLE}."MONTHS" ;;
  }
  dimension_group: order_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."ORDER_CREATED_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: order_date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."ORDER_DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: paid {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."PAID_DATE" ;;
  }
  dimension: paid_date_diff {
    type: number
    sql: ${TABLE}."PAID_DATE_DIFF" ;;
  }
  dimension: paid_in_days {
    type: number
    sql: ${TABLE}."PAID_IN_DAYS" ;;
  }
  dimension: rebate_amount_achieved {
    type: number
    sql: ${TABLE}."REBATE_AMOUNT_ACHIEVED" ;;
    value_format_name: usd_0
  }
  dimension: rebate_amount_potential {
    type: number
    sql: ${TABLE}."REBATE_AMOUNT_POTENTIAL" ;;
    value_format_name: usd_0
  }
  dimension: rebate_eligible_amount {
    type: number
    sql: ${TABLE}."REBATE_ELIGIBLE_AMOUNT" ;;
    value_format_name: usd_0
  }
  dimension_group: rebate_end_period {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."REBATE_END_PERIOD" ;;
  }
  dimension: rebate_percent_achieved {
    type: number
    sql: ${TABLE}."REBATE_PERCENT_ACHIEVED" ;;
    value_format_name: percent_0
  }
  dimension: rebate_percent_potential {
    type: number
    sql: ${TABLE}."REBATE_PERCENT_POTENTIAL" ;;
    value_format_name: percent_0
  }
  dimension_group: rebate_start_period {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."REBATE_START_PERIOD" ;;
  }
  dimension: rental_billing_cycle_strategy {
    type: string
    sql: ${TABLE}."RENTAL_BILLING_CYCLE_STRATEGY" ;;
  }
  dimension: rental_class {
    type: number
    sql: ${TABLE}."RENTAL_CLASS" ;;
  }
  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
    value_format_name: id
  }
  dimension: revenue_difference {
    type: number
    sql: ${TABLE}."REVENUE_DIFFERENCE" ;;
  }
  dimension: salesperson_id {
    type: number
    sql: ${TABLE}."SALESPERSON_ID" ;;
    value_format_name: id
  }
  dimension: salesperson_name {
    type: string
    sql: ${TABLE}."SALESPERSON_NAME" ;;
  }
  dimension: weeks {
    type: string
    sql: ${TABLE}."WEEKS" ;;
  }
  dimension: first_revenue_tier {
    type: number
    sql: ${TABLE}."FIRST_REVENUE_TIER" ;;
    value_format_name: usd_0
  }
  dimension: line_item_credit_note_pk {
    primary_key: yes
    hidden: yes
    type: string
    sql: CONCAT(${line_item_id}, '-', ${credit_note_line_item_id}) ;;
  }
  dimension: is_current_rebate {
    type: yesno
    sql: CURRENT_DATE() BETWEEN ${rebate_start_period_date} AND ${rebate_end_period_date} ;;
  }
  measure: count {
    type: count
    drill_fields: [group_name, customer_name, salesperson_name]
  }
}
