view: ar_aging_month_end_comparison {
  derived_table: {
    sql:
    SELECT *
FROM ANALYTICS.FINANCIAL_SYSTEMS.AR_AGING_HISTORY
WHERE AS_OF_DATE = {% date_end date_filter_latest %}
GROUP BY ALL

UNION

SELECT *
FROM ANALYTICS.FINANCIAL_SYSTEMS.AR_AGING_HISTORY
WHERE AS_OF_DATE = {% date_end date_filter_earliest %}
GROUP BY ALL;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: header_recordno {
    type: number
    sql: ${TABLE}."HEADER_RECORDNO" ;;
  }

  dimension: customer_id {
    type: string
    sql: ${TABLE}."CUSTOMER_ID" ;;
    bypass_suggest_restrictions: yes
  }

  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: address_line_1 {
    type: string
    sql: ${TABLE}."ADDRESS_LINE_1" ;;
  }

  dimension: address_line_2 {
    type: string
    sql: ${TABLE}."ADDRESS_LINE_2" ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}."CITY" ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  dimension: zip {
    type: string
    sql: ${TABLE}."ZIP" ;;
  }

  dimension: do_not_rent {
    type: string
    sql: ${TABLE}."DO_NOT_RENT" ;;
  }

  dimension: post_date {
    type: date
    sql: ${TABLE}."POST_DATE" ;;
  }

  dimension_group: period {
    type: time
    view_label: "Period"
    timeframes: [
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.POST_DATE ;;
    convert_tz: no
  }

  dimension: document {
    type: string
    sql: ${TABLE}."DOCUMENT" ;;
  }

  dimension: due_date {
    type: date
    sql: ${TABLE}."DUE_DATE" ;;
  }

  dimension: age {
    type: number
    sql: ${TABLE}."AGE" ;;
  }

  dimension: record_id {
    type: string
    sql: ${TABLE}."RECORD_ID" ;;
  }

  dimension: ref_number {
    type: string
    sql: ${TABLE}."REF_NUMBER" ;;
  }

  dimension: pay_method {
    type: string
    sql: ${TABLE}."PAY_METHOD" ;;
  }

  dimension: record_type {
    type: string
    sql: ${TABLE}."RECORD_TYPE" ;;
  }

  dimension: detail_recordno {
    type: number
    sql: ${TABLE}."DETAIL_RECORDNO" ;;
  }

  dimension: entity {
    type: string
    sql: ${TABLE}."ENTITY" ;;
  }

  dimension: account {
    type: string
    sql: ${TABLE}."ACCOUNT" ;;
  }

  dimension: account_name {
    type: string
    sql: ${TABLE}."ACCOUNT_NAME" ;;
  }

  dimension: account_nb {
    type: string
    sql: ${TABLE}."ACCOUNT_NB" ;;
  }

  dimension: account_type {
    type: string
    sql: ${TABLE}."ACCOUNT_TYPE" ;;
  }

  dimension: account_ct {
    type: string
    sql: ${TABLE}."ACCOUNT_CT" ;;
  }

  dimension: account_status {
    type: string
    sql: ${TABLE}."ACCOUNT_STATUS" ;;
  }

  dimension: dept_id {
    type: string
    sql: ${TABLE}."DEPT_ID" ;;
  }

  dimension: dept_name {
    type: string
    sql: ${TABLE}."DEPT_NAME" ;;
  }

  measure: orig_amount {
    type: sum
    sql: ${TABLE}."ORIG_AMOUNT" ;;
  }

  measure: amt_invoice {
    type: sum
    sql: ${TABLE}."AMT_INVOICE" ;;
  }

  measure: amt_advance {
    type: sum
    sql: ${TABLE}."AMT_ADVANCE" ;;
  }

  measure: amt_overpayment {
    type: sum
    sql: ${TABLE}."AMT_OVERPAYMENT" ;;
  }

  measure: amt_arpayment {
    type: sum
    sql: ${TABLE}."AMT_ARPAYMENT" ;;
  }

  measure: amt_aradjustment {
    type: sum
    sql: ${TABLE}."AMT_ARADJUSTMENT" ;;
  }

  measure: amt_paid {
    type: sum
    sql: ${TABLE}."AMT_PAID" ;;
  }

  measure: amt_cm_applied {
    type: sum
    sql: ${TABLE}."AMT_CM_APPLIED" ;;
  }

  measure: payment_applied {
    type: sum
    sql: ${TABLE}."PAYMENT_APPLIED" ;;
  }

  measure: payment_pay_applied {
    type: sum
    sql: ${TABLE}."PAYMENT_PAY_APPLIED" ;;
  }

  measure: payment_write_off_applied {
    type: sum
    sql: ${TABLE}."PAYMENT_WRITE_OFF_APPLIED" ;;
  }

  measure: net_payment {
    type: sum
    sql: ${TABLE}."NET_PAYMENT" ;;
  }

  measure: balance {
    type: sum
    sql: ${TABLE}."BALANCE" ;;
  }

  measure: a_0_or_less {
    type: sum
    sql: ${TABLE}."A_0_OR_LESS" ;;
  }

  measure: a_1_to_30 {
    type: sum
    sql: ${TABLE}."A_1_TO_30" ;;
  }

  measure: a_31_to_60 {
    type: sum
    sql: ${TABLE}."A_31_TO_60" ;;
  }

  measure: a_61_to_90 {
    type: sum
    sql: ${TABLE}."A_61_TO_90" ;;
  }

  measure: a_91_to_120 {
    type: sum
    sql: ${TABLE}."A_91_TO_120" ;;
  }

  measure: a_121_and_up {
    type: sum
    sql: ${TABLE}."A_121_AND_UP" ;;
  }

  dimension: collector {
    type: string
    sql: ${TABLE}."COLLECTOR" ;;
    bypass_suggest_restrictions: yes
  }

  dimension: market {
    type: string
    sql: ${TABLE}."MARKET" ;;
  }

  dimension: district_id {
    type: string
    sql: ${TABLE}."DISTRICT_ID" ;;
  }

  dimension: district_name {
    type: string
    sql: ${TABLE}."DISTRICT_NAME" ;;
  }

  dimension: region_id {
    type: string
    sql: ${TABLE}."REGION_ID" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: pay_terms {
    type: string
    sql: ${TABLE}."PAY_TERMS" ;;
  }

  measure: total_past_due {
    type: sum
    sql: ${TABLE}."TOTAL_PAST_DUE" ;;
  }

  dimension: escheatment {
    type: string
    sql: ${TABLE}."ESCHEATMENT" ;;
  }

  dimension: as_of_date {
    type: date
    sql: ${TABLE}."AS_OF_DATE" ;;
  }

  measure: net_rev {
    type: sum
    sql: ${TABLE}."NET_REV" ;;
  }


  set: detail {
    fields: [
      header_recordno,
      customer_id,
      customer_name,
      address_line_1,
      address_line_2,
      city,
      state,
      zip,
      do_not_rent,
      post_date,
      period_month,
      period_year,
      period_quarter,
      document,
      due_date,
      age,
      record_id,
      ref_number,
      pay_method,
      record_type,
      detail_recordno,
      entity,
      account,
      account_name,
      account_nb,
      account_type,
      account_ct,
      account_status,
      dept_id,
      dept_name,
      orig_amount,
      amt_invoice,
      amt_advance,
      amt_overpayment,
      amt_arpayment,
      amt_aradjustment,
      amt_paid,
      amt_cm_applied,
      payment_applied,
      payment_pay_applied,
      payment_write_off_applied,
      net_payment,
      balance,
      a_0_or_less,
      a_1_to_30,
      a_31_to_60,
      a_61_to_90,
      a_91_to_120,
      a_121_and_up,
      collector,
      market,
      district_id,
      district_name,
      region_id,
      region_name,
      pay_terms,
      total_past_due,
      escheatment,
      as_of_date,
      net_rev
    ]
  }

  filter: date_filter_earliest {
    type: date
  }

  filter: date_filter_latest {
    type: date
  }

  filter: collector_filter {
    type: string
  }
}

#
#   # Define your dimensions and measures here, like this:
#   dimension: user_id {
#     description: "Unique ID for each user that has ordered"
#     type: number
#     sql: ${TABLE}.user_id ;;
#   }
#
#   dimension: lifetime_orders {
#     description: "The total number of orders for each user"
#     type: number
#     sql: ${TABLE}.lifetime_orders ;;
#   }
#
#   dimension_group: most_recent_purchase {
#     description: "The date when each user last ordered"
#     type: time
#     timeframes: [date, week, month, year]
#     sql: ${TABLE}.most_recent_purchase_at ;;
#   }
#
#   measure: total_lifetime_orders {
#     description: "Use this for counting lifetime orders across many users"
#     type: sum
#     sql: ${lifetime_orders} ;;
#   }
# }
