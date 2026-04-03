view: invoices {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."INVOICES"
  ;;

  dimension: _es_update_timestamp {
    type: date_raw
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }
  dimension: order_id {
    type: number
    sql: ${TABLE}."ORDER_ID" ;;
  }
  dimension: reference {
    type: string
    sql: ${TABLE}."REFERENCE" ;;
  }
  dimension: sent {
    type: yesno
    sql: ${TABLE}."SENT" ;;
  }
  dimension: billing_approved_by_user_id {
    type: number
    sql: ${TABLE}."BILLING_APPROVED_BY_USER_ID" ;;
  }
  dimension: public_note {
    type: string
    sql: ${TABLE}."PUBLIC_NOTE" ;;
  }
  dimension: billing_approved_date {
    type: date_raw
    sql: ${TABLE}."BILLING_APPROVED_DATE" ;;
  }
  dimension: due_date {
    type: date_raw
    sql: ${TABLE}."DUE_DATE" ;;
  }
  dimension: created_by_user_id {
    type: number
    sql: ${TABLE}."CREATED_BY_USER_ID" ;;
  }
  dimension: paid {
    type: yesno
    sql: ${TABLE}."PAID" ;;
  }
  dimension: invoice_no {
    type: string
    sql: ${TABLE}."INVOICE_NO" ;;
  }
  dimension: end_date {
    type: date_raw
    sql: ${TABLE}."END_DATE" ;;
  }
  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
  }
  dimension: date_created {
    type: date_raw
    sql: ${TABLE}."DATE_CREATED" ;;
  }
  dimension: billing_provider_id {
    type: number
    sql: ${TABLE}."BILLING_PROVIDER_ID" ;;
  }
  dimension: private_note {
    type: string
    sql: ${TABLE}."PRIVATE_NOTE" ;;
  }
  dimension: start_date {
    type: date_raw
    sql: ${TABLE}."START_DATE" ;;
  }
  dimension: xero_id {
    type: string
    sql: ${TABLE}."XERO_ID" ;;
  }
  dimension: billing_approved {
    type: yesno
    sql: ${TABLE}."BILLING_APPROVED" ;;
  }
  dimension: paid_date {
    type: date_raw
    sql: ${TABLE}."PAID_DATE" ;;
  }
  dimension: invoice_date {
    type: date_raw
    sql: ${TABLE}."INVOICE_DATE" ;;
  }
  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }
  dimension: rental_amount {
    type: number
    sql: ${TABLE}."RENTAL_AMOUNT" ;;
  }
  dimension: owed_amount {
    type: number
    sql: ${TABLE}."OWED_AMOUNT" ;;
  }
  dimension: line_item_amount {
    type: number
    sql: ${TABLE}."LINE_ITEM_AMOUNT" ;;
  }
  dimension: billed_amount {
    type: number
    sql: ${TABLE}."BILLED_AMOUNT" ;;
  }
  dimension: rpp_amount {
    type: number
    sql: ${TABLE}."RPP_AMOUNT" ;;
  }
  dimension: tax_amount {
    type: number
    sql: ${TABLE}."TAX_AMOUNT" ;;
  }
  dimension: customer_tax_exempt_status {
    type: yesno
    sql: ${TABLE}."CUSTOMER_TAX_EXEMPT_STATUS" ;;
  }
  dimension: ship_from {
    type: string
    sql: ${TABLE}."SHIP_FROM" ;;
  }
  dimension: ship_to {
    type: string
    sql: ${TABLE}."SHIP_TO" ;;
  }
  dimension: avalara_transaction_id {
    type: number
    sql: ${TABLE}."AVALARA_TRANSACTION_ID" ;;
  }
  dimension: avalara_transaction_id_update_dt_tm {
    type: date_raw
    sql: ${TABLE}."AVALARA_TRANSACTION_ID_UPDATE_DT_TM" ;;
  }
  dimension: are_tax_cals_missing {
    type: string
    sql: ${TABLE}."ARE_TAX_CALS_MISSING" ;;
  }
  dimension: taxes_invalidated_dt_tm {
    type: date_raw
    sql: ${TABLE}."TAXES_INVALIDATED_DT_TM" ;;
  }
  dimension: date_updated {
    type: date_raw
    sql: ${TABLE}."DATE_UPDATED" ;;
  }
  dimension: purchase_order_id {
    type: number
    sql: ${TABLE}."PURCHASE_ORDER_ID" ;;
  }
  dimension: ordered_by_user_id {
    type: number
    sql: ${TABLE}."ORDERED_BY_USER_ID" ;;
  }
  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }
  dimension: outstanding {
    type: number
    sql: ${TABLE}."OUTSTANDING" ;;
  }
  dimension: due_date_outstanding {
    type: number
    sql: ${TABLE}."DUE_DATE_OUTSTANDING" ;;
  }
  dimension: are_tax_calcs_missing {
    type: yesno
    sql: ${TABLE}."ARE_TAX_CALCS_MISSING" ;;
  }
  dimension: extended_data {
    type: string
    sql: ${TABLE}."EXTENDED_DATA" ;;
  }
}
