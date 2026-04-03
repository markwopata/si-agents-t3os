view: subscription_revenue_detail {

  derived_table: {
    sql:
       --DETAIL
with esdb_line_items_telematics as (
select
    INVOICE_ID,
    LINE_ITEM_ID,
    CAST(NUMBER_OF_UNITS as DECIMAL(15,2)) as NUMBER_OF_UNITS,
    CAST(PRICE_PER_UNIT as DECIMAL(15,2)) as PRICE_PER_UNIT
from
    es_warehouse.public.line_items
where
    LINE_ITEM_TYPE_ID in (30,31,32,33,34,157)
)

, esdb_line_items_forsight as (
select
    INVOICE_ID,
    LINE_ITEM_ID,
    CAST(NUMBER_OF_UNITS as DECIMAL(15,2)) as NUMBER_OF_UNITS,
    CAST(PRICE_PER_UNIT as DECIMAL(15,2)) as PRICE_PER_UNIT
from
    es_warehouse.public.line_items
where
    LINE_ITEM_TYPE_ID = '8'
    and DESCRIPTION LIKE '%Solar Security Plant%'
)

, esdb_line_items as (
select * from esdb_line_items_telematics
union
select * from esdb_line_items_forsight
)

, credit_lines as (
select
    ABS(Int_admin_invoice_and_credit_line_detail.AMOUNT) as CREDIT,
    Int_admin_invoice_and_credit_line_detail.CREDIT_NOTE_ID,
    Int_admin_invoice_and_credit_line_detail.INVOICE_ID,
    Int_admin_invoice_and_credit_line_detail.LINE_ITEM_ID,
    esdb_line_items.NUMBER_OF_UNITS,
    esdb_line_items.PRICE_PER_UNIT,
    case
        when credit_notes.SENT = 'FALSE' then 'Cancelled'
        when credit_notes.SENT = 'TRUE' then 'Credited'
    end as STATUS
from
    analytics.intacct_models.Int_admin_invoice_and_credit_line_detail
left join
    esdb_line_items
    on esdb_line_items.LINE_ITEM_ID = Int_admin_invoice_and_credit_line_detail.LINE_ITEM_ID
left join
    es_warehouse.public.credit_notes
    on Int_admin_invoice_and_credit_line_detail.CREDIT_NOTE_ID = credit_notes.CREDIT_NOTE_ID
where
    esdb_line_items.INVOICE_ID is not null and
    Int_admin_invoice_and_credit_line_detail.CREDIT_NOTE_ID is not null
    and Int_admin_invoice_and_credit_line_detail.AMOUNT != 0.00
)

, invoices as (
select
    invoices.XERO_ID,
    invoices.INVOICE_ID,
    invoices.PURCHASE_ORDER_ID
from
    es_warehouse.public.invoices
where
    COMPANY_ID <> '1854'
)

, credit_dates as (
select
    CREDIT_NOTE_ID,
    CREDIT_NOTE_DATE::DATE as CREDIT_NOTE_DATE
from
    es_warehouse.public.credit_notes
)

, il_telematics_dedup as (
-- written by AI --
-- Short version:
-- You still have a fan-out join because there are multiple rows in Int_admin_invoice_and_credit_line_detail per (INVOICE_ID, LINE_ITEM_ID), so each credit_lines row is joining to more than one il row.
-- That’s why you see 8 rows instead of the 4 you expect.
-- Since you only need one descriptive row per (INVOICE_ID, LINE_ITEM_ID), we can:
-- Build a de-duplicated invoice-lines CTE.
-- Join credit_lines to that instead of the raw Int_admin_invoice_and_credit_line_detail.
-- Because you’re in Snowflake (based on syntax), we can use QUALIFY row_number().
    select
        *
    from analytics.intacct_models.Int_admin_invoice_and_credit_line_detail il
    where
        il.LINE_ITEM_TYPE_ID in (30,31,32,33,34,157)
        and il.BILLING_APPROVED_DATE::DATE >= '2020-01-01'
        and il.COMPANY_ID <> '1854'
    qualify
        row_number() over (
            partition by il.INVOICE_ID, il.LINE_ITEM_ID
            order by il.BILLING_APPROVED_DATE desc
        ) = 1
)

, credits as (
select
        invoice_lines.BILLING_APPROVED_DATE::DATE as BILLING_APPROVED_DATE,
        month(invoice_lines.BILLING_APPROVED_DATE::DATE) as BILLING_APPROVED_MONTH,
        year(invoice_lines.BILLING_APPROVED_DATE::DATE) as BILLING_APPROVED_YEAR,
        invoice_lines.INVOICE_DATE::DATE as INVOICE_DATE,
        credit_dates.CREDIT_NOTE_DATE::DATE as CREDIT_NOTE_DATE,
        invoice_lines.LINE_ITEM_TYPE_NAME as LINE_ITEM_TYPE,
        invoice_lines.LINE_ITEM_TYPE_ID,
        '' as RECLASSIFICATION_STATUS,
        invoice_lines.LINE_ITEM_DESCRIPTION as DESCRIPTION,
        invoice_lines.COMPANY_ID,
        companies.NAME as CUSTOMER_NAME,
        invoice_lines.INVOICE_ID,
        invoice_lines.INVOICE_NUMBER as INVOICE_NO,
        credit_lines.CREDIT_NOTE_ID,
        invoices.XERO_ID,
        purchase_orders.NAME as REFERENCE,
        invoice_lines.INVOICE_MEMO,
        null as PAID,
        'TRUE' as CREDITED,
        NUMBER_OF_UNITS * -1 as QTY,
        PRICE_PER_UNIT as UNIT_PRICE,
        credit_lines.CREDIT * -1 as AMOUNT,
        invoice_lines.MARKET_ID,
        invoice_lines.MARKET_NAME,
        null as PAID_DATE
    from
        credit_lines
    join il_telematics_dedup invoice_lines
        on invoice_lines.INVOICE_ID = credit_lines.INVOICE_ID
       and invoice_lines.LINE_ITEM_ID = credit_lines.LINE_ITEM_ID
    left join es_warehouse.public.companies
        on companies.COMPANY_ID = invoice_lines.COMPANY_ID
    left join invoices
        on invoice_lines.INVOICE_ID = invoices.INVOICE_ID
    left join es_warehouse.public.purchase_orders purchase_orders
        on invoices.PURCHASE_ORDER_ID = purchase_orders.PURCHASE_ORDER_ID
    left join credit_dates
        on credit_lines.CREDIT_NOTE_ID = credit_dates.CREDIT_NOTE_ID
    where
        credit_lines.STATUS = 'Credited'
)

, invoice_lines_int_telematics as (
select
    invoice_lines.BILLING_APPROVED_DATE::DATE as BILLING_APPROVED_DATE,
    MONTH(invoice_lines.BILLING_APPROVED_DATE::DATE) as BILLING_APPROVED_MONTH,
    YEAR(invoice_lines.BILLING_APPROVED_DATE::DATE) as BILLING_APPROVED_YEAR,
    invoice_lines.INVOICE_DATE::DATE as INVOICE_DATE,
    null as CREDIT_NOTE_DATE,
    invoice_lines.LINE_ITEM_TYPE_NAME as LINE_ITEM_TYPE,
    invoice_lines.LINE_ITEM_TYPE_ID,
    '' as RECLASSIFICATION_STATUS,
    invoice_lines.LINE_ITEM_DESCRIPTION as DESCRIPTION,
    invoice_lines.COMPANY_ID,
    companies.NAME as CUSTOMER_NAME,
    invoice_lines.INVOICE_ID,
    invoice_lines.INVOICE_NUMBER as INVOICE_NO,
    null as CREDIT_NOTE_ID,
    invoices.XERO_ID,
    purchase_orders.NAME as REFERENCE,
    invoice_lines.INVOICE_MEMO,
    case
        when invoice_lines.PAID_DATE is not null then 'TRUE'
        when invoice_lines.PAID_DATE is null then 'FALSE'
    end as PAID,
    null as CREDITED,
    esdb_line_items_telematics.NUMBER_OF_UNITS as QTY,
    esdb_line_items_telematics.PRICE_PER_UNIT as UNIT_PRICE,
    invoice_lines.AMOUNT,
    invoice_lines.MARKET_ID,
    invoice_lines.MARKET_NAME,
    invoice_lines.PAID_DATE::DATE as PAID_DATE
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
    esdb_line_items_telematics
    on esdb_line_items_telematics.LINE_ITEM_ID = invoice_lines.LINE_ITEM_ID
    and esdb_line_items_telematics.INVOICE_ID = invoice_lines.INVOICE_ID
where
    invoice_lines.LINE_ITEM_TYPE_ID in (30,31,32,33,34,157)
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

, invoice_lines_int as (
select * from invoice_lines_int_telematics
union all
select * from credits
)

select
    case
        when CREDITED = 'TRUE' then null
        else invoice_lines_int.BILLING_APPROVED_DATE
    end as BILLING_APPROVED_DATE,
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
    invoice_lines_int.RECLASSIFICATION_STATUS,
    invoice_lines_int.COMPANY_ID,
    invoice_lines_int.CUSTOMER_NAME,
    case
        when invoice_lines_int.CREDIT_NOTE_ID is null then 'Blank'
        when invoice_lines_int.CREDIT_NOTE_ID is not null then cast(invoice_lines_int.CREDIT_NOTE_ID as STRING)
    end as CREDIT_NOTE_ID,
    invoice_lines_int.INVOICE_ID,
    invoice_lines_int.INVOICE_NO,
    invoice_lines_int.XERO_ID,
    case
        when CREDITED = 'TRUE' then null
        else invoice_lines_int.REFERENCE
    end as REFERENCE,
    case
        when CREDITED = 'TRUE' then null
        else invoice_lines_int.INVOICE_MEMO
    end as INVOICE_MEMO,
    invoice_lines_int.PAID,
    invoice_lines_int.QTY,
    invoice_lines_int.UNIT_PRICE,
    invoice_lines_int.AMOUNT,
    invoice_lines_int.CREDITED,
    invoice_lines_int.MARKET_ID,
    invoice_lines_int.MARKET_NAME,
    invoice_lines_int.PAID_DATE,
    case
        when CREDITED = 'TRUE' then CREDIT_NOTE_DATE
        else null
    end as CREDIT_NOTE_DATE,
    case
        when CREDITED = 'TRUE' then CREDIT_NOTE_DATE
        else invoice_lines_int.BILLING_APPROVED_DATE
    end as FINANCIAL_DATE
from
    invoice_lines_int

                             ;;
  }

   dimension: billing_approved_date {
    type: date
    sql: ${TABLE}.BILLING_APPROVED_DATE ;;
  }

  dimension: billing_approved_month {
    type: string
    sql: ${TABLE}.BILLING_APPROVED_MONTH ;;
  }

  dimension: billing_approved_year {
    type: number
    sql: ${TABLE}.BILLING_APPROVED_YEAR ;;
  }

  dimension: invoice_date {
    type: date
    sql: ${TABLE}.INVOICE_DATE ;;
  }

  dimension: CREDIT_NOTE_DATE {
    type: date
    sql: ${TABLE}.CREDIT_NOTE_DATE ;;
  }

  dimension: PAID_DATE {
    type: date
    sql: ${TABLE}.PAID_DATE ;;
  }

  dimension: FINANCIAL_DATE {
    type: date
    sql: ${TABLE}.FINANCIAL_DATE ;;
  }

  dimension: line_item_type {
    type: string
    sql: ${TABLE}.LINE_ITEM_TYPE ;;
  }

  dimension: line_item_type_id {
    type: number
    sql: ${TABLE}.LINE_ITEM_TYPE_ID ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}.description ;;
  }

  dimension: RECLASSIFICATION_STATUS {
    type: string
    sql: ${TABLE}.RECLASSIFICATION_STATUS ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}.COMPANY_ID ;;
  }

  dimension: customer_name {
    type: string
    sql: ${TABLE}.CUSTOMER_NAME ;;
  }

  dimension: CREDIT_NOTE_ID {
    type: string
    sql: ${TABLE}.CREDIT_NOTE_ID ;;
  }

  dimension: invoice_id {
    type: number
    sql: ${TABLE}.INVOICE_ID ;;
  }

  dimension: INVOICE_NO {
    type: string
    sql: ${TABLE}.INVOICE_NO ;;
  }

  dimension: xero_id {
    type: string
    sql: ${TABLE}.XERO_ID ;;
  }

  dimension: reference {
    type: string
    sql: ${TABLE}.REFERENCE ;;
  }

  dimension: invoice_memo {
    type: string
    sql: ${TABLE}.INVOICE_MEMO ;;
  }

  dimension: paid {
    type: string
    sql: ${TABLE}.PAID;;
  }

  dimension: QTY {
    type: number
    sql: ${TABLE}.QTY ;;
  }

  dimension: UNIT_PRICE {
    type: number
    sql: ${TABLE}.UNIT_PRICE ;;
  }

  dimension: AMOUNT {
    type: number
    sql: ${TABLE}.AMOUNT ;;
  }

  measure: revenue {
    type: sum
    sql: ${TABLE}.AMOUNT ;;
  }

  dimension: CREDITED {
    type: string
    sql: ${TABLE}.CREDITED ;;
  }

  dimension: MARKET_ID {
    type:  string
    sql:  ${TABLE}.MARKET_ID ;;
  }

  dimension: MARKET_NAME {
    type:  string
    sql:  ${TABLE}.MARKET_NAME ;;
  }
}
