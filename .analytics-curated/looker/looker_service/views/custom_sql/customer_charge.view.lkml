view: customer_charge {
    derived_table: {
      sql:with parts as ( --5/13/24 changing the cost logic source, WAC logic was killing the DB
select work_order_id wo_id
, sum(-quantity) parts_qty
, 0-round(sum(-quantity*weighted_average_cost),2) parts_cost
from ANALYTICS.INTACCT_MODELS.PART_INVENTORY_TRANSACTIONS t
                        join ES_WAREHOUSE.INVENTORY.INVENTORY_LOCATIONS l
  on t.store_id=l.inventory_location_id
          WHERE TRANSACTION_TYPE_ID IN (7, 9)
            and quantity is not null
            and date_cancelled is null
                          and l.company_id=1854
  and l.date_archived is null
group by wo_id)

, hours as (
select t.work_order_id
, sum(zeroifnull(T.REGULAR_HOURS) + zeroifnull(T.OVERTIME_HOURS)) TOTAL_HOURS
, round(total_hours*-64.40,2) hours_cost -- '23 72.77, '24 74.33, updating for '25
from "ES_WAREHOUSE"."TIME_TRACKING"."TIME_ENTRIES" t
join "ES_WAREHOUSE"."PUBLIC"."USERS" u
on t.user_id=u.user_id
where u.company_id=1854
and t.work_order_id is not null
  AND t.APPROVAL_STATUS = 'Approved'
 and t.EVENT_TYPE_ID = 1 --"on duty"
 and t.ARCHIVED_DATE is null
 and t.NEEDS_REVISION = false
group by t.work_order_id
)
,wo_detail as (
select wo.work_order_id
, branch_id
, is_dealership
, wo.asset_id
, c.company_id
, iff(es.company_id is null, 'External','Internal') asset_ownership
,case when vpp.PAYOUT_PROGRAM_ID in (8,12) then 'Paid Maintenance'
when vpp.asset_id is not null then 'Contractor'
when es.company_id is not null then 'ES'
else 'Customer'
end new_ownership
, billing_type_id
, date_billed
, date_completed
, invoice_number
, invoice_id
, parts_qty
, parts_cost
, total_hours
, zeroifnull(parts_cost)+zeroifnull(hours_cost) expense
, hours_cost
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
and work_order_type_id=1 --4/24/24 excluding inspections
)

, invoices as (
select v.branch_id
, m.is_dealership
, i.billing_approved_date date_billed
, v.invoice_id
, i.invoice_no as invoice_number
, sum(amount) revenue
, work_order_id
, parts_cost
, hours_cost
, expense
, revenue+zeroifnull(expense) profit_margin
, iff(line_item_type_id in(11,13),'Customer Repair','Customer Damage') charge_type
, coalesce(w.new_ownership, case when vpp.PAYOUT_PROGRAM_ID in (8,12) then 'Paid Maintenance'
when vpp.asset_id is not null then 'Contractor'
when esa.company_id is not null then 'ES'
else 'Customer'
end) ownership
, case when own.company_id is not null then 'Contractor'
when es.company_id is not null then 'ES'
else 'Customer' end invoice_company
, 'invoice' data_source
, v.asset_id
from "ANALYTICS"."PUBLIC"."V_LINE_ITEMS" v
join "ES_WAREHOUSE"."PUBLIC"."INVOICES" i
on v.invoice_id=i.invoice_id
  left join wo_detail w
on v.invoice_id=w.invoice_id
left join "ANALYTICS"."PUBLIC"."MARKET_REGION_XWALK" m
on v.branch_id =m.market_id
left join "ES_WAREHOUSE"."SCD"."SCD_ASSET_COMPANY" c
on v.asset_id=c.asset_id
and i.billing_approved_date between c.date_start and c.date_end
left join analytics.public.es_companies esa
on c.company_id=esa.company_id
left join analytics.public.es_companies es
on i.company_id=es.company_id
left join ES_WAREHOUSE.PUBLIC.V_PAYOUT_PROGRAMS VPP
on v.asset_id=vpp.asset_id
and i.billing_approved_date between VPP.START_DATE and COALESCE(VPP.END_DATE, '2099-12-31')
left join (SELECT DISTINCT AA.COMPANY_ID
FROM ES_WAREHOUSE.PUBLIC.V_PAYOUT_PROGRAMS VPP
JOIN ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE AA
ON VPP.ASSET_ID = AA.ASSET_ID
WHERE CURRENT_TIMESTAMP >= VPP.START_DATE
AND CURRENT_TIMESTAMP < COALESCE(VPP.END_DATE, '2099-12-31')) own
on i.company_id=own.company_id
where line_item_type_id in (11,13,25,26)
and i.billing_approved_date is not null
and es.company_id is null --getting rid of internal bills
--and own.company_id is null --getting rid of own billing ? but then we will still have own expenses??
group by v.branch_id,m.is_dealership
  ,i.billing_approved_date, v.invoice_id,i.invoice_no, work_order_id, parts_cost, hours_cost, expense, charge_type,ownership, invoice_company, data_source, v.asset_id --, date_billed
order by revenue desc)

, wos_no_invoice_tie as (
select w.branch_id
, w.is_dealership
, w.date_billed
, w.invoice_id
, w.invoice_number
,0 as revenue
, w.work_order_id
, w.parts_cost
, w.hours_cost
, w.expense
, zeroifnull(w.expense) profit_margin
, case when w.new_ownership in ('ES','Contractor','Paid Maintenance') and w.work_order_id in (select distinct work_order_id
from "ES_WAREHOUSE"."WORK_ORDERS"."WORK_ORDER_COMPANY_TAGS"
where company_tag_id=23 and deleted_on is null) then 'Customer Damage'
--when billing_type_id=2 and w.new_ownership in ('ES') then 'Customer Damage' --'Rerouted Customer Damage' --should this be taken out??
when billing_type_id=2 and w.new_ownership='Customer' and w.is_dealership then 'Customer Repair' else 'review' end fo_service_type
  , case when w.work_order_id in (select distinct work_order_id
from "ES_WAREHOUSE"."WORK_ORDERS"."WORK_ORDER_COMPANY_TAGS"
where company_tag_id=23 and deleted_on is null) then 'Customer Damage'
  when billing_type_id=2 and w.asset_ownership='Internal' then 'Customer Damage' --'Rerouted Customer Damage'
  when billing_type_id=2 then 'Customer Repair' else null end w_service_type
, w.new_ownership
, w.asset_id
from wo_detail w
left join invoices d
on w.work_order_id=d.work_order_id
where w_service_type is not null
and d.work_order_id is null
and w.date_billed is not null)
, total as (
select
branch_id
, is_dealership
, date_billed
, invoice_id
, invoice_number
, revenue
, work_order_id
, parts_cost
, hours_cost
, expense
, profit_margin
, case when --charge_type='Customer Repair' and
ownership= 'Customer' and invoice_company='Customer' and is_dealership then 'Customer Repair'
when --charge_type='Customer Damage' and
ownership in ('ES','Contractor','Paid Maintenance') and invoice_company='Customer' then 'Customer Damage'
else 'review' end
 fo_service_type
  , charge_type service_type
,  ownership
,  invoice_company
, data_source
, asset_id
from invoices
union
select branch_id
, is_dealership
, date_billed
, invoice_id
, invoice_number
, revenue
, work_order_id
, parts_cost
, hours_cost
, expense
, profit_margin
  , fo_service_type
, w_service_type service_type
, new_ownership ownership
, 'No Customer Invoice' invoice_company
, 'work order' data_source
, asset_id
from wos_no_invoice_tie
)

select *
from total t
join "ANALYTICS"."PUBLIC"."MARKET_REGION_XWALK" m
on t.branch_id=m.market_id
where market_name not like '%Hard Down';;
    }

    dimension: fo_service_type { # for financial overview, more criteria for customer charge than service dashboard
      type:  string
      sql: ${TABLE}.fo_service_type ;;
    }

    measure: margin_perc {
      type: number
      sql: (${revenue_no_html}/(-${expense_no_html}))-1 ;;
      value_format: "0.00%"
    }

    dimension: branch_id {
      type: string
      sql:  ${TABLE}.branch_id ;;
    }

    dimension_group: billed {
      type: time
      timeframes: [raw, date, week, month, quarter, year]
      sql: ${TABLE}.date_billed ;;
    }

    dimension: invoice_id {
      type: string
      sql: ${TABLE}.invoice_id ;;
    }

    dimension: invoice_number {
      type:  string
      sql:  ${TABLE}.invoice_number ;;
    }

    measure: revenue {
      type:  sum
      value_format: "$#,##0"
      html: {{revenue._rendered_value}} of {{ytd_revenue._rendered_value}} Customer Revenue YTD ;;
      sql: ${TABLE}.revenue ;;
      drill_fields: [detail*]
    }

    dimension: work_order_id {
      type: string
      sql:  ${TABLE}.work_order_id ;;
    }

    dimension: asset_id {
      type: number
      value_format_name: id
      sql: ${TABLE}.asset_id ;;
    }

    measure: parts_cost {
      type:  sum
      value_format: "$#,##0"
      sql: ${TABLE}.parts_cost ;;
    }

    measure: hours_cost {
      type: sum
      value_format: "$#,##0"
      sql: ${TABLE}.hours_cost ;;
    }
    measure: expense {
      type: sum
      value_format: "$#,##0"
      html: {{expense._rendered_value}} of {{ytd_expense._rendered_value}} Customer Expenses YTD ;;
      sql: ${TABLE}.expense ;;
      drill_fields: [detail*]
    }
    measure: profit_margin {
      type: sum
      value_format: "$#,##0"
      html: {{profit_margin._rendered_value}} of {{ytd_profit_margin._rendered_value}} Customer Profit Margin YTD ;;
      sql: ${TABLE}.profit_margin ;;
      drill_fields: [detail*]
    }

    measure: ytd_revenue {
      type: running_total
      sql: ${revenue};;
      value_format_name: usd_0
    }
    measure: ytd_expense {
      type: running_total
      sql: ${expense};;
      value_format_name: usd_0
    }
    measure: ytd_profit_margin {
      type: running_total
      sql: ${profit_margin};;
      value_format_name: usd_0
    }
    dimension: service_type {
      type: string
      sql: ${TABLE}.service_type ;;
    }
    measure: revenue_no_html {
      label: "Revenue"
      type:  sum
      value_format: "$#,##0"
      sql: ${TABLE}.revenue ;;
    }
    measure: expense_no_html {
      label: "Expense"
      type: sum
      value_format: "$#,##0"
      sql: ${TABLE}.expense ;;
    }
    measure: margin_no_html {
      label: "Margin"
      type: sum
      value_format: "$#,##0"
      sql: ${TABLE}.profit_margin ;;
    }
    set: detail {
      fields: [market_region_xwalk.market_name, branch_id, billed_date, invoice_id, invoice_number, service_type, revenue_no_html, work_order_id, expense_no_html, margin_no_html]
    }
  }
