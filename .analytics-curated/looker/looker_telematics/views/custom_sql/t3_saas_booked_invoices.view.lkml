view: t3_saas_booked_invoices{
  derived_table: {
    sql:
with all_booked_invoices as (
select
booked_invoices.COMPANY_ID,
companies.NAME as CUSTOMER_NAME,
booked_invoices.INVOICE_DATE,
MONTH(INVOICE_DATE) as INVOICE_MONTH,
YEAR(INVOICE_DATE) as INVOICE_YEAR,
booked_invoices.PO_REFERENCE,
booked_invoices.CHARGE_TYPE,
booked_invoices.SUBSCRIPTION_LINE_ITEM_ID,
booked_invoices.DESCRIPTION,
booked_invoices.QTY,
booked_invoices.UNIT_PRICE,
booked_invoices.INVOICE_LINE_TOTAL
from analytics.t3_saas_billing.booked_invoices
left join es_warehouse.public.companies companies
on booked_invoices.COMPANY_ID = companies.COMPANY_ID
)

, all_booked_invoices_with_month as (
select
all_booked_invoices.COMPANY_ID,
all_booked_invoices.CUSTOMER_NAME,
all_booked_invoices.INVOICE_DATE,
case
        when all_booked_invoices.INVOICE_MONTH = 1 then 'January'
        when all_booked_invoices.INVOICE_MONTH = 2 then 'February'
        when all_booked_invoices.INVOICE_MONTH = 3 then 'March'
        when all_booked_invoices.INVOICE_MONTH = 4 then 'April'
        when all_booked_invoices.INVOICE_MONTH = 5 then 'May'
        when all_booked_invoices.INVOICE_MONTH = 6 then 'June'
        when all_booked_invoices.INVOICE_MONTH = 7 then 'July'
        when all_booked_invoices.INVOICE_MONTH = 8 then 'August'
        when all_booked_invoices.INVOICE_MONTH = 9 then 'September'
        when all_booked_invoices.INVOICE_MONTH = 10 then 'October'
        when all_booked_invoices.INVOICE_MONTH = 11 then 'November'
        when all_booked_invoices.INVOICE_MONTH = 12 then 'December'
        end as INVOICE_MONTH,
all_booked_invoices.INVOICE_YEAR,
all_booked_invoices.PO_REFERENCE,
all_booked_invoices.CHARGE_TYPE,
all_booked_invoices.SUBSCRIPTION_LINE_ITEM_ID,
all_booked_invoices.DESCRIPTION,
all_booked_invoices.QTY,
all_booked_invoices.UNIT_PRICE,
all_booked_invoices.INVOICE_LINE_TOTAL
from
all_booked_invoices
)

select * from all_booked_invoices_with_month
    ;;}

  dimension: COMPANY_ID {
    type: string
    sql: ${TABLE}.COMPANY_ID ;;
  }

  dimension: CUSTOMER_NAME {
    type: string
    sql: ${TABLE}.CUSTOMER_NAME ;;
  }

  dimension: INVOICE_DATE {
    type: date
    sql: ${TABLE}.INVOICE_DATE ;;
  }

  dimension: PO_REFERENCE {
    type: string
    sql: ${TABLE}.PO_REFERENCE ;;
  }

  dimension: CHARGE_TYPE {
    type: string
    sql: ${TABLE}.CHARGE_TYPE ;;
  }

  dimension: SUBSCRIPTION_LINE_ITEM_ID {
    type: string
    sql: ${TABLE}.SUBSCRIPTION_LINE_ITEM_ID ;;
  }

  dimension: DESCRIPTION {
    type: string
    sql: ${TABLE}.DESCRIPTION ;;
  }

  dimension: QTY {
    type: number
    sql: ${TABLE}.QTY ;;
  }

  dimension: UNIT_PRICE {
    type: number
    sql: ${TABLE}.UNIT_PRICE ;;
  }

  dimension: INVOICE_LINE_TOTAL {
    type: number
    sql: ${TABLE}.INVOICE_LINE_TOTAL ;;
  }

  dimension: INVOICE_MONTH {
    type: string
    sql: ${TABLE}.INVOICE_MONTH ;;
  }

  dimension: INVOICE_YEAR {
    type: string
    sql: ${TABLE}.INVOICE_YEAR ;;
  }

}
