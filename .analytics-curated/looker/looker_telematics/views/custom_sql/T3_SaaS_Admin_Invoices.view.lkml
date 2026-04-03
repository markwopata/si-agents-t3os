view: T3_SaaS_Admin_Invoices{
  derived_table: {
    sql:
with credits as (
select
    ABS(AMOUNT) + ABS(TAX_AMOUNT) as CREDIT,
    CREDIT_NOTE_ID,
    INVOICE_ID,
    LINE_ITEM_ID
from
    analytics.intacct_models.Int_admin_invoice_and_credit_line_detail
where
    MARKET_ID = '79502'
    and CREDIT_NOTE_ID is not null
)

, esdb_line_items as (
select
    INVOICE_ID,
    LINE_ITEM_ID,
    CAST(NUMBER_OF_UNITS as DECIMAL(15,2)) as NUMBER_OF_UNITS,
    CAST(PRICE_PER_UNIT as DECIMAL(15,2)) as PRICE_PER_UNIT
from
    es_warehouse.public.line_items
where
    LINE_ITEM_TYPE_ID in (30,31,32,33,34)
)

, invoices as (
select
    *
from
    es_warehouse.public.invoices
where
    COMPANY_ID <> '1854'
)

, invoice_lines_int as (select
    invoice_lines.BILLING_APPROVED_DATE::DATE as BILLING_APPROVED_DATE,
    MONTH(invoice_lines.BILLING_APPROVED_DATE::DATE) as BILLING_APPROVED_MONTH,
    YEAR(invoice_lines.BILLING_APPROVED_DATE::DATE) as BILLING_APPROVED_YEAR,
    invoice_lines.INVOICE_DATE::DATE as INVOICE_DATE,
    invoice_lines.LINE_ITEM_TYPE_NAME as LINE_ITEM_TYPE,
    invoice_lines.LINE_ITEM_TYPE_ID,
    invoice_lines.LINE_ITEM_DESCRIPTION as DESCRIPTION,
    invoice_lines.COMPANY_ID,
    companies.NAME as CUSTOMER_NAME,
    invoice_lines.INVOICE_ID,
    invoice_lines.INVOICE_NUMBER as INVOICE_NO,
    invoices.XERO_ID,
    purchase_orders.NAME as REFERENCE,
    invoice_lines.INVOICE_MEMO,
    case
        when invoice_lines.PAID_DATE is not null then 'TRUE'
        when invoice_lines.PAID_DATE is null then 'FALSE'
    end as PAID,
    esdb_line_items.NUMBER_OF_UNITS as QTY,
    esdb_line_items.PRICE_PER_UNIT as UNIT_PRICE,
    invoice_lines.AMOUNT as AMOUNT,
    credits.CREDIT_NOTE_ID,
    case
        when credits.CREDIT is null then 0
        else credits.CREDIT
    end as PAID_CREDITED,
    invoice_lines.MARKET_ID,
    invoice_lines.MARKET_NAME,
    invoice_lines.URL_INVOICE_ADMIN
from
    analytics.intacct_models.Int_admin_invoice_and_credit_line_detail invoice_lines
left join
    es_warehouse.public.companies companies
    on companies.COMPANY_ID = invoice_lines.COMPANY_ID
left join
    invoices
    on invoice_lines.INVOICE_ID = invoices.INVOICE_ID
left join
    es_warehouse.public.purchase_orders purchase_orders
    on invoices.PURCHASE_ORDER_ID = purchase_orders.PURCHASE_ORDER_ID
left join
    credits
    on invoice_lines.invoice_id = credits.invoice_id
    and invoice_lines.line_item_id = credits.LINE_ITEM_ID
left join
    esdb_line_items
    on esdb_line_items.LINE_ITEM_ID = invoice_lines.LINE_ITEM_ID
    and esdb_line_items.INVOICE_ID = invoice_lines.INVOICE_ID
where
    invoice_lines.LINE_ITEM_TYPE_ID in (30,31,32,33,34)
    and invoice_lines.BILLING_APPROVED_DATE::DATE >= '1/1/2020'
    and invoice_lines.COMPANY_ID <> '1854'
    and invoice_lines.AMOUNT > 0
order by
    invoice_lines.BILLING_APPROVED_DATE::DATE,
    invoice_lines.LINE_ITEM_TYPE_ID,
    invoice_lines.COMPANY_ID,
    invoice_lines.INVOICE_ID,
    invoice_lines.INVOICE_NUMBER
)

select
    invoice_lines_int.BILLING_APPROVED_DATE,
    case
        when invoice_lines_int.BILLING_APPROVED_MONTH = 1 then 'January'
        when invoice_lines_int.BILLING_APPROVED_MONTH = 2 then 'February'
        when invoice_lines_int.BILLING_APPROVED_MONTH = 3 then 'March'
        when invoice_lines_int.BILLING_APPROVED_MONTH = 4 then 'April'
        when invoice_lines_int.BILLING_APPROVED_MONTH = 5 then 'May'
        when invoice_lines_int.BILLING_APPROVED_MONTH = 6 then 'June'
        when invoice_lines_int.BILLING_APPROVED_MONTH = 7 then 'July'
        when invoice_lines_int.BILLING_APPROVED_MONTH = 8 then 'August'
        when invoice_lines_int.BILLING_APPROVED_MONTH = 9 then 'September'
        when invoice_lines_int.BILLING_APPROVED_MONTH = 10 then 'October'
        when invoice_lines_int.BILLING_APPROVED_MONTH = 11 then 'November'
        when invoice_lines_int.BILLING_APPROVED_MONTH = 12 then 'December'
        end as BILLING_APPROVED_MONTH,
    invoice_lines_int.BILLING_APPROVED_YEAR,
    invoice_lines_int.INVOICE_DATE,
    invoice_lines_int.LINE_ITEM_TYPE,
    invoice_lines_int.LINE_ITEM_TYPE_ID,
    invoice_lines_int.DESCRIPTION,
    invoice_lines_int.COMPANY_ID,
    invoice_lines_int.CUSTOMER_NAME,
    invoice_lines_int.INVOICE_ID,
    invoice_lines_int.INVOICE_NO,
    invoice_lines_int.XERO_ID,
    invoice_lines_int.REFERENCE,
    invoice_lines_int.INVOICE_MEMO,
    invoice_lines_int.PAID,
    invoice_lines_int.AMOUNT as REVENUE,
    invoice_lines_int.QTY,
    invoice_lines_int.UNIT_PRICE,
    case
        when invoice_lines_int.PAID_CREDITED > 0 then 'TRUE'
        when invoice_lines_int.PAID_CREDITED = 0 then 'FALSE'
    end as CREDITED,
    invoice_lines_int.CREDIT_NOTE_ID,
    invoice_lines_int.PAID_CREDITED,
    invoice_lines_int.MARKET_ID,
    invoice_lines_int.MARKET_NAME,
    invoice_lines_int.URL_INVOICE_ADMIN
from
    invoice_lines_int
    ;;}

  dimension: BILLING_APPROVED_DATE {
    type: date
    sql: ${TABLE}.BILLING_APPROVED_DATE ;;
  }

  dimension: BILLING_APPROVED_MONTH {
    type: string
    sql: ${TABLE}.BILLING_APPROVED_MONTH ;;
  }

  dimension: BILLING_APPROVED_YEAR {
    type: string
    sql: ${TABLE}.BILLING_APPROVED_YEAR ;;
  }

  dimension: LINE_ITEM_TYPE {
    type: string
    sql: ${TABLE}.LINE_ITEM_TYPE ;;
  }

  dimension: COMPANY_ID {
    type: string
    sql: ${TABLE}.COMPANY_ID ;;
  }

  dimension: CUSTOMER_NAME {
    type: string
    sql: ${TABLE}.CUSTOMER_NAME ;;
  }

  dimension: INVOICE_ID {
    type: number
    value_format_name: id
    sql: ${TABLE}.INVOICE_ID ;;
  }

  dimension: INVOICE_NO {
    type: string
    html: <a style="color:blue" href="https://admin.equipmentshare.com/#/home/transactions/invoices/{{INVOICE_ID._value}}" target="_blank">{{value}}</a> ;;
    sql: ${TABLE}.INVOICE_ID ;;
  }

  dimension: REFERENCE {
    type: string
    sql: ${TABLE}.REFERENCE ;;
  }

  dimension: CREDIT_NOTE_ID {
    type: number
    value_format_name: id
    sql: ${TABLE}.CREDIT_NOTE_ID ;;
  }

  dimension: CREDIT_NOTE_NO {
    type: string
    html: <a style="color:red" href="https://admin.equipmentshare.com/#/home/transactions/credit-notes/{{CREDIT_NOTE_ID._value}}" target="_blank">{{value}}</a> ;;
    sql: ${TABLE}.CREDIT_NOTE_ID ;;
  }

  dimension: PAID {
    type: string
    sql: ${TABLE}.PAID ;;
  }

  dimension: REVENUE {
    type: number
    sql: ${TABLE}.REVENUE ;;
  }

  dimension: CREDITED {
    type: string
    sql: ${TABLE}.CREDITED ;;
  }


}
