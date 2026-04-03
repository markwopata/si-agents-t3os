view: int_admin_invoice_and_credit_line_detail {
  sql_table_name: "ANALYTICS"."INTACCT_MODELS"."INT_ADMIN_INVOICE_AND_CREDIT_LINE_DETAIL" ;;

  dimension: line_item_id {
    type: string
    sql: ${TABLE}."LINE_ITEM_ID" ;;
  }

  dimension: invoice_id {
    type: string
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: credit_note_id {
    type: string
    sql: ${TABLE}."CREDIT_NOTE_ID" ;;
  }

  dimension: credit_note_line_item_id {
    type: string
    sql: ${TABLE}."CREDIT_NOTE_LINE_ITEM_ID" ;;
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: line_item_market_id {
    type: string
    sql: ${TABLE}."LINE_ITEM_MARKET_ID" ;;
  }

  dimension: primary_salesperson_id {
    type: string
    sql: ${TABLE}."PRIMARY_SALESPERSON_ID" ;;
  }

  dimension: credit_note_status_id {
    type: string
    sql: ${TABLE}."CREDIT_NOTE_STATUS_ID" ;;
  }

  dimension: line_item_type_id {
    type: string
    sql: ${TABLE}."LINE_ITEM_TYPE_ID" ;;
  }

  dimension: ship_from_branch_id {
    type: string
    sql: ${TABLE}."SHIP_FROM_BRANCH_ID" ;;
  }

  dimension: asset_id {
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: rental_id {
    type: string
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: ship_to_location_id {
    type: string
    sql: ${TABLE}."SHIP_TO_LOCATION_ID" ;;
  }

  dimension: ship_from_location_id {
    type: string
    sql: ${TABLE}."SHIP_FROM_LOCATION_ID" ;;
  }

  dimension: ship_to_branch_id {
    type: string
    sql: ${TABLE}."SHIP_TO_BRANCH_ID" ;;
  }

  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
    value_format_name: usd
  }

  measure: total_amount {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd
  }

  dimension: tax_amount {
    type: number
    sql: ${TABLE}."TAX_AMOUNT" ;;
    value_format_name: usd
  }

  measure: total_tax_amount {
    type: sum
    sql: ${tax_amount} ;;
    value_format_name: usd
  }

  dimension: rental_price_per_week {
    type: string
    sql: ${TABLE}."RENTAL_PRICE_PER_WEEK" ;;
    value_format_name: usd
  }

  dimension: rental_price_per_day {
    type: string
    sql: ${TABLE}."RENTAL_PRICE_PER_DAY" ;;
    value_format_name: usd
  }

  dimension: rental_price_per_hour {
    type: string
    sql: ${TABLE}."RENTAL_PRICE_PER_HOUR" ;;
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

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }

  dimension: credit_note_number {
    type: string
    sql: ${TABLE}."CREDIT_NOTE_NUMBER" ;;
  }

  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: line_item_description {
    type: string
    sql: ${TABLE}."LINE_ITEM_DESCRIPTION" ;;
  }

  dimension: line_item_type_name {
    type: string
    sql: ${TABLE}."LINE_ITEM_TYPE_NAME" ;;
  }

  dimension: account_name {
    type: string
    sql: ${TABLE}."ACCOUNT_NAME" ;;
  }

  dimension: account_number {
    type: string
    sql: ${TABLE}."ACCOUNT_NUMBER" ;;
  }

  dimension: invoice_memo {
    type: string
    sql: ${TABLE}."INVOICE_MEMO" ;;
  }

  dimension: credit_note_memo {
    type: string
    sql: ${TABLE}."CREDIT_NOTE_MEMO" ;;
  }

  dimension: credit_note_reference {
    type: string
    sql: ${TABLE}."CREDIT_NOTE_REFERENCE" ;;
  }

  dimension: credit_note_status_name {
    type: string
    sql: ${TABLE}."CREDIT_NOTE_STATUS_NAME" ;;
  }

  dimension: url_invoice_admin {
    type: string
    sql: ${TABLE}."URL_INVOICE_ADMIN" ;;
  }

  dimension: url_credit_note_admin {
    type: string
    sql: ${TABLE}."URL_CREDIT_NOTE_ADMIN" ;;
  }

  dimension: avalara_transaction_id {
    type: string
    sql: ${TABLE}."AVALARA_TRANSACTION_ID" ;;
  }

  dimension: ship_from_street {
    type: string
    sql: ${TABLE}."SHIP_FROM_STREET" ;;
  }

  dimension: ship_from_city {
    type: string
    sql: ${TABLE}."SHIP_FROM_CITY" ;;
  }

  dimension: ship_from_state {
    type: string
    sql: ${TABLE}."SHIP_FROM_STATE" ;;
  }

  dimension: ship_from_zip_code {
    type: string
    sql: ${TABLE}."SHIP_FROM_ZIP_CODE" ;;
  }

  dimension: ship_from_country {
    type: string
    sql: ${TABLE}."SHIP_FROM_COUNTRY" ;;
  }

  dimension: ship_from_nickname {
    type: string
    sql: ${TABLE}."SHIP_FROM_NICKNAME" ;;
  }

  dimension: ship_to_street {
    type: string
    sql: ${TABLE}."SHIP_TO_STREET" ;;
  }

  dimension: ship_to_city {
    type: string
    sql: ${TABLE}."SHIP_TO_CITY" ;;
  }

  dimension: ship_to_state {
    type: string
    sql: ${TABLE}."SHIP_TO_STATE" ;;
  }

  dimension: ship_to_zip_code {
    type: string
    sql: ${TABLE}."SHIP_TO_ZIP_CODE" ;;
  }

  dimension: ship_to_country {
    type: string
    sql: ${TABLE}."SHIP_TO_COUNTRY" ;;
  }

  dimension: ship_to_nickname {
    type: string
    sql: ${TABLE}."SHIP_TO_NICKNAME" ;;
  }

  dimension: ship_from_latitude {
    type: string
    sql: ${TABLE}."SHIP_FROM_LATITUDE" ;;
  }

  dimension: ship_from_longitude {
    type: string
    sql: ${TABLE}."SHIP_FROM_LONGITUDE" ;;
  }

  dimension: ship_to_latitude {
    type: string
    sql: ${TABLE}."SHIP_TO_LATITUDE" ;;
  }

  dimension: ship_to_longitude {
    type: string
    sql: ${TABLE}."SHIP_TO_LONGITUDE" ;;
  }

  dimension: src {
    type: string
    sql: ${TABLE}."SRC" ;;
  }

  dimension: rental_bill_type {
    type: string
    sql: ${TABLE}."RENTAL_BILL_TYPE" ;;
  }

  dimension: secondary_salesperson_ids {
    type: string
    sql: ${TABLE}."SECONDARY_SALESPERSON_IDS" ;;
  }

  dimension: is_rental_revenue {
    type: yesno
    sql: ${TABLE}."IS_RENTAL_REVENUE" ;;
  }

  dimension: is_taxable {
    type: yesno
    sql: ${TABLE}."IS_TAXABLE" ;;
  }

  dimension: is_intercompany {
    type: yesno
    sql: ${TABLE}."IS_INTERCOMPANY" ;;
  }

  dimension: is_pending {
    type: yesno
    sql: ${TABLE}."IS_PENDING" ;;
  }

  dimension: is_deleted {
    type: yesno
    sql: ${TABLE}."IS_DELETED" ;;
  }

  dimension: is_billing_approved {
    type: yesno
    sql: ${TABLE}."IS_BILLING_APPROVED" ;;
  }

  dimension: is_credit_note_generated_from_invoice {
    type: yesno
    sql: ${TABLE}."IS_CREDIT_NOTE_GENERATED_FROM_INVOICE" ;;
  }

  dimension: rental_cheapest_period_week_count {
    type: number
    sql: ${TABLE}."RENTAL_CHEAPEST_PERIOD_WEEK_COUNT" ;;
  }

  dimension: rental_cheapest_period_four_week_count {
    type: number
    sql: ${TABLE}."RENTAL_CHEAPEST_PERIOD_FOUR_WEEK_COUNT" ;;
  }

  dimension: rental_cheapest_period_hour_count {
    type: number
    sql: ${TABLE}."RENTAL_CHEAPEST_PERIOD_HOUR_COUNT" ;;
  }

  dimension: rental_cheapest_period_day_count {
    type: number
    sql: ${TABLE}."RENTAL_CHEAPEST_PERIOD_DAY_COUNT" ;;
  }

  dimension: rental_cheapest_period_month_count {
    type: number
    sql: ${TABLE}."RENTAL_CHEAPEST_PERIOD_MONTH_COUNT" ;;
  }

  dimension_group: invoice_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."INVOICE_DATE" ;;
  }

  dimension_group: credit_note_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."CREDIT_NOTE_DATE" ;;
  }

  dimension_group: billing_approved_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."BILLING_APPROVED_DATE" ;;
  }

  dimension_group: gl_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."GL_DATE" ;;
  }

  dimension_group: line_item_date_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."LINE_ITEM_DATE_CREATED" ;;
  }

  dimension_group: line_item_date_updated {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."LINE_ITEM_DATE_UPDATED" ;;
  }

  dimension_group: header_date_updated {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."HEADER_DATE_UPDATED" ;;
  }

  dimension_group: header_date_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."HEADER_DATE_CREATED" ;;
  }

  dimension_group: invoice_cycle_start_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."INVOICE_CYCLE_START_DATE" ;;
  }

  dimension_group: invoice_cycle_end_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."INVOICE_CYCLE_END_DATE" ;;
  }

  dimension_group: paid_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."PAID_DATE" ;;
  }

  set: detail_drill {
    fields: [line_item_id, invoice_number, credit_note_number, customer_name, market_name, amount, invoice_date_date]
  }

  measure: count {
    type: count
    drill_fields: [detail_drill*]
  }


}
