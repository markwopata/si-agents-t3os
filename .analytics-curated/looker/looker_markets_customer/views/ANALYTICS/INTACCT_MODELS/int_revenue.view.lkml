view: int_revenue {
  sql_table_name: "INTACCT_MODELS"."INT_REVENUE" ;;

  dimension: revenue_row_pk {
    hidden: yes
    primary_key: yes
    type: string
    sql: concat(
          coalesce(to_varchar(${TABLE}."INVOICE_ID"), 'null'), '|',
          coalesce(to_varchar(${TABLE}."LINE_ITEM_ID"), 'null'), '|',
          coalesce(to_varchar(${TABLE}."CREDIT_NOTE_LINE_ITEM_ID"), '0'), '|',
          coalesce(${TABLE}."SRC", 'null')
        ) ;;
  }

  dimension: account_name {
    type: string
    sql: ${TABLE}."ACCOUNT_NAME" ;;
  }
  dimension: account_number {
    type: string
    sql: ${TABLE}."ACCOUNT_NUMBER" ;;
  }
  dimension: amount {
    type: number
    sql: coalesce(${TABLE}."AMOUNT",0) ;;
  }
  dimension: asset_id {
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: asset_id_link_to_details {
    type: number
    value_format_name: id
    group_label: "Links"
    label: "Asset ID"
    sql: ${asset_id} ;;
    html: <a href='https://equipmentshare.looker.com/dashboards/169?Asset+ID={{ value | url_encode }}' target='_blank' style='color:#0063f3; text-decoration:underline;'>{{ value }} ➔</a>;;
  }
  dimension: avalara_transaction_id {
    type: string
    sql: ${TABLE}."AVALARA_TRANSACTION_ID" ;;
  }
  dimension_group: billing_approved {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."BILLING_APPROVED_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }
  dimension_group: credit_note {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."CREDIT_NOTE_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: credit_note_id {
    type: number
    sql: ${TABLE}."CREDIT_NOTE_ID" ;;
  }
  dimension: credit_note_line_item_id {
    type: number
    sql: ${TABLE}."CREDIT_NOTE_LINE_ITEM_ID" ;;
  }
  dimension: credit_note_memo {
    type: string
    sql: ${TABLE}."CREDIT_NOTE_MEMO" ;;
  }
  dimension: credit_note_number {
    type: string
    sql: ${TABLE}."CREDIT_NOTE_NUMBER" ;;
  }
  dimension: credit_note_reference {
    type: string
    sql: ${TABLE}."CREDIT_NOTE_REFERENCE" ;;
  }
  dimension: credit_note_status_id {
    type: number
    sql: ${TABLE}."CREDIT_NOTE_STATUS_ID" ;;
  }
  dimension: credit_note_status_name {
    type: string
    sql: ${TABLE}."CREDIT_NOTE_STATUS_NAME" ;;
  }
  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }
  dimension_group: gl {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."GL_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: formatted_month_gl {
    group_label: "GL HTML Formatted Date"
    label: "Month"
    type: date
    sql: DATE_TRUNC(month,${gl_date}::DATE) ;;
    html: {{ rendered_value | date: "%b %Y"  }};;
  }
  dimension_group: header_date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."HEADER_DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: header_date_updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."HEADER_DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: invoice_cycle_end {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."INVOICE_CYCLE_END_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: invoice_cycle_start {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."INVOICE_CYCLE_START_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: invoice {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."INVOICE_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
  }
  dimension: invoice_memo {
    type: string
    sql: ${TABLE}."INVOICE_MEMO" ;;
  }
  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }
  dimension: is_billing_approved {
    type: yesno
    sql: ${TABLE}."IS_BILLING_APPROVED" ;;
  }
  dimension: is_credit_note_generated_from_invoice {
    type: yesno
    sql: ${TABLE}."IS_CREDIT_NOTE_GENERATED_FROM_INVOICE" ;;
  }
  dimension: is_intercompany {
    type: yesno
    sql: ${TABLE}."IS_INTERCOMPANY" ;;
  }
  dimension: is_rental_revenue {
    type: yesno
    sql: ${TABLE}."IS_RENTAL_REVENUE" ;;
  }
  dimension: is_taxable {
    type: yesno
    sql: ${TABLE}."IS_TAXABLE" ;;
  }
  dimension_group: line_item_date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."LINE_ITEM_DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: line_item_date_updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."LINE_ITEM_DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: line_item_description {
    type: string
    sql: ${TABLE}."LINE_ITEM_DESCRIPTION" ;;
  }
  dimension: line_item_id {
    type: number
    sql: ${TABLE}."LINE_ITEM_ID" ;;
  }
  dimension: line_item_market_id {
    type: number
    sql: ${TABLE}."LINE_ITEM_MARKET_ID" ;;
  }
  dimension: line_item_type_id {
    type: number
    sql: ${TABLE}."LINE_ITEM_TYPE_ID" ;;
  }
  dimension: line_item_type_name {
    type: string
    sql: ${TABLE}."LINE_ITEM_TYPE_NAME" ;;
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }
  dimension_group: paid {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."PAID_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: primary_salesperson_id {
    type: number
    sql: ${TABLE}."PRIMARY_SALESPERSON_ID" ;;
  }
  dimension: rental_bill_type {
    type: string
    sql: ${TABLE}."RENTAL_BILL_TYPE" ;;
  }
  dimension: rental_cheapest_period_day_count {
    type: number
    sql: ${TABLE}."RENTAL_CHEAPEST_PERIOD_DAY_COUNT" ;;
  }
  dimension: rental_cheapest_period_four_week_count {
    type: number
    sql: ${TABLE}."RENTAL_CHEAPEST_PERIOD_FOUR_WEEK_COUNT" ;;
  }
  dimension: rental_cheapest_period_hour_count {
    type: number
    sql: ${TABLE}."RENTAL_CHEAPEST_PERIOD_HOUR_COUNT" ;;
  }
  dimension: rental_cheapest_period_month_count {
    type: number
    sql: ${TABLE}."RENTAL_CHEAPEST_PERIOD_MONTH_COUNT" ;;
  }
  dimension: rental_cheapest_period_week_count {
    type: number
    sql: ${TABLE}."RENTAL_CHEAPEST_PERIOD_WEEK_COUNT" ;;
  }
  dimension: rental_id {
    type: string
    sql: ${TABLE}."RENTAL_ID" ;;
  }
  dimension: rental_price_per_day {
    type: string
    sql: ${TABLE}."RENTAL_PRICE_PER_DAY" ;;
  }
  dimension: rental_price_per_four_weeks {
    type: string
    sql: ${TABLE}."RENTAL_PRICE_PER_FOUR_WEEKS" ;;
  }
  dimension: rental_price_per_hour {
    type: string
    sql: ${TABLE}."RENTAL_PRICE_PER_HOUR" ;;
  }
  dimension: rental_price_per_month {
    type: string
    sql: ${TABLE}."RENTAL_PRICE_PER_MONTH" ;;
  }
  dimension: rental_price_per_week {
    type: string
    sql: ${TABLE}."RENTAL_PRICE_PER_WEEK" ;;
  }
  dimension: secondary_salesperson_ids {
    type: string
    sql: ${TABLE}."SECONDARY_SALESPERSON_IDS" ;;
  }
  dimension: ship_from_branch_id {
    type: number
    sql: ${TABLE}."SHIP_FROM_BRANCH_ID" ;;
  }
  dimension: ship_from_city {
    type: string
    sql: ${TABLE}."SHIP_FROM_CITY" ;;
  }
  dimension: ship_from_country {
    type: string
    sql: ${TABLE}."SHIP_FROM_COUNTRY" ;;
  }
  dimension: ship_from_latitude {
    type: string
    sql: ${TABLE}."SHIP_FROM_LATITUDE" ;;
  }
  dimension: ship_from_location_id {
    type: string
    sql: ${TABLE}."SHIP_FROM_LOCATION_ID" ;;
  }
  dimension: ship_from_longitude {
    type: string
    sql: ${TABLE}."SHIP_FROM_LONGITUDE" ;;
  }
  dimension: ship_from_nickname {
    type: string
    sql: ${TABLE}."SHIP_FROM_NICKNAME" ;;
  }
  dimension: ship_from_state {
    type: string
    sql: ${TABLE}."SHIP_FROM_STATE" ;;
  }
  dimension: ship_from_street {
    type: string
    sql: ${TABLE}."SHIP_FROM_STREET" ;;
  }
  dimension: ship_from_zip_code {
    type: string
    sql: ${TABLE}."SHIP_FROM_ZIP_CODE" ;;
  }
  dimension: ship_to_branch_id {
    type: string
    sql: ${TABLE}."SHIP_TO_BRANCH_ID" ;;
  }
  dimension: ship_to_city {
    type: string
    sql: ${TABLE}."SHIP_TO_CITY" ;;
  }
  dimension: ship_to_country {
    type: string
    sql: ${TABLE}."SHIP_TO_COUNTRY" ;;
  }
  dimension: ship_to_latitude {
    type: string
    sql: ${TABLE}."SHIP_TO_LATITUDE" ;;
  }
  dimension: ship_to_location_id {
    type: string
    sql: ${TABLE}."SHIP_TO_LOCATION_ID" ;;
  }
  dimension: ship_to_longitude {
    type: string
    sql: ${TABLE}."SHIP_TO_LONGITUDE" ;;
  }
  dimension: ship_to_nickname {
    type: string
    sql: ${TABLE}."SHIP_TO_NICKNAME" ;;
  }
  dimension: ship_to_state {
    type: string
    sql: ${TABLE}."SHIP_TO_STATE" ;;
  }
  dimension: ship_to_street {
    type: string
    sql: ${TABLE}."SHIP_TO_STREET" ;;
  }
  dimension: ship_to_zip_code {
    type: string
    sql: ${TABLE}."SHIP_TO_ZIP_CODE" ;;
  }
  dimension: src {
    type: string
    sql: ${TABLE}."SRC" ;;
  }
  dimension: tax_amount {
    type: number
    sql: ${TABLE}."TAX_AMOUNT" ;;
  }
  dimension: url_credit_note_admin {
    type: string
    sql: ${TABLE}."URL_CREDIT_NOTE_ADMIN" ;;
  }
  dimension: url_invoice_admin {
    type: string
    sql: ${TABLE}."URL_INVOICE_ADMIN" ;;
  }
  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: total_amount {
    type: sum
    sql:coalesce(${amount},0);;
    value_format: "[>=1000000000]$0.00,,,\"B\";[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      asset_id_link_to_details,
      rental_id,
      customer_name,
      market_name
  ]
  }

}
