view: payments {
   derived_table: {
    # datagroup_trigger: Every_Two_Hours_Update
    sql:
select
company_id
,sum(amount) as amount
,sum(amount_remaining) as amount_remaining
from es_warehouse.public.payments
group by company_id
order by amount_remaining desc
 ;;
  }

  # dimension: payment_id {
  #   primary_key: yes
  #   type: number
  #   sql: ${TABLE}."PAYMENT_ID" ;;
  # }

  # dimension_group: _es_update_timestamp {
  #   type: time
  #   timeframes: [
  #     raw,
  #     time,
  #     date,
  #     week,
  #     month,
  #     quarter,
  #     year
  #   ]
  #   sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  # }

  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
  }

  dimension: amount_remaining {
    type: number
    sql: ${TABLE}."AMOUNT_REMAINING" ;;
  }

  # dimension: bank_account_id {
  #   type: number
  #   sql: ${TABLE}."BANK_ACCOUNT_ID" ;;
  # }

  # dimension: branch_id {
  #   type: number
  #   sql: ${TABLE}."BRANCH_ID" ;;
  # }

  # dimension: check_number {
  #   type: string
  #   sql: ${TABLE}."CHECK_NUMBER" ;;
  # }

  dimension: company_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  # dimension: created_by_user_id {
  #   type: number
  #   sql: ${TABLE}."CREATED_BY_USER_ID" ;;
  # }

  # dimension_group: date_created {
  #   type: time
  #   timeframes: [
  #     raw,
  #     time,
  #     date,
  #     week,
  #     month,
  #     quarter,
  #     year
  #   ]
  #   sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  # }

  # dimension: invoice_id {
  #   type: number
  #   sql: ${TABLE}."INVOICE_ID" ;;
  # }

  # dimension: order_id {
  #   type: number
  #   sql: ${TABLE}."ORDER_ID" ;;
  # }

  # dimension_group: payment {
  #   type: time
  #   timeframes: [
  #     raw,
  #     time,
  #     date,
  #     week,
  #     month,
  #     quarter,
  #     year
  #   ]
  #   sql: CAST(${TABLE}."PAYMENT_DATE" AS TIMESTAMP_NTZ) ;;
  # }

  # dimension: payment_method_id {
  #   type: number
  #   sql: ${TABLE}."PAYMENT_METHOD_ID" ;;
  # }

  # dimension: payment_method_type_id {
  #   type: number
  #   sql: ${TABLE}."PAYMENT_METHOD_TYPE_ID" ;;
  # }

  # dimension: reference {
  #   type: string
  #   sql: ${TABLE}."REFERENCE" ;;
  # }

  # dimension: result {
  #   type: string
  #   sql: ${TABLE}."RESULT" ;;
  # }

  # dimension: status {
  #   type: number
  #   sql: ${TABLE}."STATUS" ;;
  # }

  # dimension: stripe_id {
  #   type: string
  #   sql: ${TABLE}."STRIPE_ID" ;;
  # }

  # dimension: user_id {
  #   type: number
  #   sql: ${TABLE}."USER_ID" ;;
  # }

  # dimension: xero_id {
  #   type: string
  #   sql: ${TABLE}."XERO_ID" ;;
  # }

  # dimension: days_from_today_to_date_created {
  #   type:  number
  #   sql:  datediff(day,${date_created_raw},current_timestamp()) ;;
  #   # DATE_PART('day',current_timestamp()-${date_created_raw}::timestamp) ;;
  # }

  measure: Total_Pre_Overpayment_Amount {
    type: sum
    sql: ${amount_remaining} ;;
    filters: [amount_remaining: ">0"]
    value_format_name: usd
    drill_fields: [detail*]
  }

  set: detail {
    fields: [
      companies.name,
      Total_Pre_Overpayment_Amount
    ]
  }
  measure: count {
    type: count
    drill_fields: [payment_applications.count, payment_erp_refs.count]
  }
}
