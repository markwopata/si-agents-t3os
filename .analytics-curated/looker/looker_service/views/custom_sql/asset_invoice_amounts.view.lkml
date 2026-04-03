view: asset_invoice_amounts {
  derived_table: {
    sql: with all_invoice_ids as (
select
  invoice_id,
  branch_id
from
  line_items
where
  line_item_type_id in (13,25,26)
),
damage_parts_invoice_amt as (
select
  invoice_id,
  max(branch_id) as branch_id,
  sum(amount) as damage_parts_total_amt
from
  line_items li
where
  line_item_type_id in (25)
group by
  invoice_id
),
damage_labor_invoice_amt as (
select
  invoice_id,
  max(branch_id) as branch_id,
  sum(amount) as damage_labor_total_amt
from
  line_items li
where
  line_item_type_id in (26)
group by
  invoice_id
),
service_labor_invoice_amt as (
select
  invoice_id,
  max(branch_id) as branch_id,
  sum(amount) as service_labor_total_amt
from
  line_items li
where
  line_item_type_id in (13)
group by
  invoice_id
),
invoice_asset_info as (
select
  invoice_id,
  max(asset_id) as asset_id
from
  line_items li
where
  asset_id is not null
group by
  invoice_id
),
invoice_credited as (
select
invoice_id,
invoice_no,
left(invoice_no, strpos(invoice_no, '-') - 1) as trimmed_invoice_no,
paid,
date_created,
invoice_date
from
invoices i
where
  billing_approved_date is not null
),
combined_invoice_info as (
select
  ali.invoice_id,
  ali.branch_id,
  ai.asset_id,
  dp.damage_parts_total_amt,
  dl.damage_labor_total_amt,
  sl.service_labor_total_amt,
  ic.invoice_no,
  ic.trimmed_invoice_no,
  ic.paid,
  ic.date_created as invoice_date_created,
  ic.invoice_date
from
  all_invoice_ids ali
  left join damage_parts_invoice_amt dp on ali.invoice_id = dp.invoice_id
  left join damage_labor_invoice_amt dl on ali.invoice_id = dl.invoice_id
  left join service_labor_invoice_amt sl on ali.invoice_id = sl.invoice_id
  left join invoice_asset_info ai on ali.invoice_id = ai.invoice_id
  left join invoice_credited ic on ali.invoice_id = ic.invoice_id
 ),
 work_order_info as (
 select
  work_order_id,
  asset_id,
  work_order_status_name,
  date_updated as work_order_date_updated,
  branch_id as work_order_branch_id,
  invoice_number as wo_invoice_no,
  bt.name as billing_type_name,
  wot."name" as work_order_type_name,
  ROW_NUMBER() OVER (PARTITION BY invoice_number ORDER BY work_order_id DESC) AS rn
from
  work_orders.work_orders wo
  left join work_orders.billing_types bt on wo.billing_type_id = bt.billing_type_id
  left join work_orders.work_order_types wot on wot.work_order_type_id = wo.work_order_type_id
where
  archived_date is null
),
filter_bad_invoices as (
select
  ci.invoice_id,
  ci.invoice_no,
  case when wo_invoice_no like '%' || ci.trimmed_invoice_no || '%' then 1 end as invoice_match,
  ci.asset_id,
  ci.branch_id,
  ci.damage_parts_total_amt,
  ci.damage_labor_total_amt,
  ci.service_labor_total_amt,
  ci.paid,
  ci.invoice_date_created,
  work_order_id,
  work_order_status_name,
  billing_type_name,
  work_order_type_name
from
  combined_invoice_info ci
  inner join work_order_info wo on wo.asset_id = ci.asset_id and wo.work_order_branch_id = ci.branch_id and (ci.invoice_date_created between wo.work_order_date_updated - interval '6 hours' and wo.work_order_date_updated + interval '6 hours' or ci.invoice_date between wo.work_order_date_updated - interval '6 hours' and wo.work_order_date_updated + interval '6 hours')
     where
       wo.rn = 1
    ),
    filter_out_multiple_work_orders as (
    select
      invoice_id,
      invoice_no,
      fi.asset_id,
      branch_id,
      damage_parts_total_amt,
      damage_labor_total_amt,
      service_labor_total_amt,
      paid,
      invoice_date_created,
      work_order_id,
      work_order_status_name,
      billing_type_name,
      work_order_type_name,
      aa.oec,
      ROW_NUMBER() OVER (PARTITION BY invoice_no, fi.asset_id ORDER BY invoice_date_created DESC) AS rn
    from
      filter_bad_invoices fi
      left join assets_aggregate aa on fi.asset_id = aa.asset_id
    where
      invoice_match = 1
    )
    select
      invoice_id,
      invoice_no,
      asset_id,
      branch_id,
      damage_parts_total_amt,
      damage_labor_total_amt,
      service_labor_total_amt,
      paid,
      invoice_date_created,
      work_order_id,
      work_order_status_name,
      billing_type_name,
      work_order_type_name,
      oec
  from
    filter_out_multiple_work_orders
  where
    rn = 1
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: invoice_id {
    type: number
    sql: ${TABLE}."invoice_id" ;;
  }

  dimension: invoice_no {
    type: string
    sql: ${TABLE}."invoice_no" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."asset_id" ;;
  }

  dimension: branch_id {
    type: number
    sql: ${TABLE}."branch_id" ;;
  }

  dimension: damage_parts_total_amt {
    type: number
    sql: ${TABLE}."damage_parts_total_amt" ;;
  }

  dimension: damage_labor_total_amt {
    type: number
    sql: ${TABLE}."damage_labor_total_amt" ;;
  }

  dimension: service_labor_total_amt {
    type: number
    sql: ${TABLE}."service_labor_total_amt" ;;
  }

  dimension: paid {
    type: string
    sql: ${TABLE}."paid" ;;
  }

  dimension_group: invoice_date_created {
    type: time
    sql: ${TABLE}."invoice_date_created" ;;
  }

  dimension: work_order_id {
    type: number
    sql: ${TABLE}."work_order_id" ;;
  }

  dimension: work_order_status_name {
    type: string
    sql: ${TABLE}."work_order_status_name" ;;
  }

  dimension: billing_type_name {
    type: string
    sql: ${TABLE}."billing_type_name" ;;
  }

  dimension: oec {
    type: number
    sql: ${TABLE}."oec" ;;
    value_format_name: usd_0
    drill_fields: [asset_id]
  }

  dimension: work_order_type_name {
    type: string
    sql: ${TABLE}."work_order_type_name" ;;
  }

  measure: damage_labor_total {
    type: sum
    sql: ${damage_labor_total_amt} ;;
    value_format_name: usd_0
  }

  measure: service_labor_total {
    type: sum
    sql: ${service_labor_total_amt} ;;
    value_format_name: usd_0
  }

  measure: damage_parts_total {
    type: sum
    sql: ${damage_parts_total_amt} ;;
    value_format_name: usd_0
  }

  measure: asset_oec {
    type: max
    sql: case when ${oec} = 0 then null else ${oec} end ;;
    value_format_name: usd_0
  }

  measure: total_labor_and_parts {
    type: number
    sql: ${damage_labor_total} + ${service_labor_total} + ${damage_parts_total} ;;
    value_format_name: usd_0
  }

  measure: total_cost_vs_oec {
    type: number
    sql: ${total_labor_and_parts} / ${asset_oec} ;;
    value_format_name: percent_1
  }

  measure: percent_complete {
    type: number
    sql: 1.0*(${total_cost_vs_oec});;
    html: <div style="float: left
          ; width:{{ value | times:100}}%
          ; background-color: rgba(0,180,0,{{ value | times:100 }})
          ; text-align:left
          ; color: #FFFFFF
          ; border-radius: 5px"> <p style="margin-bottom: 0; margin-left: 4px;">{{ value | times:100 }}%</p>
          </div>
          <div style="float: left
          ; width:{{ 1| minus:value | times:100}}%
          ; background-color: rgba(0,180,0,0.1)
          ; text-align:right
          ; border-radius: 5px"> <p style="margin-bottom: 0; margin-left: 0px; color:rgba(0,0,0,0.0" )>{{value}}</p>
          </div>
      ;;
  }

  dimension: work_order_id_with_link_to_work_order {
    label: "Link to Work Order"
    type: string
    sql: ${work_order_id} ;;
    html: <font color="blue "><u><a href="https://app.estrack.com/#/home/service/work-orders/{{ work_order_id._value }}" target="_blank">{{ work_order_id._value }}</a></font></u> ;;
  }

  dimension: link_to_invoice {
    label: "Link to Invoice"
    type: string
    html: <font color="blue "><u><a href="https://admin.equipmentshare.com/#/home/transactions/invoices/search?query={{invoice_id}}" target="_blank">Link to Admin</a></font></u> ;;
    sql: ${invoice_id}  ;;
  }

  dimension: invoice_paid {
    type: yesno
    sql: ${paid} = true ;;
  }

  set: detail {
    fields: [
      invoice_id,
      invoice_no,
      asset_id,
      branch_id,
      damage_parts_total_amt,
      damage_labor_total_amt,
      service_labor_total_amt,
      paid,
      invoice_date_created_time,
      work_order_id,
      work_order_status_name,
      billing_type_name,
      oec
    ]
  }
}
