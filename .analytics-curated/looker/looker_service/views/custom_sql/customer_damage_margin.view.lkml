view: customer_damage_margin {
  derived_table: {
    sql: with prep_store_part_cost as (
         select STORE_PART_ID
              , STORE_PART_COST_ID
              , COST
              , DATE_ARCHIVED
              , DATE_CREATED
              , coalesce(lag(DATE_ARCHIVED::timestamp_ntz)
                             over (partition by STORE_PART_ID order by date_archived, STORE_PART_COST_ID),
                         0::timestamp_ntz)::timestamp_ntz                           as date_start
              , coalesce(DATE_ARCHIVED::timestamp_ntz, '2099-12-31'::timestamp_ntz) as date_end
         from ES_WAREHOUSE.INVENTORY.STORE_PART_COSTS
         order by STORE_PART_ID, STORE_PART_COST_ID
     )
, parts_trans AS (
         SELECT
         IFF(TRANSACTION_TYPE_ID = 7, t.TO_ID, t.FROM_ID) AS wo_id
          , IFF(TRANSACTION_TYPE_ID = 9, t.TO_ID, t.FROM_ID) as store_t_id
               , ti.PART_ID                                       AS part_id
               , sp.store_part_id
               , t.transaction_type_id                            AS transaction_type_id
               , t.TRANSACTION_ID
               , IFF(transaction_type_id = 7, ti.quantity_received, 0-ti.quantity_received)                  AS qty
          , qty*spc.cost transaction_cost
          ,last_day(t.date_completed) month_
          , t.date_completed
          FROM ES_WAREHOUSE.INVENTORY.TRANSACTIONS t
           JOIN ES_WAREHOUSE.INVENTORY.TRANSACTION_ITEMS ti
              ON t.TRANSACTION_ID = ti.TRANSACTION_ID
           join ES_WAREHOUSE.INVENTORY.STORE_PARTS sp
                       on store_t_id = sp.STORE_ID
                           and ti.PART_ID = sp.part_id
                  join prep_store_part_cost spc
                       on sp.STORE_PART_ID = spc.STORE_PART_ID
                           and t.DATE_completed >= spc.date_start
                           and t.DATE_completed < spc.date_end
  join ES_WAREHOUSE.INVENTORY.INVENTORY_LOCATIONS l
  on store_t_id=l.inventory_location_id
          WHERE TRANSACTION_TYPE_ID IN (7, 9)
            and qty is not null
            and t.date_cancelled is null
  and l.company_id=1854
  and l.date_archived is null
          )
, parts as (
select wo_id
, sum(qty) parts_qty
, 0-round(sum(transaction_cost),2) parts_cost
from parts_trans
group by wo_id
)
, hours as (
select t.work_order_id
, sum(T.REGULAR_HOURS + T.OVERTIME_HOURS) TOTAL_HOURS
, round(total_hours*-72.77,2) hours_cost -- confirm labor rate with matt
from "ES_WAREHOUSE"."TIME_TRACKING"."TIME_ENTRIES" t
join "ES_WAREHOUSE"."PUBLIC"."USERS" u
on t.user_id=u.user_id
where u.company_id=1854
and t.work_order_id is not null
group by t.work_order_id
)
, wo_detail as (
select wo.work_order_id
, branch_id
, asset_id
, billing_type_id
, date_billed
, date_completed
, invoice_number
, invoice_id
, parts_qty
, parts_cost
, total_hours
, zeroifnull(parts_cost)+zeroifnull(hours_cost) damage_expense
, hours_cost
from "ES_WAREHOUSE"."WORK_ORDERS"."WORK_ORDERS" wo
left join hours h
on wo.work_order_id =h.work_order_id
left join parts p
on wo.work_order_id=p.wo_id
where archived_date is null
and wo.asset_id is not null
)
, damage_invoices as (
     select v.branch_id
       , i.billing_approved_date date_billed
       , v.invoice_id
       , sum(amount) damage_revenue
       , work_order_id
       , parts_cost
       , hours_cost
       , damage_expense
       ,damage_revenue+zeroifnull(damage_expense) profit_margin
     from "ANALYTICS"."PUBLIC"."V_LINE_ITEMS" v
     join "ES_WAREHOUSE"."PUBLIC"."INVOICES" i
     on v.invoice_id=i.invoice_id
     left join analytics.public.es_companies c
     on i.company_id=c.company_id
     left join wo_detail w
     on v.invoice_id=w.invoice_id
     where line_item_type_id in (25,26)
     and i.billing_approved_date is not null
     and c.company_id is null --taking out internal bills
     group by v.branch_id,i.billing_approved_date, v.invoice_id, work_order_id, parts_cost, hours_cost, damage_expense
     )
, wos_no_invoice_tie as (
  select w.branch_id
  , w.date_billed
  , w.invoice_id
  ,0 as damage_revenue
  , w.work_order_id
  , w.parts_cost
  , w.hours_cost
  , w.damage_expense
  , zeroifnull(w.damage_expense) profit_margin
  from wo_detail w
  left join damage_invoices d
  on w.work_order_id=d.work_order_id
  where w.work_order_id in (select distinct work_order_id
from "ES_WAREHOUSE"."WORK_ORDERS"."WORK_ORDERS_BY_TAG"
where name ='Customer Damage')
and d.work_order_id is null
and w.date_billed is not null)
select * from damage_invoices
union
select * from wos_no_invoice_tie;;
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

measure: damage_revenue {
  type:  sum
  value_format: "$#,##0"
  html: {{damage_revenue._rendered_value}} of {{ytd_damage_revenue._rendered_value}} Customer Damage Revenue YTD ;;
  sql: ${TABLE}.damage_revenue ;;
  drill_fields: [detail*]
}

dimension: work_order_id {
  type: string
  sql:  ${TABLE}.work_order_id ;;
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
measure: damage_expense {
  type: sum
  value_format: "$#,##0"
  html: {{damage_expense._rendered_value}} of {{ytd_damage_expense._rendered_value}} Customer Damage Expenses YTD ;;
  sql: ${TABLE}.damage_expense ;;
  drill_fields: [detail*]
}
measure: damage_margin {
  type: sum
  value_format: "$#,##0"
  html: {{damage_margin._rendered_value}} of {{ytd_damage_margin._rendered_value}} Customer Damage Margin YTD ;;
  sql: ${TABLE}.profit_margin ;;
  drill_fields: [detail*]
}

  measure: ytd_damage_revenue {
    type: running_total
    sql: ${damage_revenue};;
    value_format_name: usd_0
  }
  measure: ytd_damage_expense {
    type: running_total
    sql: ${damage_expense};;
    value_format_name: usd_0
  }
  measure: ytd_damage_margin {
    type: running_total
    sql: ${damage_margin};;
    value_format_name: usd_0
  }
  measure: damage_revenue_no_html {
    label: "Damage Revenue"
    type:  sum
    value_format: "$#,##0"
    sql: ${TABLE}.damage_revenue ;;
    drill_fields: [detail*]
  }
  measure: damage_expense_no_html {
    label: "Damage Expense"
    type: sum
    value_format: "$#,##0"
    sql: ${TABLE}.damage_expense ;;
    drill_fields: [detail*]
  }
  measure: damage_margin_no_html {
    label: "Damage Margin"
    type: sum
    value_format: "$#,##0"
    sql: ${TABLE}.profit_margin ;;
    drill_fields: [detail*]
  }
  set: detail {
  fields: [branch_id,billed_date,invoice_id,damage_revenue_no_html,work_order_id, damage_expense_no_html, damage_margin_no_html]
  }
}
