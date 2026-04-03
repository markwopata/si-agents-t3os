
view: int_admin_credit_note_line_detail {
  sql_table_name: ANALYTICS.INTACCT_MODELS.INT_ADMIN_CREDIT_NOTE_LINE_DETAIL;;


  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: credit_note_id {
    type: string
    sql: ${TABLE}."CREDIT_NOTE_ID" ;;
  }

  dimension: credit_note_id_link {
    label: "Credit Note ID"
    type: string
    sql: ${credit_note_id} ;;
    html: <font color="#0063f3 "><u><a href="{{url_credit_note_admin}}" target="_blank">{{credit_note_id._rendered_value}} ➔ </a></font></u> ;;
  }

  dimension: credit_note_number {
    type: string
    sql: ${TABLE}."CREDIT_NOTE_NUMBER" ;;
  }

  dimension: credit_note_type_id {
    type: string
    sql: ${TABLE}."CREDIT_NOTE_TYPE_ID" ;;
  }

  dimension: credit_note_type_name {
    type: string
    sql: ${TABLE}."CREDIT_NOTE_TYPE_NAME" ;;
  }

  dimension: credit_note_status_id {
    type: string
    sql: ${TABLE}."CREDIT_NOTE_STATUS_ID" ;;
  }

  dimension: credit_note_status_name {
    type: string
    sql: ${TABLE}."CREDIT_NOTE_STATUS_NAME" ;;
  }

  dimension: reason_ids {
    type: string
    sql: ${TABLE}."REASON_IDS" ;;
  }

  dimension: request_reasons {
    type: string
    sql: ${TABLE}."REQUEST_REASONS" ;;
  }

  dimension: notes {
    type: string
    sql: ${TABLE}."NOTES" ;;
  }

  dimension_group: gl_date {
    type: time
    sql: ${TABLE}."GL_DATE" ;;
  }

  dimension_group: credit_note_date {
    type: time
    sql: ${TABLE}."CREDIT_NOTE_DATE" ;;
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

  dimension: credit_note_memo {
    type: string
    sql: ${TABLE}."CREDIT_NOTE_MEMO" ;;
  }

  dimension: credit_note_reference {
    type: string
    sql: ${TABLE}."CREDIT_NOTE_REFERENCE" ;;
  }

  dimension: credit_note_line_item_id {
    type: string
    sql: ${TABLE}."CREDIT_NOTE_LINE_ITEM_ID" ;;
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

  dimension: avalara_transaction_id {
    type: string
    sql: ${TABLE}."AVALARA_TRANSACTION_ID" ;;
  }

  dimension: account_number {
    type: string
    sql: ${TABLE}."ACCOUNT_NUMBER" ;;
  }

  dimension: account_name {
    type: string
    sql: ${TABLE}."ACCOUNT_NAME" ;;
  }

  dimension: credit_amount {
    type: number
    sql: ${TABLE}."CREDIT_AMOUNT" * (-1);;
    value_format_name: usd
  }

  measure: credit_amount_sum {
    type: sum
    sql:  ${credit_amount}  ;;
    value_format_name: usd_0
    drill_fields: [credit_sum_detail*]
  }

  measure: credit_amount_drill {
    label: "Credit Total"
    type: sum
    sql:  ${credit_amount}  ;;
    value_format_name: usd
  }

  measure: credit_amount_sum_cm {
    label: "Current Month Credit Total"
    type: sum
    sql:  CASE WHEN ${v_dim_dates_bi.is_current_month} THEN ${credit_amount} END ;;
    description: "Sum of all current month credits tied to invoices a rep is assigned to as the primary salesperson."
    value_format_name: usd_0
    drill_fields: [credit_sum_detail*]
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
  }

  measure: credit_amount_sum_pm {
    label: "Prior Month Credit Total"
    type: sum
    sql:  CASE WHEN ${v_dim_dates_bi.is_prior_month} THEN ${credit_amount} END ;;
    value_format_name: usd_0
    description: "Sum of all prior month credits tied to invoices a rep is assigned to as the primary salesperson."
    drill_fields: [credit_sum_detail*]
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
  }

  measure: credit_amount_sum_cm_drill {
    label: "Current Month Credit"
    type: sum
    sql:  ${credit_amount} ;;
    filters: [v_dim_dates_bi.is_current_month: "Yes"]
    description: "Sum of all approved current month credits tied to invoices a rep is assigned to as the primary salesperson."
    value_format_name: usd_0
    drill_fields: [credit_sum_detail*]
  }

  measure: credit_amount_sum_pm_drill {
    label: "Prior Month Credit"
    type: sum
    sql:  ${credit_amount} ;;
    filters: [v_dim_dates_bi.is_prior_month: "Yes"]
    description: "Sum of all approved prior month credits tied to invoices a rep is assigned to as the primary salesperson."
    value_format_name: usd_0
    drill_fields: [credit_sum_detail*]
  }

  measure: credit_amount_sum_cm_filter {
    label: "Current Month Credit Amt"
    type: sum
    sql:  ${credit_amount} ;;
    filters: [v_dim_dates_bi.is_current_month: "Yes"]
    description: "Sum of all approved current month credits tied to invoices a rep is assigned to as the primary salesperson."
    value_format_name: usd_0
    drill_fields: [credit_sum_detail*]
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
  }

  measure: credit_amount_sum_pm_filter {
    label: "Prior Month Credit Amt"
    type: sum
    sql:  ${credit_amount} ;;
    filters: [v_dim_dates_bi.is_prior_month: "Yes"]
    description: "Sum of all approved prior month credits tied to invoices a rep is assigned to as the primary salesperson."
    value_format_name: usd_0
    drill_fields: [credit_sum_detail*]
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
  }

  measure: credit_count_cm_filter {
    label: "Current Month Count of Credits"
    type: count_distinct
    sql:  ${credit_note_id} ;;
    filters: [v_dim_dates_bi.is_current_month: "Yes"]
    description: "Count of all approvedcurrent month credits tied to invoices a rep is assigned to as the primary salesperson."
    drill_fields: [credit_sum_detail*]
  }

  measure: credit_count_pm_filter  {
    label: "Prior Month Count of Credits"
    type: count_distinct
    sql:  ${credit_note_id} ;;
    filters: [v_dim_dates_bi.is_prior_month: "Yes"]
    description: "Count of all approved prior month credits tied to invoices a rep is assigned to as the primary salesperson."
    drill_fields: [credit_sum_detail*]
  }

  dimension: credit_tax_amount {
    type: number
    sql: ${TABLE}."CREDIT_TAX_AMOUNT" ;;
    value_format_name: usd

  }

  dimension: original_line_amount {
    type: number
    sql: ${TABLE}."ORIGINAL_LINE_AMOUNT" ;;
    value_format_name: usd
  }

  dimension: original_line_tax_amount {
    type: number
    sql: ${TABLE}."ORIGINAL_LINE_TAX_AMOUNT" ;;
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

  dimension_group: credit_note_date_created {
    type: time
    sql: ${TABLE}."CREDIT_NOTE_DATE_CREATED" ;;
  }

  dimension_group: credit_note_date_updated {
    type: time
    sql: ${TABLE}."CREDIT_NOTE_DATE_UPDATED" ;;
  }

  dimension_group: credit_note_line_item_date_created {
    type: time
    sql: ${TABLE}."CREDIT_NOTE_LINE_ITEM_DATE_CREATED" ;;
  }

  dimension_group: credit_note_line_item_date_updated {
    type: time
    sql: ${TABLE}."CREDIT_NOTE_LINE_ITEM_DATE_UPDATED" ;;
  }

  dimension: originating_invoice_id {
    type: string
    sql: ${TABLE}."ORIGINATING_INVOICE_ID" ;;
  }

  dimension: is_generated_from_invoice {
    type: yesno
    sql: ${TABLE}."IS_GENERATED_FROM_INVOICE" ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }

  dimension: admin_link_to_invoice {
    label: "Invoice Number"
    type: string
    html: <font color="#0063f3 "><u><a href="{{url_invoice_admin}}" target="_blank">{{invoice_number._rendered_value}} ➔ </a></font></u> ;;
    sql: ${invoice_number}  ;;
  }

  dimension_group: invoice_billing_approved_date {
    type: time
    sql: ${TABLE}."INVOICE_BILLING_APPROVED_DATE" ;;
  }

  dimension_group: invoice_date {
    type: time
    sql: ${TABLE}."INVOICE_DATE" ;;
  }

  dimension: invoice_memo {
    type: string
    sql: ${TABLE}."INVOICE_MEMO" ;;
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
    value_format_name: usd_0
  }

  dimension: rental_price_per_day {
    type: string
    sql: ${TABLE}."RENTAL_PRICE_PER_DAY" ;;
    value_format_name: usd_0

  }

  dimension: rental_price_per_week {
    type: string
    sql: ${TABLE}."RENTAL_PRICE_PER_WEEK" ;;
    value_format_name: usd_0

  }

  dimension: rental_price_per_four_weeks {
    type: string
    sql: ${TABLE}."RENTAL_PRICE_PER_FOUR_WEEKS" ;;
    value_format_name: usd_0

  }

  dimension: rental_price_per_month {
    type: string
    sql: ${TABLE}."RENTAL_PRICE_PER_MONTH" ;;
    value_format_name: usd_0

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

  dimension: primary_salesperson_id_complete {
    type: string
    sql: COALESCE(${primary_salesperson_id}, ${base_es_warehouse_public__approved_invoice_salespersons.primary_salesperson_id}) ;;
  }

  dimension: secondary_salesperson_ids {
    type: string
    sql: ${TABLE}."SECONDARY_SALESPERSON_IDS" ;;
  }

  dimension: url_credit_note_admin {
    type: string
    sql: ${TABLE}."URL_CREDIT_NOTE_ADMIN" ;;
  }

  dimension: url_invoice_admin {
    type: string
    sql: ${TABLE}."URL_INVOICE_ADMIN" ;;
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
    type: string
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

  set: credit_sum_detail {
    fields: [
      credit_note_id_link,
      dim_companies_bi.company_and_id_with_na_icon_and_link_int_credit_app,
      salesperson_permissions.rep_home_market_fmt,
      line_item_type_id,
      line_item_type_name,
      line_item_description,
      credit_note_memo,
      admin_link_to_invoice,
      credit_amount_drill
    ]

  }


  set: detail {
    fields: [
        credit_note_id,
  credit_note_number,
  credit_note_type_id,
  credit_note_type_name,
  credit_note_status_id,
  credit_note_status_name,
  reason_ids,
  request_reasons,
  notes,
  gl_date_time,
  credit_note_date_time,
  market_id,
  market_name,
  company_id,
  customer_name,
  credit_note_memo,
  credit_note_reference,
  credit_note_line_item_id,
  line_item_id,
  line_item_type_id,
  line_item_type_name,
  avalara_transaction_id,
  account_number,
  account_name,
  credit_amount,
  credit_tax_amount,
  original_line_amount,
  original_line_tax_amount,
  is_taxable,
  line_item_description,
  credit_note_date_created_time,
  credit_note_date_updated_time,
  credit_note_line_item_date_created_time,
  credit_note_line_item_date_updated_time,
  originating_invoice_id,
  is_generated_from_invoice,
  invoice_number,
  invoice_billing_approved_date_time,
  invoice_date_time,
  invoice_memo,
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
  url_credit_note_admin,
  url_invoice_admin,
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
