view: commission_details {
  sql_table_name: "ANALYTICS"."COMMISSION_DBT"."COMMISSION_FINAL_ALL" ;;

  dimension: allocation_cost_center {
    type: string
    sql: ${TABLE}."ALLOCATION_COST_CENTER" ;;
  }
  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: benchmark_rate {
    type: number
    sql: ${TABLE}."BENCHMARK_RATE" ;;
  }
  dimension: billing_approved {
    type: date_raw
    sql: ${TABLE}."BILLING_APPROVED_DATE";;
    hidden: yes
  }
  dimension: book_rate {
    type: number
    sql: ${TABLE}."BOOK_RATE" ;;
  }
  dimension: business_segment_id {
    type: number
    sql: ${TABLE}."BUSINESS_SEGMENT_ID" ;;
  }
  dimension: cheapest_period {
    type: string
    sql: ${TABLE}."CHEAPEST_PERIOD" ;;
  }
  dimension: comments {
    type: string
    sql: ${TABLE}."COMMENTS" ;;
  }
  dimension: commission_amount {
    type: number
    sql: ${TABLE}."COMMISSION_AMOUNT" ;;
  }
  dimension: commission_id {
    type: string
    sql: ${TABLE}."COMMISSION_ID" ;;
  }
  dimension: commission_month {
    type: date_raw
    sql: ${TABLE}."COMMISSION_MONTH" ;;
    hidden: yes
  }
  dimension: commission_rate {
    type: number
    sql: ${TABLE}."COMMISSION_RATE" ;;
  }
  dimension: commission_type_id {
    type: number
    sql: ${TABLE}."COMMISSION_TYPE_ID" ;;
  }
  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }
  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }
  dimension: credit_note_line_item_id {
    type: number
    sql: ${TABLE}."CREDIT_NOTE_LINE_ITEM_ID" ;;
  }
  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }
  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }
  dimension: email_address {
    type: string
    sql: ${TABLE}."EMAIL_ADDRESS" ;;
  }
  dimension: employee_id {
    type: string
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }
  dimension: employee_manager {
    type: string
    sql: ${TABLE}."EMPLOYEE_MANAGER" ;;
  }
  dimension: employee_manager_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_MANAGER_ID" ;;
  }
  dimension: employee_title {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }
  dimension: employee_type {
    type: string
    sql: ${TABLE}."EMPLOYEE_TYPE" ;;
  }
  dimension: floor_rate {
    type: number
    sql: ${TABLE}."FLOOR_RATE" ;;
  }
  dimension: full_name {
    type: string
    sql: ${TABLE}."FULL_NAME" ;;
  }
  dimension: hidden {
    type: yesno
    sql: ${TABLE}."HIDDEN" ;;
  }
  dimension: invoice_asset_make {
    type: string
    sql: ${TABLE}."INVOICE_ASSET_MAKE" ;;
  }
  dimension: invoice_class {
    type: string
    sql: ${TABLE}."INVOICE_CLASS" ;;
  }
  dimension: invoice_class_id {
    type: number
    sql: ${TABLE}."INVOICE_CLASS_ID" ;;
  }
  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
  }
  dimension: invoice_no {
    type: string
    sql: ${TABLE}."INVOICE_NO" ;;
  }
  dimension: is_exception {
    type: yesno
    sql: ${TABLE}."IS_EXCEPTION" ;;
  }
  dimension: is_override {
    type: yesno
    sql: ${TABLE}."IS_OVERRIDE" ;;
  }
  dimension: is_payable {
    type: yesno
    sql: ${TABLE}."IS_PAYABLE" ;;
  }
  dimension: line_item_amount {
    type: number
    sql: ${TABLE}."LINE_ITEM_AMOUNT" ;;
  }
  dimension: line_item_id {
    type: number
    sql: ${TABLE}."LINE_ITEM_ID" ;;
  }
  dimension: line_item_type {
    type: string
    sql: ${TABLE}."LINE_ITEM_TYPE" ;;
  }
  dimension: line_item_type_id {
    type: number
    sql: ${TABLE}."LINE_ITEM_TYPE_ID" ;;
  }
  dimension: manual_adjustment_id {
    type: number
    sql: ${TABLE}."MANUAL_ADJUSTMENT_ID" ;;
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }
  dimension: order {
    type: date_raw
    sql: ${TABLE}."ORDER_DATE" ;;
    hidden: yes
  }
  dimension: order_id {
    type: number
    sql: ${TABLE}."ORDER_ID" ;;
  }
  dimension: override_rate {
    type: number
    sql: ${TABLE}."OVERRIDE_RATE" ;;
  }
  dimension: parent_market_id {
    type: number
    sql: ${TABLE}."PARENT_MARKET_ID" ;;
  }
  dimension: parent_market_name {
    type: string
    sql: ${TABLE}."PARENT_MARKET_NAME" ;;
  }
  dimension: paycheck {
    type: date_raw
    sql: ${TABLE}."PAYCHECK_DATE" ;;
    hidden: yes
  }
  dimension: quoted_rates {
    type: string
    sql: ${TABLE}."QUOTED_RATES" ;;
  }
  dimension: rate_tier_id {
    type: number
    sql: ${TABLE}."RATE_TIER_ID" ;;
  }
  dimension: rate_tier_name {
    type: string
    sql: ${TABLE}."RATE_TIER_NAME" ;;
  }
  dimension: region {
    type: number
    sql: ${TABLE}."REGION" ;;
  }
  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }
  dimension: reimbursement_factor {
    type: number
    sql: ${TABLE}."REIMBURSEMENT_FACTOR" ;;
  }
  dimension: rental_billed_days {
    type: number
    sql: ${TABLE}."RENTAL_BILLED_DAYS" ;;
  }
  dimension: rental_class_from_line_item {
    type: string
    sql: ${TABLE}."RENTAL_CLASS_FROM_LINE_ITEM" ;;
  }
  dimension: rental_class_id_from_rental {
    type: number
    value_format_name: id
    sql: ${TABLE}."RENTAL_CLASS_ID_FROM_RENTAL" ;;
  }
  dimension: rental_date_created {
    type: date_raw
    sql: ${TABLE}."RENTAL_DATE_CREATED" ;;
    hidden: yes
  }
  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
  }
  dimension: rental_start {
    type: date_raw
    sql: ${TABLE}."RENTAL_START_DATE";;
    hidden: yes
  }
  dimension: requester_full_name {
    type: string
    sql: ${TABLE}."REQUESTER_FULL_NAME" ;;
  }
  dimension: requester_id {
    type: number
    sql: ${TABLE}."REQUESTER_ID" ;;
  }
  dimension: salesperson_type {
    type: string
    sql: ${TABLE}."SALESPERSON_TYPE" ;;
  }
  dimension: salesperson_type_id {
    type: number
    sql: ${TABLE}."SALESPERSON_TYPE_ID" ;;
  }
  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }
  dimension: secondary_rep_count {
    type: number
    sql: ${TABLE}."SECONDARY_REP_COUNT" ;;
  }
  dimension: ship_to_state {
    type: string
    sql: ${TABLE}."SHIP_TO_STATE" ;;
  }
  dimension: split {
    type: number
    sql: ${TABLE}."SPLIT" ;;
  }
  dimension: submitted_by {
    type: string
    sql: ${TABLE}."SUBMITTED_BY" ;;
  }
  dimension: submitted {
    type: date_raw
    sql: ${TABLE}."SUBMITTED_DATE" ;;
    hidden: yes
  }
  dimension: transaction {
    type: date_raw
    sql: ${TABLE}."TRANSACTION_DATE" ;;
    hidden: yes
  }
  dimension: transaction_description {
    type: string
    sql: ${TABLE}."TRANSACTION_DESCRIPTION" ;;
  }
  dimension: transaction_type {
    type: string
    sql: ${TABLE}."TRANSACTION_TYPE" ;;
  }
  dimension: transaction_type_id {
    type: number
    sql: ${TABLE}."TRANSACTION_TYPE_ID" ;;
  }
  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
  company_name,
  market_name,
  parent_market_name,
  requester_full_name,
  full_name,
  region_name,
  rate_tier_name
  ]
  }

}
