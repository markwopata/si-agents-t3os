view: wo_expense_vs_revenue {
  derived_table: {
    sql: with parts as ( --5/13/24 changing the cost logic source, WAC logic was killing the DB
select
    work_order_id as wo_id,
    sum(quantity) parts_qty,
    0-round(sum(quantity*weighted_average_cost),2) as parts_cost
from ANALYTICS.INTACCT_MODELS.PART_INVENTORY_TRANSACTIONS t
join ES_WAREHOUSE.INVENTORY.INVENTORY_LOCATIONS l
    on t.store_id=l.inventory_location_id
WHERE TRANSACTION_TYPE_ID IN (7, 9)
and quantity is not null
and date_cancelled is null
and l.company_id = 1854
and l.date_archived is null
group by
    wo_id
)

,hours as (
select
    t.work_order_id,
    sum(zeroifnull(T.REGULAR_HOURS) + zeroifnull(T.OVERTIME_HOURS)) as TOTAL_HOURS,
    round(total_hours*72.77,2) as hours_cost -- confirm labor rate with matt
from "ES_WAREHOUSE"."TIME_TRACKING"."TIME_ENTRIES" t
join "ES_WAREHOUSE"."PUBLIC"."USERS" u
    on t.user_id=u.user_id
where u.company_id = 1854
and t.work_order_id is not null
AND t.APPROVAL_STATUS = 'Approved'
and t.EVENT_TYPE_ID = 1 --"on duty"
and t.ARCHIVED_DATE is null
and t.NEEDS_REVISION = false
group by
    t.work_order_id
)

,wo_detail as (
select
    wo.work_order_id,
    branch_id,
    is_dealership,
    wo.asset_id,
    c.company_id,
    iff(es.company_id is null, 'External','Internal') as asset_ownership,
    case
        when vpp.PAYOUT_PROGRAM_ID in (8,12) then 'Paid Maintenance'
        when vpp.asset_id is not null then 'Contractor'
        when es.company_id is not null then 'ES'
        else 'Customer'
    end as new_ownership,
    billing_type_id,
    date_billed,
    date_completed,
    invoice_number,
    invoice_id,
    parts_qty,
    parts_cost,
    total_hours,
    zeroifnull(parts_cost)+zeroifnull(hours_cost) as expense,
    hours_cost
from "ES_WAREHOUSE"."WORK_ORDERS"."WORK_ORDERS" wo
left join "ANALYTICS"."PUBLIC"."MARKET_REGION_XWALK" m
    on wo.branch_id=m.market_id
left join "ES_WAREHOUSE"."SCD"."SCD_ASSET_COMPANY" c
    on wo.asset_id=c.asset_id
    and wo.date_completed between c.date_start and c.date_end
left join analytics.public.es_companies es
    on c.company_id=es.company_id
left join ES_WAREHOUSE.PUBLIC.V_PAYOUT_PROGRAMS VPP
    on wo.asset_id=vpp.asset_id
    and wo.date_completed between VPP.START_DATE and COALESCE(VPP.END_DATE, '2099-12-31')
left join hours h
    on wo.work_order_id =h.work_order_id
left join parts p
    on wo.work_order_id=p.wo_id
where archived_date is null
and wo.asset_id is not null
-- and work_order_type_id=1 --4/24/24 excluding inspections
)

select
    wo.work_order_id,
    wo.asset_id,
    i.invoice_id,
    i.invoice_no,
    m.market_id,
    i.billing_approved_date,
    i.company_id,
    wo.description,
    wo.billing_type_id,
    sum(li.amount) as revenue,
    wd.expense,
    wd.expense - revenue as difference,
    iff(difference > 0, difference, 0) as missed_opportunity
from es_warehouse.public.invoices i
join es_warehouse.public.line_items li
    on i.invoice_id = li.invoice_id
join ( select wo.*, coalesce(i1.invoice_id, i2.invoice_id) as final_invoice_id from es_warehouse.work_orders.work_orders wo
            left join ES_WAREHOUSE.PUBLIC.INVOICES i1
                on i1.invoice_id = wo.invoice_id
            left join ES_WAREHOUSE.PUBLIC.INVOICES i2
                on replace(i2.invoice_no, '-000','') = ltrim(replace(REGEXP_REPLACE(wo.invoice_number,'[A-z]',''),'-000',''), ':#/-_,$.* ')) wo
    on i.invoice_id = wo.final_invoice_id
join es_warehouse.public.markets m
    on wo.branch_id = m.market_id
inner join wo_detail wd --
    on wo.work_order_id = wd.work_order_id
where m.company_id = 1854
and wd.expense != 0
and i.company_id not in (select company_id from analytics.public.es_companies)
and li.line_item_type_id in (11,13,25,26)
group by
    wo.work_order_id,
    i.invoice_id,
    i.invoice_no,
    wo.asset_id,
    i.company_id,
    m.market_id,
    wo.description,
    wo.billing_type_id,
    i.billing_approved_date,
    wd.expense ;;
  }
  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
    value_format: "0"
    html: <a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="new" style="color: #0063f3; text-decoration: underline;">{{ work_order_id._value }}</a> ;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    value_format: "0"
  }
  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
    value_format: "0"
    html: <font color="blue "><u><a href="https://admin.equipmentshare.com/#/home/transactions/invoices/{{ invoice_id }}" target="_blank">{{rendered_value}}</a></font></u> ;;
  }
  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NO" ;;
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
    value_format: "0"
  }
  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
    value_format: "0"
  }
  dimension: billing_type_id {
    type: number
    sql: ${TABLE}."BILLING_TYPE_ID" ;;
    value_format: "0"
  }
  dimension: wo_description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }
  dimension_group: billing_approved_date {
    type: time
    timeframes: [raw,date,month,quarter,year]
    sql: ${TABLE}."BILLING_APPROVED_DATE" ;;
  }
  dimension: revenue {
    type: number
    sql: ${TABLE}."REVENUE" ;;
    value_format: "$0.00"
  }
  dimension: expense {
    type: number
    sql: ${TABLE}."EXPENSE" ;;
    value_format: "$0.00"
  }
  dimension: difference {
    type: number
    sql: ${TABLE}."EXPENSE" ;;
    value_format: "$0.00"
  }
  dimension: missed_opportunity {
    type: number
    sql: ${TABLE}."MISSED_OPPORTUNITY" ;;
    value_format: "$0.00"
  }
  measure: sum_of_revenue {
    type: sum
    sql: ${revenue} ;;
    value_format: "$0.00"
  }
  measure: sum_of_expense {
    type: sum
    sql: ${expense} ;;
    value_format: "$0.00"
  }
  measure: sum_of_differece {
    type: sum
    sql: ${difference} ;;
    value_format: "$0.00"
  }
  measure: sum_of_missed_opportunity {
    type: sum
    sql: ${missed_opportunity} ;;
    value_format: "$0.00"
    drill_fields: [invoice_id,invoice_number,companies.name,billing_approved_date_date,work_order_id,wo_description,billing_types.name,asset_id,market_region_xwalk.region_name,market_region_xwalk.district,market_region_xwalk.market_name,expense,revenue]
  }
}
