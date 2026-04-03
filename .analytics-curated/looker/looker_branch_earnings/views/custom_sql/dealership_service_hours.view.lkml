view: dealership_service_hours {
  derived_table: {
    sql:
with relevant_wo as (
select vpp.PAYOUT_PROGRAM_ID
     , c.company_id
     , wo.*
 from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
 join ES_WAREHOUSE.PUBLIC.MARKETS m on wo.BRANCH_ID = m.MARKET_ID
 join ES_WAREHOUSE.SCD.SCD_ASSET_COMPANY c on wo.asset_id = c.asset_id and wo.date_billed between c.date_start and c.date_end
 left join analytics.public.ES_COMPANIES esc on c.COMPANY_ID = esc.COMPANY_ID
 join ES_WAREHOUSE.PUBLIC.V_PAYOUT_PROGRAMS vpp on wo.asset_id = vpp.asset_id  and wo.date_billed between vpp.start_date and coalesce(vpp.end_date, '9999-12-31')
 left join ANALYTICS.SERVICE.EZ_AML_WO_EXCLUSIONS ex on wo.work_order_id = ex.work_order_id
 left join ANALYTICS.SERVICE.OWN_WO_INVOICED_SUMMARY oex on wo.WORK_ORDER_ID = oex.work_order_id
 where wo.archived_date is null
  and vpp.payout_program_id in (1, 3, 4, 6, 7) --flex 70,flex80,plus,flex60,advantage max(legacy) --from andrew cowherd
  --and wo.date_billed::date between $beg_of and $end_of
  and m.COMPANY_ID = 1854                      --work is completed by ES
  and esc.COMPANY_ID is null                   --not owned by es
  and ex.work_order_id is null                 --not captured in previous process that had went off of first closure date
  and oex.work_order_id is null --not pulled in previous period current process)
)

, invoices as (
select i.invoice_id
     , i.INVOICE_NO
     , po.name as reference
     , i.LINE_ITEM_AMOUNT
 from ES_WAREHOUSE.PUBLIC.INVOICES i
 left join ANALYTICS.PUBLIC.ES_COMPANIES c on i.company_id=c.company_id
 left join ES_WAREHOUSE.PUBLIC.PURCHASE_ORDERS po on po.purchase_order_id = i.purchase_order_id
 where i.invoice_no not like '%deleted%'
  and c.company_id is null
  --and i.BILLING_APPROVED_DATE::date<=$end_of and (i.paid_date is null or i.PAID_DATE::date<=$end_of) --this is to get the same invoices even if report had to be rerun
 group by 1,2,3,4)

, warranty_retool as (
select rw.WORK_ORDER_ID
     , i.invoice_id
     , 'Warranty Retool' as connected_by
 from ANALYTICS.WARRANTIES.RETOOL_CLAIMS rw
 join INVOICES i
    on trim(rw.invoice_no) = i.invoice_no
    join relevant_wo wo
    on rw.WORK_ORDER_ID=wo.WORK_ORDER_ID)

, wo_note as (
select won.work_order_id
     , i.invoice_id
     ,  iff(upper(note) ilike '%MANUAL INVOICE #%'
            , replace(upper(note), 'MANUAL INVOICE #', '')
            , replace(upper(note), 'WARRANTY INVOICE #', '')
     ) as invoice_number_note
     , lead(won.date_created) over (partition by won.work_order_id order by won.date_created asc) next_note_date
     , 'WO Note' as connected_by
 from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDER_NOTES won
 join INVOICES i on i.invoice_no = trim(invoice_number_note)
 join relevant_wo wo on wo.WORK_ORDER_ID=won.WORK_ORDER_ID
 where won.note  ilike any ('%MANUAL INVOICE #%', 'WARRANTY INVOICE #%' )
 qualify next_note_date is null)

 ,id as (
    select wo.work_order_id work_order_id
        , i.invoice_id
        , 'Invoice ID' as connected_by
    from relevant_wo wo
    join invoices i
        on i.invoice_id = wo.invoice_id
)
, no as (
    select wo.work_order_id as work_order_id
        , i.invoice_id
        , 'Invoice Number' as Connected_by
    from relevant_wo wo
    join invoices i
        on ltrim(replace(REGEXP_REPLACE(wo.invoice_number,'[A-z]',''),'-000',''), ':#/-_,$.* ') = replace(i.invoice_no, '-000','')
)
, iref as (
    select wo.work_order_id as work_order_id
        , i.invoice_id
        , 'Invoice Reference' as Connected_by
    from relevant_wo wo
    join invoices i
        on SUBSTRING(i.reference, POSITION('WO-' IN i.reference) + 3, 7)= to_char(wo.work_order_id)
   or SUBSTRING(i.reference, POSITION('WO# ' IN i.reference) + 4, 7) =to_char(wo.work_order_id)
    where i.reference ilike '%WO%'
)

, comb_wo_invoice_map as (
select invoice_id, work_order_id , 'retool' as tie from warranty_retool
union
select invoice_id, work_order_id, 'wo note' as tie from wo_note
union
select invoice_id, work_order_id, 'id' as tie  from id
union
select invoice_id, work_order_id, 'number' as tie from no
union
select invoice_id, work_order_id, 'ref' as tie from iref)

, wo_max_invoice as(
select woi.work_order_id
     , max(woi.invoice_id) as invoice_id
 from comb_wo_invoice_map woi
 group by all)

, intercompany_invoices as(
select distinct invoice_id
 from analytics.intacct_models.INT_ADMIN_INVOICE_AND_CREDIT_LINE_DETAIL
 where is_intercompany = true)

select rm.retail_territory
    , m.region_name as region
    , m.district
    , m.market_id
    , m.market_name
    , tt.time_entry_id
    , tt.start_date::date as date
    , date_trunc(month,tt.start_date::date) as gl_month
    , cd.employee_id
    , cd.employee_title
    , split_part(cd.DEFAULT_COST_CENTERS_FULL_PATH,'/',-1) as dept
    , (case
        when cd.wage_type ilike '%salar%' then 'salary'
        else 'hourly'
       end) as wage_type
    , tt.work_order_id
    , wo.work_order_status_name as work_order_status
    , coalesce(bt.name, 'Unassigned') as billing_type
    , coalesce(wo.invoice_id,woi.invoice_id) as invoice_id
    , (case
        when tt.work_order_id is not null and bt.name in('Warranty','Customer') then 'Billable Hours'
        when tt.work_order_id is not null and bt.name not in('Warranty','Customer') then 'Internal Assigned Hours'
        else 'Unassigned Hours'
       end) as hours_type
    , tt.regular_hours
    , tt.overtime_hours
from analytics.intacct_models.stg_es_warehouse_time_tracking__time_entries tt
 join es_warehouse.public.users u on tt.user_id = u.user_id
 join analytics.payroll.stg_analytics_payroll__company_directory cd on u.employee_id = cd.employee_id::text
 left join analytics.intacct_models.stg_es_warehouse_work_orders__work_orders wo on tt.work_order_id = wo.work_order_id
 left join analytics.intacct_models.stg_es_warehouse_work_orders__billing_types bt on wo.billing_type_id = bt.billing_type_id
 left join wo_max_invoice woi on tt.work_order_id = woi.work_order_id
 left join intercompany_invoices ii on coalesce(wo.invoice_id,woi.invoice_id) = ii.invoice_id
 join analytics.branch_earnings.market m on cd.market_id = m.child_market_id
 join analytics.dbt_seeds.seed_retail_market_map rm on m.market_id = rm.market_id
 where tt.approval_status = 'Approved'
  and tt.event_type_id = 1
  and cd.employee_title ilike any('%technician%','%mechanic%')
  and date_trunc(month,tt.start_date::date) >= '2024-01-01'
      ;;
  }

  dimension: retail_territory {
    type: string
    sql: ${TABLE}."RETAIL_TERRITORY" ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: market_id {
    label: "MarketID"
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: time_entry_id {
    label: "TimeEntryID"
    type: string
    sql: ${TABLE}."TIME_ENTRY_ID" ;;
  }

  dimension: date {
    label: "Date"
    type: date
    sql: ${TABLE}."DATE" ;;
  }

  dimension_group: date {
    type: time
    timeframes: [raw, date, week, month, quarter, year, month_name]
    sql: ${TABLE}."DATE" ;;
  }

  dimension: employee_id {
    label: "EmployeeID"
    type: string
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }

  dimension: employee_title {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }

  dimension: dept {
    type: string
    sql: ${TABLE}."DEPT" ;;
  }

  dimension: wage_type {
    type: string
    sql: ${TABLE}."WAGE_TYPE" ;;
  }

  dimension: work_order_id {
    label: "Work Order ID"
    type: string
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }

  dimension: work_order_status {
    label: "Work Order Status"
    type: string
    sql: ${TABLE}."WORK_ORDER_STATUS" ;;
  }

  dimension: billing_type {
    label: "Billing Type"
    type: string
    sql: ${TABLE}."BILLING_TYPE" ;;
  }

  dimension: invoice_id {
    label: "InvoiceID"
    type: string
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: hours_type {
    type: string
    sql: ${TABLE}."HOURS_TYPE" ;;
  }

  measure: regular_hours {
    type: sum
    value_format_name: decimal_2
    drill_fields: [drill_fields*]
    sql: ${TABLE}."REGULAR_HOURS" ;;
  }

  measure: overtime_hours {
    type: sum
    value_format_name: decimal_2
    drill_fields: [drill_fields*]
    sql: ${TABLE}."OVERTIME_HOURS" ;;
  }

  measure: total_hours {
    type: sum
    value_format_name: decimal_2
    drill_fields: [drill_fields*]
    sql: ${TABLE}."REGULAR_HOURS" + ${TABLE}."OVERTIME_HOURS" ;;
  }

  measure: labor_expense {
    type: number
    value_format_name: decimal_2
    drill_fields: [drill_fields*]
    sql: sum(case when ${TABLE}."BILLING_TYPE" = 'Warranty' then (${TABLE}."REGULAR_HOURS" + ${TABLE}."OVERTIME_HOURS")*140
                  else (${TABLE}."REGULAR_HOURS" + ${TABLE}."OVERTIME_HOURS")*100
             end);;
  }

  measure: assigned_hours {
    type: sum
    value_format_name: decimal_2
    drill_fields: [drill_fields*]
    sql: case when ${TABLE}."HOURS_TYPE" in('Billable Hours','Internal Assigned Hours') then (${TABLE}."REGULAR_HOURS" + ${TABLE}."OVERTIME_HOURS") else 0 end ;;
  }

  measure: py_assigned_hours {
    type: sum
    value_format_name: decimal_2
    drill_fields: [drill_fields*]
    sql: case
          when ${TABLE}."HOURS_TYPE" in('Billable Hours','Internal Assigned Hours')
           and year(${TABLE}."DATE") = year(current_date) - 1
            then (${TABLE}."REGULAR_HOURS" + ${TABLE}."OVERTIME_HOURS") else 0 end ;;
  }

  measure: cy_assigned_hours {
    type: sum
    value_format_name: decimal_2
    drill_fields: [drill_fields*]
    sql: case
          when ${TABLE}."HOURS_TYPE" in('Billable Hours','Internal Assigned Hours')
           and year(${TABLE}."DATE") = year(current_date)
            then (${TABLE}."REGULAR_HOURS" + ${TABLE}."OVERTIME_HOURS") else 0 end ;;
  }

  measure: assigned_hours_pct {
    type: number
    value_format_name: percent_2
    drill_fields: [drill_fields*]
    sql: sum(case when ${TABLE}."HOURS_TYPE" in('Billable Hours','Internal Assigned Hours') then (${TABLE}."REGULAR_HOURS" + ${TABLE}."OVERTIME_HOURS") else 0 end)/nullifzero(sum(${TABLE}."REGULAR_HOURS" + ${TABLE}."OVERTIME_HOURS")) ;;
  }

  measure: py_assigned_hours_pct {
    type: number
    value_format_name: percent_2
    drill_fields: [drill_fields*]
    sql: sum(case when ${TABLE}."HOURS_TYPE" in('Billable Hours','Internal Assigned Hours')
              and year(${TABLE}."DATE") = year(current_date) - 1
               then (${TABLE}."REGULAR_HOURS" + ${TABLE}."OVERTIME_HOURS") else 0 end)
         /nullifzero(sum(case when year(${TABLE}."DATE") = year(current_date) - 1 then ${TABLE}."REGULAR_HOURS" + ${TABLE}."OVERTIME_HOURS" else 0 end)) ;;
  }

  measure: cy_assigned_hours_pct {
    type: number
    value_format_name: percent_2
    drill_fields: [drill_fields*]
    sql: sum(case when ${TABLE}."HOURS_TYPE" in('Billable Hours','Internal Assigned Hours')
              and year(${TABLE}."DATE") = year(current_date)
               then (${TABLE}."REGULAR_HOURS" + ${TABLE}."OVERTIME_HOURS") else 0 end)
         /nullifzero(sum(case when year(${TABLE}."DATE") = year(current_date) then ${TABLE}."REGULAR_HOURS" + ${TABLE}."OVERTIME_HOURS" else 0 end)) ;;
  }

  measure: unassigned_hours {
    type: sum
    value_format_name: decimal_2
    drill_fields: [drill_fields*]
    sql: case when ${TABLE}."HOURS_TYPE" in('Unassigned Hours') then (${TABLE}."REGULAR_HOURS" + ${TABLE}."OVERTIME_HOURS") else 0 end ;;
  }

  measure: py_unassigned_hours {
    type: sum
    value_format_name: decimal_2
    drill_fields: [drill_fields*]
    sql: case when ${TABLE}."HOURS_TYPE" in('Unassigned Hours')
          and year(${TABLE}."DATE") = year(current_date) - 1 then (${TABLE}."REGULAR_HOURS" + ${TABLE}."OVERTIME_HOURS")
          else 0 end ;;
  }

  measure: cy_unassigned_hours {
    type: sum
    value_format_name: decimal_2
    drill_fields: [drill_fields*]
    sql: case when ${TABLE}."HOURS_TYPE" in('Unassigned Hours')
          and year(${TABLE}."DATE") = year(current_date) then (${TABLE}."REGULAR_HOURS" + ${TABLE}."OVERTIME_HOURS")
          else 0 end ;;
  }

  measure: unassigned_hours_pct {
    type: number
    value_format_name: percent_2
    drill_fields: [drill_fields*]
    sql: sum(case when ${TABLE}."HOURS_TYPE" in('Unassigned Hours') then (${TABLE}."REGULAR_HOURS" + ${TABLE}."OVERTIME_HOURS") else 0 end)/nullifzero(sum(${TABLE}."REGULAR_HOURS" + ${TABLE}."OVERTIME_HOURS")) ;;
  }

  measure: py_unassigned_hours_pct {
    type: number
    value_format_name: percent_2
    drill_fields: [drill_fields*]
    sql: sum(case when ${TABLE}."HOURS_TYPE" in('Unassigned Hours')
              and year(${TABLE}."DATE") = year(current_date) - 1
               then (${TABLE}."REGULAR_HOURS" + ${TABLE}."OVERTIME_HOURS") else 0 end)
         /nullifzero(sum(case when year(${TABLE}."DATE") = year(current_date) - 1 then ${TABLE}."REGULAR_HOURS" + ${TABLE}."OVERTIME_HOURS" else 0 end)) ;;
  }

  measure: cy_unassigned_hours_pct {
    type: number
    value_format_name: percent_2
    drill_fields: [drill_fields*]
    sql: sum(case when ${TABLE}."HOURS_TYPE" in('Unassigned Hours')
              and year(${TABLE}."DATE") = year(current_date)
               then (${TABLE}."REGULAR_HOURS" + ${TABLE}."OVERTIME_HOURS") else 0 end)
         /nullifzero(sum(case when year(${TABLE}."DATE") = year(current_date) then ${TABLE}."REGULAR_HOURS" + ${TABLE}."OVERTIME_HOURS" else 0 end)) ;;
  }

  measure: billable_hours {
    type: sum
    value_format_name: decimal_2
    drill_fields: [drill_fields*]
    sql: case when ${TABLE}."HOURS_TYPE" in('Billable Hours') then (${TABLE}."REGULAR_HOURS" + ${TABLE}."OVERTIME_HOURS") else 0 end ;;
  }

  measure: py_billable_hours {
    type: sum
    value_format_name: decimal_2
    drill_fields: [drill_fields*]
    sql: case when ${TABLE}."HOURS_TYPE" in('Billable Hours')
               and year(${TABLE}."DATE") = year(current_date) - 1
                then (${TABLE}."REGULAR_HOURS" + ${TABLE}."OVERTIME_HOURS") else 0 end ;;
  }

  measure: cy_billable_hours {
    type: sum
    value_format_name: decimal_2
    drill_fields: [drill_fields*]
    sql: case when ${TABLE}."HOURS_TYPE" in('Billable Hours')
               and year(${TABLE}."DATE") = year(current_date)
                then (${TABLE}."REGULAR_HOURS" + ${TABLE}."OVERTIME_HOURS") else 0 end ;;
  }

  measure: billable_hours_pct {
    type: number
    value_format_name: percent_2
    drill_fields: [drill_fields*]
    sql: sum(case when ${TABLE}."HOURS_TYPE" in('Billable Hours') then (${TABLE}."REGULAR_HOURS" + ${TABLE}."OVERTIME_HOURS") else 0 end)/nullifzero(sum(${TABLE}."REGULAR_HOURS" + ${TABLE}."OVERTIME_HOURS")) ;;
  }

  measure: py_billable_hours_pct {
    type: number
    value_format_name: percent_2
    drill_fields: [drill_fields*]
    sql: sum(case when ${TABLE}."HOURS_TYPE" in('Billable Hours')
                   and year(${TABLE}."DATE") = year(current_date) - 1
                    then (${TABLE}."REGULAR_HOURS" + ${TABLE}."OVERTIME_HOURS") else 0 end)
         /nullifzero(sum(case when year(${TABLE}."DATE") = year(current_date) - 1 then ${TABLE}."REGULAR_HOURS" + ${TABLE}."OVERTIME_HOURS" else 0 end)) ;;
  }

  measure: cy_billable_hours_pct {
    type: number
    value_format_name: percent_2
    drill_fields: [drill_fields*]
    sql: sum(case when ${TABLE}."HOURS_TYPE" in('Billable Hours')
                   and year(${TABLE}."DATE") = year(current_date)
                    then (${TABLE}."REGULAR_HOURS" + ${TABLE}."OVERTIME_HOURS") else 0 end)
         /nullifzero(sum(case when year(${TABLE}."DATE") = year(current_date) then ${TABLE}."REGULAR_HOURS" + ${TABLE}."OVERTIME_HOURS" else 0 end)) ;;
  }

  measure: unbilled_assigned_hours {
    type: sum
    value_format_name: decimal_2
    drill_fields: [drill_fields*]
    sql: case when ${TABLE}."HOURS_TYPE" in('Internal Assigned Hours') then (${TABLE}."REGULAR_HOURS" + ${TABLE}."OVERTIME_HOURS") else 0 end ;;
  }

  measure: py_unbilled_assigned_hours {
    type: sum
    value_format_name: decimal_2
    drill_fields: [drill_fields*]
    sql: case when ${TABLE}."HOURS_TYPE" in('Internal Assigned Hours')
               and year(${TABLE}."DATE") = year(current_date) - 1
                then (${TABLE}."REGULAR_HOURS" + ${TABLE}."OVERTIME_HOURS") else 0 end ;;
  }

  measure: cy_unbilled_assigned_hours {
    type: sum
    value_format_name: decimal_2
    drill_fields: [drill_fields*]
    sql: case when ${TABLE}."HOURS_TYPE" in('Internal Assigned Hours')
               and year(${TABLE}."DATE") = year(current_date)
                then (${TABLE}."REGULAR_HOURS" + ${TABLE}."OVERTIME_HOURS") else 0 end ;;
  }

  measure: unbilled_assigned_hours_pct {
    type: number
    value_format_name: percent_2
    drill_fields: [drill_fields*]
    sql: sum(case when ${TABLE}."HOURS_TYPE" in('Internal Assigned Hours') then (${TABLE}."REGULAR_HOURS" + ${TABLE}."OVERTIME_HOURS") else 0 end)/nullifzero(sum(${TABLE}."REGULAR_HOURS" + ${TABLE}."OVERTIME_HOURS")) ;;
  }

  measure: py_unbilled_assigned_hours_pct {
    type: number
    value_format_name: percent_2
    drill_fields: [drill_fields*]
    sql: sum(case when ${TABLE}."HOURS_TYPE" in('Internal Assigned Hours')
                   and year(${TABLE}."DATE") = year(current_date) - 1
                    then (${TABLE}."REGULAR_HOURS" + ${TABLE}."OVERTIME_HOURS") else 0 end)
         /nullifzero(sum(case when year(${TABLE}."DATE") = year(current_date) - 1 then ${TABLE}."REGULAR_HOURS" + ${TABLE}."OVERTIME_HOURS" else 0 end)) ;;
  }

  measure: cy_unbilled_assigned_hours_pct {
    type: number
    value_format_name: percent_2
    drill_fields: [drill_fields*]
    sql: sum(case when ${TABLE}."HOURS_TYPE" in('Internal Assigned Hours')
                   and year(${TABLE}."DATE") = year(current_date)
                    then (${TABLE}."REGULAR_HOURS" + ${TABLE}."OVERTIME_HOURS") else 0 end)
         /nullifzero(sum(case when year(${TABLE}."DATE") = year(current_date) then ${TABLE}."REGULAR_HOURS" + ${TABLE}."OVERTIME_HOURS" else 0 end)) ;;
  }

  measure: work_order_count {
    type: number
    drill_fields: [drill_fields*]
    sql: count(${TABLE}."WORK_ORDER_ID") ;;
  }

  set: drill_fields {
    fields: [
      retail_territory,
      market,
      invoice_id,
      time_entry_id,
      employee_id,
      employee_title,
      dept,
      wage_type,
      hours_type,
      billing_type,
      regular_hours,
      overtime_hours,
      work_order_id,
      invoice_id
    ]
  }

}
