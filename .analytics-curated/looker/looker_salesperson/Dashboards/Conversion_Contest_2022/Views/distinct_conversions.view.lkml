view: distinct_conversions {
  derived_table: {
    sql:
SELECT *
  FROM analytics.public.conversion_contest_2022
 WHERE is_valid = 'Yes'
 QUALIFY ROW_NUMBER() OVER (PARTITION BY company_id ORDER BY invoice_billing_approved_date) = 1
;;
  }

  dimension: company_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."COMPANY_ID" ;;
  }
  dimension: company_created_date {
    type: date_time
    convert_tz: no
    sql: ${TABLE}."COMPANY_CREATED_DATE" ;;
  }
  dimension: invoice_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."INVOICE_ID" ;;
  }
  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  dimension: invoice_branch {
    type: number
    value_format_name: id
    sql: ${TABLE}."INVOICE_BRANCH" ;;
  }

  dimension: invoice_date_created {
    type: date_time
    convert_tz: no
    sql: ${TABLE}."INVOICE_DATE_CREATED" ;;
  }
  dimension_group: invoice_billing_approved_date {
    type: time
    timeframes: [
      date,
      month,
      week
    ]
    sql: ${TABLE}."INVOICE_BILLING_APPROVED_DATE" ;;
  }

  dimension: order_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."ORDER_ID" ;;
  }
  dimension: rental_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."RENTAL_ID" ;;
  }
  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: equipment_class {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS" ;;
  }
  dimension: rental_rates {
    type: string
    sql: ${TABLE}."ACTUAL_RATES" ;;
  }
  dimension: floor_rates {
    type: string
    sql: ${TABLE}."FLOOR_RATES" ;;
  }
  dimension: rate_tier {
    type: string
    sql: ${TABLE}."RATE_TIER_NAME" ;;
  }
  dimension: is_order_missing {
    # null if the order is not missing
    type: string
    sql: coalesce(${TABLE}."ORDER_MISSING", 'Has order') ;;
  }
  dimension: is_rental_missing {
    # null if the rental is not missing
    type: string
    sql: coalesce(${TABLE}."RENTAL_MISSING", 'Has rental') ;;
  }
  dimension: invoice_approved_over_30_days_later {
    # null if invoice was approved within 30 days of company creation
    type: string
    sql: ${TABLE}."INVOICE_APPROVED_OVER_30" ;;
  }
  dimension: rate_threshold_check {
    type: string
    sql: ${TABLE}."RATE_THRESHOLD" ;;
  }
  dimension: is_valid_invoice {
    type: string
    sql: ${TABLE}."IS_VALID" ;;
  }
  dimension: days_left_for_valid_invoice {
    type: string
    sql: ${TABLE}."DAYS_LEFT_TO_BILL"::string ;;
  }
  dimension: first_rep_id_at_company {
    # first sales rep that was on an invoice for this company
    type: number
    value_format_name: id
    sql: ${TABLE}."FIRST_REP_ID_AT_COMPANY" ;;
  }
  dimension: first_rep_at_company {
    # first sales rep that was on an invoice for this company
    type: string
    sql: ${TABLE}."FIRST_REP_AT_COMPANY" ;;
  }
  dimension: primary_rep_on_invoice {
    # sales rep that is on this particular invoice
    type: string
    sql: ${TABLE}."PRIMARY_REP_ON_INVOICE" ;;
  }

  dimension: is_sales_account {
    type: yesno
    sql: ${first_rep_at_company} ilike '% Sales%' ;;
  }

  # - - - - - MEASURES - - - - -

  measure: converted_companies {
    type: count_distinct
    sql: ${company_id} ;;
    filters: [is_valid_invoice: "Yes"]
    drill_fields: [
      companies.company_name_with_link_to_customer_dashboard,
      company_created_date,
      invoice_number,
      invoice_billing_approved_date_date,
      first_rep_at_company
    ]
  }

  measure: distinct_reps {
    type: count_distinct
    sql: ${first_rep_at_company} ;;
    drill_fields: [first_rep_at_company, converted_companies]
  }

  measure: distinct_companies {
    type: count_distinct
    sql: ${company_id} ;;
  }

  measure: num_missing_orders {
    type: count
    filters: [is_order_missing: "No order"]
    drill_fields: [
      companies.company_name_with_link_to_customer_dashboard,
      company_created_date]
  }

  measure: num_missing_rentals {
    type: count
    filters: [is_rental_missing: "No rental", is_order_missing: "Has order"]
    drill_fields: [
      companies.company_name_with_link_to_customer_dashboard,
      company_created_date,
      order_id
    ]
  }

  measure: num_unapproved_invoices {
    type: count
    filters: [rate_threshold_check: "No Approved Invoice", invoice_number: "-NULL"]
    drill_fields: [
      companies.company_name_with_link_to_customer_dashboard,
      company_created_date,
      order_id,
      rental_id,
      invoice_number,
      invoice_date_created,
      rate_threshold_check,
      invoice_approved_over_30_days_later,
      is_valid_invoice
    ]
  }

  measure: count {
    type: count
  }
}
