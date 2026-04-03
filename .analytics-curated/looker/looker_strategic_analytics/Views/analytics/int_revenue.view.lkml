
view: int_revenue {
  sql_table_name: analytics.intacct_models.int_revenue ;;


  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: invoice_id {
    type: string
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }

  dimension: credit_note_id {
    type: string
    sql: ${TABLE}."CREDIT_NOTE_ID" ;;
  }

  dimension: credit_note_number {
    type: string
    sql: ${TABLE}."CREDIT_NOTE_NUMBER" ;;
  }

  dimension: avalara_transaction_id {
    type: string
    sql: ${TABLE}."AVALARA_TRANSACTION_ID" ;;
  }

  dimension_group: gl_date {
    type: time
    sql: ${TABLE}."GL_DATE" ;;
  }

  dimension_group: billing_approved_date {
    type: time
    sql: ${TABLE}."BILLING_APPROVED_DATE" ;;
  }

  dimension: is_billing_approved {
    type: yesno
    sql: ${TABLE}."IS_BILLING_APPROVED" ;;
  }

  dimension_group: invoice_date {
    type: time
    sql: ${TABLE}."INVOICE_DATE" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: invoice_memo {
    type: string
    sql: ${TABLE}."INVOICE_MEMO" ;;
  }

  dimension_group: credit_note_date {
    type: time
    sql: ${TABLE}."CREDIT_NOTE_DATE" ;;
  }

  dimension: credit_note_status_id {
    type: string
    sql: ${TABLE}."CREDIT_NOTE_STATUS_ID" ;;
  }

  dimension: credit_note_status_name {
    type: string
    sql: ${TABLE}."CREDIT_NOTE_STATUS_NAME" ;;
  }

  dimension: credit_note_memo {
    type: string
    sql: ${TABLE}."CREDIT_NOTE_MEMO" ;;
  }

  dimension: credit_note_reference {
    type: string
    sql: ${TABLE}."CREDIT_NOTE_REFERENCE" ;;
  }

  dimension: is_credit_note_generated_from_invoice {
    type: yesno
    sql: ${TABLE}."IS_CREDIT_NOTE_GENERATED_FROM_INVOICE" ;;
  }

  dimension: line_item_id {
    type: string
    sql: ${TABLE}."LINE_ITEM_ID" ;;
  }

  dimension: line_item_type_id {
    type: string
    sql: ${TABLE}."LINE_ITEM_TYPE_ID" ;;
  }

  dimension: line_item_type_name {
    type: string
    sql: ${TABLE}."LINE_ITEM_TYPE_NAME" ;;
  }

  dimension: is_rental_revenue {
    type: yesno
    sql: ${TABLE}."IS_RENTAL_REVENUE" ;;
  }

  dimension: account_number {
    type: string
    sql: ${TABLE}."ACCOUNT_NUMBER" ;;
  }

  dimension: account_name {
    type: string
    sql: ${TABLE}."ACCOUNT_NAME" ;;
  }

  dimension: credit_note_line_item_id {
    type: string
    sql: ${TABLE}."CREDIT_NOTE_LINE_ITEM_ID" ;;
  }

  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
    value_format_name: usd
  }

  measure: amount_sum {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd
  }

  dimension: tax_amount {
    type: number
    sql: ${TABLE}."TAX_AMOUNT" ;;
    value_format_name: usd
  }

  measure: tax_amount_sum {
    type: sum
    sql: ${tax_amount} ;;
    value_format_name: usd
  }

  dimension: is_taxable {
    type: yesno
    sql: ${TABLE}."IS_TAXABLE" ;;
  }

  dimension: line_item_description {
    type: string
    sql: ${TABLE}."LINE_ITEM_DESCRIPTION" ;;
  }

  dimension_group: header_date_created {
    type: time
    sql: ${TABLE}."HEADER_DATE_CREATED" ;;
  }

  dimension_group: header_date_updated {
    type: time
    sql: ${TABLE}."HEADER_DATE_UPDATED" ;;
  }

  dimension_group: line_item_date_created {
    type: time
    sql: ${TABLE}."LINE_ITEM_DATE_CREATED" ;;
  }

  dimension_group: line_item_date_updated {
    type: time
    sql: ${TABLE}."LINE_ITEM_DATE_UPDATED" ;;
  }

  dimension: asset_id {
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: rental_id {
    type: string
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension_group: invoice_cycle_start_date {
    type: time
    sql: ${TABLE}."INVOICE_CYCLE_START_DATE" ;;
  }

  dimension_group: invoice_cycle_end_date {
    type: time
    sql: ${TABLE}."INVOICE_CYCLE_END_DATE" ;;
  }

  dimension: rental_bill_type {
    type: string
    sql: ${TABLE}."RENTAL_BILL_TYPE" ;;
  }

  dimension: rental_cheapest_period_hour_count {
    type: number
    sql: ${TABLE}."RENTAL_CHEAPEST_PERIOD_HOUR_COUNT" ;;
  }

  dimension: rental_cheapest_period_day_count {
    type: number
    sql: ${TABLE}."RENTAL_CHEAPEST_PERIOD_DAY_COUNT" ;;
  }

  dimension: rental_cheapest_period_week_count {
    type: number
    sql: ${TABLE}."RENTAL_CHEAPEST_PERIOD_WEEK_COUNT" ;;
  }

  dimension: rental_cheapest_period_four_week_count {
    type: number
    sql: ${TABLE}."RENTAL_CHEAPEST_PERIOD_FOUR_WEEK_COUNT" ;;
  }

  dimension: rental_cheapest_period_month_count {
    type: number
    sql: ${TABLE}."RENTAL_CHEAPEST_PERIOD_MONTH_COUNT" ;;
  }

  dimension: rental_price_per_hour {
    type: string
    sql: ${TABLE}."RENTAL_PRICE_PER_HOUR" ;;
    value_format_name: usd
  }

  dimension: rental_price_per_day {
    type: string
    sql: ${TABLE}."RENTAL_PRICE_PER_DAY" ;;
    value_format_name: usd
  }

  dimension: rental_price_per_week {
    type: string
    sql: ${TABLE}."RENTAL_PRICE_PER_WEEK" ;;
    value_format_name: usd
  }

  dimension: rental_price_per_four_weeks {
    type: string
    sql: ${TABLE}."RENTAL_PRICE_PER_FOUR_WEEKS" ;;
    value_format_name: usd
  }

  dimension: rental_price_per_month {
    type: string
    sql: ${TABLE}."RENTAL_PRICE_PER_MONTH" ;;
    value_format_name: usd
  }

  dimension: is_intercompany {
    type: yesno
    sql: ${TABLE}."IS_INTERCOMPANY" ;;
  }

  dimension: line_item_market_id {
    type: string
    sql: ${TABLE}."LINE_ITEM_MARKET_ID" ;;
  }

  dimension: primary_salesperson_id {
    type: string
    sql: ${TABLE}."PRIMARY_SALESPERSON_ID" ;;
  }

  dimension: secondary_salesperson_ids {
    type: string
    sql: ${TABLE}."SECONDARY_SALESPERSON_IDS" ;;
  }

  dimension_group: paid_date {
    type: time
    sql: ${TABLE}."PAID_DATE" ;;
  }

  dimension: url_invoice_admin {
    type: string
    sql: ${TABLE}."URL_INVOICE_ADMIN" ;;
  }

  dimension: url_credit_note_admin {
    type: string
    sql: ${TABLE}."URL_CREDIT_NOTE_ADMIN" ;;
  }

  dimension: src {
    type: string
    sql: ${TABLE}."SRC" ;;
  }

  dimension: ship_to_branch_id {
    type: string
    sql: ${TABLE}."SHIP_TO_BRANCH_ID" ;;
  }

  dimension: ship_to_location_id {
    type: string
    sql: ${TABLE}."SHIP_TO_LOCATION_ID" ;;
  }

  dimension: ship_to_nickname {
    type: string
    sql: ${TABLE}."SHIP_TO_NICKNAME" ;;
  }

  dimension: ship_to_country {
    type: string
    sql: ${TABLE}."SHIP_TO_COUNTRY" ;;
  }

  dimension: ship_to_state {
    type: string
    sql: ${TABLE}."SHIP_TO_STATE" ;;
  }

  dimension: ship_to_city {
    type: string
    sql: ${TABLE}."SHIP_TO_CITY" ;;
  }

  dimension: ship_to_street {
    type: string
    sql: ${TABLE}."SHIP_TO_STREET" ;;
  }

  dimension: ship_to_zip_code {
    type: string
    sql: ${TABLE}."SHIP_TO_ZIP_CODE" ;;
  }

  dimension: ship_to_longitude {
    type: string
    sql: ${TABLE}."SHIP_TO_LONGITUDE" ;;
  }

  dimension: ship_to_latitude {
    type: string
    sql: ${TABLE}."SHIP_TO_LATITUDE" ;;
  }

  dimension: ship_from_branch_id {
    type: number
    sql: ${TABLE}."SHIP_FROM_BRANCH_ID" ;;
  }

  dimension: ship_from_location_id {
    type: string
    sql: ${TABLE}."SHIP_FROM_LOCATION_ID" ;;
  }

  dimension: ship_from_nickname {
    type: string
    sql: ${TABLE}."SHIP_FROM_NICKNAME" ;;
  }

  dimension: ship_from_country {
    type: string
    sql: ${TABLE}."SHIP_FROM_COUNTRY" ;;
  }

  dimension: ship_from_state {
    type: string
    sql: ${TABLE}."SHIP_FROM_STATE" ;;
  }

  dimension: ship_from_city {
    type: string
    sql: ${TABLE}."SHIP_FROM_CITY" ;;
  }

  dimension: ship_from_street {
    type: string
    sql: ${TABLE}."SHIP_FROM_STREET" ;;
  }

  dimension: ship_from_zip_code {
    type: string
    sql: ${TABLE}."SHIP_FROM_ZIP_CODE" ;;
  }

  dimension: ship_from_longitude {
    type: string
    sql: ${TABLE}."SHIP_FROM_LONGITUDE" ;;
  }

  dimension: ship_from_latitude {
    type: string
    sql: ${TABLE}."SHIP_FROM_LATITUDE" ;;
  }

  set: detail {
    fields: [
        invoice_id,
  invoice_number,
  credit_note_id,
  credit_note_number,
  avalara_transaction_id,
  gl_date_time,
  billing_approved_date_time,
  is_billing_approved,
  invoice_date_time,
  market_id,
  market_name,
  company_id,
  customer_name,
  invoice_memo,
  credit_note_date_time,
  credit_note_status_id,
  credit_note_status_name,
  credit_note_memo,
  credit_note_reference,
  is_credit_note_generated_from_invoice,
  line_item_id,
  line_item_type_id,
  line_item_type_name,
  is_rental_revenue,
  account_number,
  account_name,
  credit_note_line_item_id,
  amount,
  tax_amount,
  is_taxable,
  line_item_description,
  header_date_created_time,
  header_date_updated_time,
  line_item_date_created_time,
  line_item_date_updated_time,
  asset_id,
  rental_id,
  invoice_cycle_start_date_time,
  invoice_cycle_end_date_time,
  rental_bill_type,
  rental_cheapest_period_hour_count,
  rental_cheapest_period_day_count,
  rental_cheapest_period_week_count,
  rental_cheapest_period_four_week_count,
  rental_cheapest_period_month_count,
  rental_price_per_hour,
  rental_price_per_day,
  rental_price_per_week,
  rental_price_per_four_weeks,
  rental_price_per_month,
  is_intercompany,
  line_item_market_id,
  primary_salesperson_id,
  secondary_salesperson_ids,
  paid_date_time,
  url_invoice_admin,
  url_credit_note_admin,
  src,
  ship_to_branch_id,
  ship_to_location_id,
  ship_to_nickname,
  ship_to_country,
  ship_to_state,
  ship_to_city,
  ship_to_street,
  ship_to_zip_code,
  ship_to_longitude,
  ship_to_latitude,
  ship_from_branch_id,
  ship_from_location_id,
  ship_from_nickname,
  ship_from_country,
  ship_from_state,
  ship_from_city,
  ship_from_street,
  ship_from_zip_code,
  ship_from_longitude,
  ship_from_latitude
    ]
  }
}
