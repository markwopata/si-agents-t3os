view: dim_invoices_fleet_opt {
  derived_table: {
    sql:
select di.*
    , labor.billed_labor_hours
    , labor.labor_rate
from "FLEET_OPTIMIZATION"."GOLD"."DIM_INVOICES_FLEET_OPT" di
left join (
        select invoice_id
            , sum(number_of_units) as billed_labor_hours
            , max(price_per_unit) as labor_rate
        from ES_WAREHOUSE.PUBLIC.LINE_ITEMS li
        join ES_WAREHOUSE.PUBLIC.LINE_ITEM_TYPES lit
            on lit.line_item_type_id = li.line_item_type_id
                and lit.name ilike '%labor%'
        group by 1
    ) labor
    on labor.invoice_id = di.invoice_id;;
  }

  dimension: invoice_avalara_transaction_id {
    type: string
    sql: ${TABLE}."INVOICE_AVALARA_TRANSACTION_ID" ;;
  }
  dimension: invoice_billing_approved {
    type: yesno
    sql: ${TABLE}."INVOICE_BILLING_APPROVED" ;;
  }
  dimension: invoice_billing_approved_date_key {
    type: string
    sql: ${TABLE}."INVOICE_BILLING_APPROVED_DATE_KEY" ;;
  }
  dimension_group: invoice_billing_approved {
    type: time
    timeframes: [
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."INVOICE_BILLING_APPROVED_DATE" ;;
  }
  dimension: invoice_company_key {
    type: string
    sql: ${TABLE}."INVOICE_COMPANY_KEY" ;;
  }
  dimension: invoice_creator_user_key {
    type: string
    sql: ${TABLE}."INVOICE_CREATOR_USER_KEY" ;;
  }
  dimension: invoice_credit_note_indicates_error {
    type: yesno
    sql: ${TABLE}."INVOICE_CREDIT_NOTE_INDICATES_ERROR" ;;
  }
  dimension: invoice_customer_tax_exempt_status {
    type: yesno
    sql: ${TABLE}."INVOICE_CUSTOMER_TAX_EXEMPT_STATUS" ;;
  }
  dimension: invoice_date_key {
    type: string
    sql: ${TABLE}."INVOICE_DATE_KEY" ;;
  }
  dimension: invoice_due_date_key {
    type: string
    sql: ${TABLE}."INVOICE_DUE_DATE_KEY" ;;
  }
  dimension: invoice_has_pending_warranty {
    type: yesno
    sql: ${TABLE}."INVOICE_HAS_PENDING_WARRANTY" ;;
  }
  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
  }
  dimension: invoice_is_warranty_invoice {
    type: yesno
    sql: ${TABLE}."INVOICE_IS_WARRANTY_INVOICE" ;;
  }
  dimension: invoice_key {
    type: string
    sql: ${TABLE}."INVOICE_KEY" ;;
  }
  dimension: invoice_no {
    type: string
    sql: ${TABLE}."INVOICE_NO" ;;
    html: <a href="https://admin.equipmentshare.com/#/home/transactions/invoices/{{ invoice_id._value }}" target="new" style="color: #0063f3; text-decoration: underline;">{{ invoice_no._value }}</a> ;;
  }
  dimension: invoice_number_of_days_outstanding {
    type: number
    sql: ${TABLE}."INVOICE_NUMBER_OF_DAYS_OUTSTANDING" ;;
  }
  dimension: invoice_paid {
    type: yesno
    sql: ${TABLE}."INVOICE_PAID" ;;
  }
  dimension: invoice_paid_date_key {
    type: string
    sql: ${TABLE}."INVOICE_PAID_DATE_KEY" ;;
  }
  dimension: invoice_public_note {
    type: string
    sql: ${TABLE}."INVOICE_PUBLIC_NOTE" ;;
  }
  dimension_group: invoice_recordtimestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."INVOICE_RECORDTIMESTAMP" ;;
  }
  dimension: invoice_reference {
    type: string
    sql: ${TABLE}."INVOICE_REFERENCE" ;;
  }
  dimension: invoice_source {
    type: string
    sql: ${TABLE}."INVOICE_SOURCE" ;;
  }
  measure: count {
    type: count
  }
  dimension: billed_labor_hours {
    type: number
    value_format_name: decimal_1
    sql: ${TABLE}.billed_labor_hours ;;
  }
  dimension: labor_rate {
    type: number
    value_format_name: usd
    sql: ${TABLE}.labor_rate ;;
  }
}
