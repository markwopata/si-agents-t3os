view: stg_es_warehouse_public__invoices {
  sql_table_name: "INTACCT_MODELS"."STG_ES_WAREHOUSE_PUBLIC__INVOICES" ;;

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: are_tax_calcs_missing {
    type: yesno
    sql: ${TABLE}."ARE_TAX_CALCS_MISSING" ;;
  }
  dimension: are_tax_cals_missing {
    type: yesno
    sql: ${TABLE}."ARE_TAX_CALS_MISSING" ;;
  }
  dimension: avalara_transaction_id {
    type: string
    sql: ${TABLE}."AVALARA_TRANSACTION_ID" ;;
  }
  dimension_group: avalara_transaction_id_update_dt_tm {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."AVALARA_TRANSACTION_ID_UPDATE_DT_TM" AS TIMESTAMP_NTZ) ;;
  }
  dimension: billed_amount {
    type: number
    sql: ${TABLE}."BILLED_AMOUNT" ;;
  }
  dimension: billing_approved {
    type: yesno
    sql: ${TABLE}."BILLING_APPROVED" ;;
  }
  dimension: billing_approved_by_user_id {
    type: number
    sql: ${TABLE}."BILLING_APPROVED_BY_USER_ID" ;;
  }
  dimension_group: billing_approved {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."BILLING_APPROVED_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: billing_provider_id {
    type: number
    sql: ${TABLE}."BILLING_PROVIDER_ID" ;;
  }
  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }
  dimension: created_by_user_id {
    type: number
    sql: ${TABLE}."CREATED_BY_USER_ID" ;;
  }
  dimension: customer_tax_exempt_status {
    type: yesno
    sql: ${TABLE}."CUSTOMER_TAX_EXEMPT_STATUS" ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: due {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DUE_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: due_date_outstanding {
    type: number
    sql: ${TABLE}."DUE_DATE_OUTSTANDING" ;;
  }
  dimension_group: end {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."END_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: extended_data {
    type: string
    sql: ${TABLE}."EXTENDED_DATA" ;;
  }
  dimension: extended_data__generation_request_id {
    type: string
    sql: ${TABLE}."EXTENDED_DATA__GENERATION_REQUEST_ID" ;;
  }
  dimension: extended_data__ignore_for_cycle {
    type: string
    sql: ${TABLE}."EXTENDED_DATA__IGNORE_FOR_CYCLE" ;;
  }
  dimension: extended_data__in_dispute {
    type: string
    sql: ${TABLE}."EXTENDED_DATA__IN_DISPUTE" ;;
  }
  dimension: extended_data__job {
    type: string
    sql: ${TABLE}."EXTENDED_DATA__JOB" ;;
  }
  dimension: extended_data__job__job_id {
    type: string
    sql: ${TABLE}."EXTENDED_DATA__JOB__JOB_ID" ;;
  }
  dimension: extended_data__job__job_name {
    type: string
    sql: ${TABLE}."EXTENDED_DATA__JOB__JOB_NAME" ;;
  }
  dimension: extended_data__job__phase_name {
    type: string
    sql: ${TABLE}."EXTENDED_DATA__JOB__PHASE_NAME" ;;
  }
  dimension: extended_data__missing_special_charges {
    type: string
    sql: ${TABLE}."EXTENDED_DATA__MISSING_SPECIAL_CHARGES" ;;
  }
  dimension: extended_data__should_bill_dt {
    type: string
    sql: ${TABLE}."EXTENDED_DATA__SHOULD_BILL_DT" ;;
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
  dimension: invoice_no {
    type: string
    sql: ${TABLE}."INVOICE_NO" ;;
  }
  dimension: is_deleted {
    type: yesno
    sql: ${TABLE}."IS_DELETED" ;;
  }
  dimension: is_paid {
    type: yesno
    sql: ${TABLE}."IS_PAID" ;;
  }
  dimension: is_pending {
    type: yesno
    sql: ${TABLE}."IS_PENDING" ;;
  }
  dimension: line_item_amount {
    type: number
    sql: ${TABLE}."LINE_ITEM_AMOUNT" ;;
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: order_id {
    type: number
    sql: ${TABLE}."ORDER_ID" ;;
  }
  dimension: ordered_by_user_id {
    type: number
    sql: ${TABLE}."ORDERED_BY_USER_ID" ;;
  }
  dimension: outstanding {
    type: number
    sql: ${TABLE}."OUTSTANDING" ;;
  }
  dimension: owed_amount {
    type: number
    sql: ${TABLE}."OWED_AMOUNT" ;;
  }
  dimension_group: paid {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."PAID_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: private_note {
    type: string
    sql: ${TABLE}."PRIVATE_NOTE" ;;
  }
  dimension: public_note {
    type: string
    sql: ${TABLE}."PUBLIC_NOTE" ;;
  }
  dimension: purchase_order_id {
    type: number
    sql: ${TABLE}."PURCHASE_ORDER_ID" ;;
  }
  dimension: reference {
    type: string
    sql: ${TABLE}."REFERENCE" ;;
  }
  dimension: rental_amount {
    type: number
    sql: ${TABLE}."RENTAL_AMOUNT" ;;
  }
  dimension: rpp_amount {
    type: number
    sql: ${TABLE}."RPP_AMOUNT" ;;
  }
  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }
  dimension: sent {
    type: yesno
    sql: ${TABLE}."SENT" ;;
  }
  dimension: ship_from {
    type: string
    sql: ${TABLE}."SHIP_FROM" ;;
  }
  dimension: ship_from__address {
    type: string
    sql: ${TABLE}."SHIP_FROM__ADDRESS" ;;
  }
  dimension: ship_from__address__city {
    type: string
    sql: ${TABLE}."SHIP_FROM__ADDRESS__CITY" ;;
  }
  dimension: ship_from__address__country {
    type: string
    sql: ${TABLE}."SHIP_FROM__ADDRESS__COUNTRY" ;;
  }
  dimension: ship_from__address__latitude {
    type: string
    sql: ${TABLE}."SHIP_FROM__ADDRESS__LATITUDE" ;;
  }
  dimension: ship_from__address__longitude {
    type: string
    sql: ${TABLE}."SHIP_FROM__ADDRESS__LONGITUDE" ;;
  }
  dimension: ship_from__address__state_abbreviation {
    type: string
    sql: ${TABLE}."SHIP_FROM__ADDRESS__STATE_ABBREVIATION" ;;
  }
  dimension: ship_from__address__street_1 {
    type: string
    sql: ${TABLE}."SHIP_FROM__ADDRESS__STREET_1" ;;
  }
  dimension: ship_from__address__zip_code {
    type: string
    sql: ${TABLE}."SHIP_FROM__ADDRESS__ZIP_CODE" ;;
  }
  dimension: ship_from__branch_id {
    type: number
    sql: ${TABLE}."SHIP_FROM__BRANCH_ID" ;;
  }
  dimension: ship_from__location_id {
    type: string
    sql: ${TABLE}."SHIP_FROM__LOCATION_ID" ;;
  }
  dimension: ship_from__nickname {
    type: string
    sql: ${TABLE}."SHIP_FROM__NICKNAME" ;;
  }
  dimension: ship_to {
    type: string
    sql: ${TABLE}."SHIP_TO" ;;
  }
  dimension: ship_to__address {
    type: string
    sql: ${TABLE}."SHIP_TO__ADDRESS" ;;
  }
  dimension: ship_to__address__city {
    type: string
    sql: ${TABLE}."SHIP_TO__ADDRESS__CITY" ;;
  }
  dimension: ship_to__address__country {
    type: string
    sql: ${TABLE}."SHIP_TO__ADDRESS__COUNTRY" ;;
  }
  dimension: ship_to__address__latitude {
    type: string
    sql: ${TABLE}."SHIP_TO__ADDRESS__LATITUDE" ;;
  }
  dimension: ship_to__address__longitude {
    type: string
    sql: ${TABLE}."SHIP_TO__ADDRESS__LONGITUDE" ;;
  }
  dimension: ship_to__address__state_abbreviation {
    type: string
    sql: ${TABLE}."SHIP_TO__ADDRESS__STATE_ABBREVIATION" ;;
  }
  dimension: ship_to__address__street_1 {
    type: string
    sql: ${TABLE}."SHIP_TO__ADDRESS__STREET_1" ;;
  }
  dimension: ship_to__address__zip_code {
    type: string
    sql: ${TABLE}."SHIP_TO__ADDRESS__ZIP_CODE" ;;
  }
  dimension: ship_to__branch_id {
    type: string
    sql: ${TABLE}."SHIP_TO__BRANCH_ID" ;;
  }
  dimension: ship_to__location_id {
    type: string
    sql: ${TABLE}."SHIP_TO__LOCATION_ID" ;;
  }
  dimension: ship_to__nickname {
    type: string
    sql: ${TABLE}."SHIP_TO__NICKNAME" ;;
  }
  dimension_group: start {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."START_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: tax_amount {
    type: number
    sql: ${TABLE}."TAX_AMOUNT" ;;
  }
  dimension_group: taxes_invalidated_dt_tm {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TAXES_INVALIDATED_DT_TM" AS TIMESTAMP_NTZ) ;;
  }
  dimension: url_admin {
    type: string
    sql: ${TABLE}."URL_ADMIN" ;;
  }
  dimension: xero_id {
    type: string
    sql: ${TABLE}."XERO_ID" ;;
  }
  measure: line_item_amount_agg {
    label: "Total Line Item Amount"
    type: sum
    sql: ${line_item_amount} ;;
  }
  measure: tax_amount_agg {
    label: "Total Tax Amount"
    type: sum
    sql: ${tax_amount} ;;
  }
  measure: billed_amount_agg {
    label: "Total Billed Amount"
    type: sum
    sql: ${billed_amount} ;;
  }
  measure: count {
    type: count
    drill_fields: [extended_data__job__job_name, ship_from__nickname, extended_data__job__phase_name, ship_to__nickname]
  }
}
