view: t3aas_admin_revenue {
  derived_table: {
    sql:

with credits as (
select
    ABS(AMOUNT) as CREDIT,
    INVOICE_ID,
    LINE_ITEM_ID
from
    analytics.intacct_models.Int_admin_invoice_and_credit_line_detail
where
    MARKET_ID = '79502'
    and CREDIT_NOTE_ID is not null
)

, invoice_lines as (
select
    invoices.BILLING_APPROVED_DATE,
    invoices.IS_BILLING_APPROVED,
    MONTH(invoices.BILLING_APPROVED_DATE::DATE) as BILLING_APPROVED_MONTH,
    YEAR(invoices.BILLING_APPROVED_DATE::DATE) as BILLING_APPROVED_YEAR,
    invoices.LINE_ITEM_TYPE_NAME,
    invoices.LINE_ITEM_TYPE_ID,
    invoices.COMPANY_ID,
    invoices.CUSTOMER_NAME,
    invoices.INVOICE_ID,
    invoices.INVOICE_NUMBER as INVOICE_NO,
    invoices.INVOICE_MEMO as REFERENCE,
    case
        when invoices.PAID_DATE is not null then 'TRUE'
        when invoices.PAID_DATE is null then 'FALSE'
    end as PAID,
    invoices.AMOUNT as REVENUE,
    case
        when credits.Credit is null then 0
        else credits.CREDIT
    end as PAID_CREDITED,
    CONCAT(invoices.COMPANY_ID, MONTH(invoices.BILLING_APPROVED_DATE::DATE), YEAR(invoices.BILLING_APPROVED_DATE::DATE)) AS Identifier
from
    analytics.intacct_models.Int_admin_invoice_and_credit_line_detail invoices
left join
    credits
    on invoices.invoice_id = credits.invoice_id
    and invoices.line_item_id = credits.LINE_ITEM_ID
where
    invoices.MARKET_ID = '79502'
    and invoices.LINE_ITEM_TYPE_ID IN (33)
    and invoices.BILLING_APPROVED_DATE::DATE >= '2020-01-01'
    and invoices.COMPANY_ID <> '1854'
    and invoices.LINE_ITEM_DESCRIPTION not ilike '%Early Termination%'
    and invoices.AMOUNT > 0
ORDER BY
  invoices.BILLING_APPROVED_DATE::DATE,
  invoices.LINE_ITEM_TYPE_ID,
  invoices.COMPANY_ID,
  invoices.INVOICE_ID,
  invoices.INVOICE_NUMBER
)

, paid_totals as (
select
    billing_approved_month,
    billing_approved_year,
    company_id,
    customer_name,
    paid,
    sum(revenue) as revenue
from
    invoice_lines
where
    paid = 'TRUE'
group by
    billing_approved_month,
    billing_approved_year,
    company_id,
    paid,
    customer_name
)

, unpaid_totals as (
select
    billing_approved_month,
    billing_approved_year,
    company_id,
    customer_name,
    paid,
    sum(revenue) as revenue
from
    invoice_lines
where
    paid = 'FALSE'
group by
    billing_approved_month,
    billing_approved_year,
    company_id,
    paid,
    customer_name
)

, billed_totals as (
select
    billing_approved_month,
    billing_approved_year,
    company_id,
    customer_name,
    null as paid,
    sum(revenue) as revenue
from
    invoice_lines
group by
    billing_approved_month,
    billing_approved_year,
    company_id,
    customer_name
)

, credited_totals as (
select
    billing_approved_month,
    billing_approved_year,
    company_id,
    customer_name,
    paid,
    -1 * sum(PAID_CREDITED) as credited
from
    invoice_lines
where
    PAID_CREDITED > 0
group by
    billing_approved_month,
    billing_approved_year,
    company_id,
    paid,
    customer_name
)

, rental_revenue_lines as (
select
    MONTH(invoices.BILLING_APPROVED_DATE::DATE) as BILLING_APPROVED_MONTH,
    YEAR(invoices.BILLING_APPROVED_DATE::DATE) as BILLING_APPROVED_YEAR,
    invoices.COMPANY_ID,
    AMOUNT as RENTAL_REVENUE
from
    analytics.intacct_models.Int_admin_invoice_and_credit_line_detail invoices
left join
    analytics.t3_saas_billing.customer_master
    on customer_master.COMPANY_ID = invoices.company_id
where
    invoices.LINE_ITEM_TYPE_ID in ('6','8', '108', '109')
    and customer_master.company_id is not null
    and invoices.IS_BILLING_APPROVED = 'TRUE'
    and invoices.IS_RENTAL_REVENUE = 'TRUE'
    and invoices.PAID_DATE is not null
    and DATE(invoices.BILLING_APPROVED_DATE) < DATE(CURRENT_TIMESTAMP)
)

, rental_revenue_totals as (
select
    BILLING_APPROVED_MONTH,
    BILLING_APPROVED_YEAR,
    COMPANY_ID,
    SUM(RENTAL_REVENUE) as RENTAL_REVENUE
from
    rental_revenue_lines
group by
    BILLING_APPROVED_MONTH,
    BILLING_APPROVED_YEAR,
    COMPANY_ID
)

, revenue_totals as (
select
    billed_totals.BILLING_APPROVED_MONTH,
    billed_totals.BILLING_APPROVED_YEAR,
    billed_totals.COMPANY_ID,
    billed_totals.CUSTOMER_NAME,
    paid_totals.REVENUE as PAID_REVENUE,
    billed_totals.REVENUE as BILLED_REVENUE,
    unpaid_totals.REVENUE as UNPAID_REVENUE,
    credited_totals.CREDITED
from
    billed_totals
left join
    paid_totals
    on paid_totals.COMPANY_ID = billed_totals.COMPANY_ID
    and paid_totals.BILLING_APPROVED_MONTH = billed_totals.BILLING_APPROVED_MONTH
    and paid_totals.BILLING_APPROVED_YEAR = billed_totals.BILLING_APPROVED_YEAR
left join
    unpaid_totals
    on paid_totals.COMPANY_ID = unpaid_totals.COMPANY_ID
    and paid_totals.BILLING_APPROVED_MONTH = unpaid_totals.BILLING_APPROVED_MONTH
    and paid_totals.BILLING_APPROVED_YEAR = unpaid_totals.BILLING_APPROVED_YEAR
left join
    credited_totals
    on paid_totals.COMPANY_ID = credited_totals.COMPANY_ID
    and paid_totals.BILLING_APPROVED_MONTH = credited_totals.BILLING_APPROVED_MONTH
    and paid_totals.BILLING_APPROVED_YEAR = credited_totals.BILLING_APPROVED_YEAR

)

, sum_booked_invoices as (
select
    COMPANY_ID as COMPANY_ID,
    CHARGE_TYPE,
    sum(INVOICE_LINE_TOTAL) as BOOKED_REVENUE,
    MONTH(INVOICE_DATE) as INVOICE_MONTH,
    YEAR(INVOICE_DATE) as INVOICE_YEAR
from
    analytics.t3_saas_billing.booked_invoices
group by
    COMPANY_ID,
    CHARGE_TYPE,
    INVOICE_DATE
)

, sum_booked_invoices_saas as (
select
    *
from
    sum_booked_invoices
where
    CHARGE_TYPE = 'Telematics Subscription-Only (SAAS)'
)

, sum_booked_invoices_non_saas as (
select
    *
from
    sum_booked_invoices
where
    CHARGE_TYPE != 'Telematics Subscription-Only (SAAS)'
)

, admin_revenue_saas as (
select
    sum_booked_invoices_saas.COMPANY_ID,
    sum_booked_invoices_saas.CHARGE_TYPE,
    companies.name as COMPANY_NAME,
    case
        when sum_booked_invoices_saas.INVOICE_MONTH = 1 then 'January'
        when sum_booked_invoices_saas.INVOICE_MONTH = 2 then 'February'
        when sum_booked_invoices_saas.INVOICE_MONTH = 3 then 'March'
        when sum_booked_invoices_saas.INVOICE_MONTH = 4 then 'April'
        when sum_booked_invoices_saas.INVOICE_MONTH = 5 then 'May'
        when sum_booked_invoices_saas.INVOICE_MONTH = 6 then 'June'
        when sum_booked_invoices_saas.INVOICE_MONTH = 7 then 'July'
        when sum_booked_invoices_saas.INVOICE_MONTH = 8 then 'August'
        when sum_booked_invoices_saas.INVOICE_MONTH = 9 then 'September'
        when sum_booked_invoices_saas.INVOICE_MONTH = 10 then 'October'
        when sum_booked_invoices_saas.INVOICE_MONTH = 11 then 'November'
        when sum_booked_invoices_saas.INVOICE_MONTH = 12 then 'December'
        end as INVOICE_MONTH,
    sum_booked_invoices_saas.INVOICE_MONTH as NUMERIC_INVOICE_MONTH,
    sum_booked_invoices_saas.INVOICE_YEAR,
    sum_booked_invoices_saas.BOOKED_REVENUE,
    revenue_totals.BILLED_REVENUE,
    revenue_totals.PAID_REVENUE,
    revenue_totals.UNPAID_REVENUE,
    revenue_totals.CREDITED,
    rental_revenue_totals.RENTAL_REVENUE
from
    sum_booked_invoices_saas
left join
    revenue_totals
    on revenue_totals.COMPANY_ID = sum_booked_invoices_saas.COMPANY_ID
    and revenue_totals.BILLING_APPROVED_MONTH = sum_booked_invoices_saas.INVOICE_MONTH
    and revenue_totals.BILLING_APPROVED_YEAR = sum_booked_invoices_saas.INVOICE_YEAR
left join
    rental_revenue_totals
    on rental_revenue_totals.COMPANY_ID = sum_booked_invoices_saas.COMPANY_ID
    and rental_revenue_totals.BILLING_APPROVED_MONTH = sum_booked_invoices_saas.INVOICE_MONTH
    and rental_revenue_totals.BILLING_APPROVED_YEAR = sum_booked_invoices_saas.INVOICE_YEAR
left join
    es_warehouse.public.companies companies
    on companies.company_id = sum_booked_invoices_saas.company_id
)

, admin_revenue_non_saas as (
select
    sum_booked_invoices_non_saas.COMPANY_ID,
    sum_booked_invoices_non_saas.CHARGE_TYPE,
    companies.name as COMPANY_NAME,
    case
        when sum_booked_invoices_non_saas.INVOICE_MONTH = 1 then 'January'
        when sum_booked_invoices_non_saas.INVOICE_MONTH = 2 then 'February'
        when sum_booked_invoices_non_saas.INVOICE_MONTH = 3 then 'March'
        when sum_booked_invoices_non_saas.INVOICE_MONTH = 4 then 'April'
        when sum_booked_invoices_non_saas.INVOICE_MONTH = 5 then 'May'
        when sum_booked_invoices_non_saas.INVOICE_MONTH = 6 then 'June'
        when sum_booked_invoices_non_saas.INVOICE_MONTH = 7 then 'July'
        when sum_booked_invoices_non_saas.INVOICE_MONTH = 8 then 'August'
        when sum_booked_invoices_non_saas.INVOICE_MONTH = 9 then 'September'
        when sum_booked_invoices_non_saas.INVOICE_MONTH = 10 then 'October'
        when sum_booked_invoices_non_saas.INVOICE_MONTH = 11 then 'November'
        when sum_booked_invoices_non_saas.INVOICE_MONTH = 12 then 'December'
        end as INVOICE_MONTH,
    sum_booked_invoices_non_saas.INVOICE_MONTH as NUMERIC_INVOICE_MONTH,
    sum_booked_invoices_non_saas.INVOICE_YEAR,
    sum_booked_invoices_non_saas.BOOKED_REVENUE,
    null as BILLED_REVENUE,
    null as PAID_REVENUE,
    null as UNPAID_REVENUE,
    null as CREDITED,
    null as RENTAL_REVENUE
from
    sum_booked_invoices_non_saas
left join
    es_warehouse.public.companies companies
    on companies.company_id = sum_booked_invoices_non_saas.company_id
)

, results_union as (
select * from admin_revenue_saas
union
select * from admin_revenue_non_saas
)

, int_final_results as (
select
    CONCAT(results_union.COMPANY_ID, ' - ', results_union.CHARGE_TYPE, ' - ', results_union.INVOICE_MONTH, ' - ', results_union.INVOICE_YEAR) as UNIQUE_IDENTIFIER,
    '1' as INVOICE_DAY,
    results_union.*
from
    results_union
)

select
    *,
    DATE_FROM_PARTS(INVOICE_YEAR, NUMERIC_INVOICE_MONTH, INVOICE_DAY) as INVOICE_DATE
from
    int_final_results
    ;;
  }

  dimension: UNIQUE_IDENTIFIER {
    type: string
    sql: ${TABLE}.UNIQUE_IDENTIFIER ;;
  }

  dimension: COMPANY_ID {
    type: string
    sql: ${TABLE}.COMPANY_ID ;;
  }

  dimension: COMPANY_NAME {
    type: string
    sql: ${TABLE}.COMPANY_NAME ;;
  }

  dimension: CHARGE_TYPE {
    type: string
    sql: ${TABLE}.CHARGE_TYPE ;;
  }


  dimension: INVOICE_MONTH {
    type: string
    sql: ${TABLE}.INVOICE_MONTH ;;
  }

  dimension: INVOICE_YEAR {
    type: string
    sql: ${TABLE}.INVOICE_YEAR ;;
  }

  dimension: INVOICE_DATE {
    type: date
    sql: ${TABLE}.INVOICE_DATE ;;
  }

  dimension: BOOKED_REVENUE {
    type: number
    sql: ${TABLE}.BOOKED_REVENUE ;;
  }

  dimension: BILLED_REVENUE {
    type: number
    sql: ${TABLE}.BILLED_REVENUE ;;
  }

  dimension: PAID_REVENUE {
    type: number
    sql: ${TABLE}.PAID_REVENUE ;;
  }

  dimension: UNPAID_REVENUE {
    type: number
    sql: ${TABLE}.UNPAID_REVENUE;;
  }

  dimension: CREDITED {
    type: number
    sql: ${TABLE}.CREDITED;;
  }

  dimension: RENTAL_REVENUE {
    type: number
    sql: ${TABLE}.RENTAL_REVENUE;;
  }

}
