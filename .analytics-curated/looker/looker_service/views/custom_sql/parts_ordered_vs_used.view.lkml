view: parts_ordered_vs_used {
  derived_table:{
    sql:with wo_trans AS
         (SELECT IFF(TRANSACTION_TYPE_ID = 7, t.TO_ID, t.FROM_ID) AS wo_id
               , ti.PART_ID                                       AS part_id
               , t.transaction_type_id                            AS transaction_type_id
               , t.TRANSACTION_ID
               , IFF(transaction_type_id = 7, ti.quantity_received, 0-ti.quantity_received)                  AS qty
          FROM ES_WAREHOUSE.INVENTORY.TRANSACTIONS t
          LEFT JOIN ES_WAREHOUSE.INVENTORY.TRANSACTION_ITEMS ti
              ON t.TRANSACTION_ID = ti.TRANSACTION_ID
          WHERE TRANSACTION_TYPE_ID IN (7, 9)
         -- and  wo_id =840707
            and qty is not null
          --and year(t.date_created)=2023
          )

, unused_parts as(
select wo_id
, count_if(transaction_type_id=9)/count_if(transaction_type_id=7) unused_parts_percent
from wo_trans wot
group by wo_id
order by wo_id
)
, allocated as(
  select allocation_id wo_id
, min(date_created) first_po_date
, max(date_created) last_po_date
, count(distinct(li.PURCHASE_ORDER_ID)) order_count
from "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_LINE_ITEMS" li
 inner join "PROCUREMENT"."PUBLIC"."PURCHASE_ORDERS" po
  on li.PURCHASE_ORDER_ID=po.PURCHASE_ORDER_ID
where allocation_type ='WORK_ORDER'
 -- and allocation_id =1959317
group by wo_id
  --, date_created
  )

select u.*
, first_po_date
, last_po_date
, order_count
from unused_parts u
left join allocated a --change to left join for now
on u.wo_id=a.wo_id
order by unused_parts_percent desc
  ;;
  }
  drill_fields: [detail*]

  dimension: wo_id {
    type: string
    primary_key: yes
    sql: ${TABLE}.wo_id ;;
  }

  dimension: unused_parts_percent {
    type: number
    sql: ${TABLE}.unused_parts_percent ;;
  }

  dimension: first_po_date {
    type: date
    sql: ${TABLE}.first_po_date ;;
  }

  dimension: last_po_date {
    type: date
    sql: ${TABLE}.last_po_date ;;
  }

  dimension: order_count {
    type: number
    sql: ${TABLE}.order_count ;;
  }

  measure: avg_unused_parts_percent {
    type: average
    sql: ${unused_parts_percent} ;;
  }

  measure: avg_order_count {
    type: average
    sql: ${order_count} ;;
  }
 set: detail {
  fields: [work_orders.work_order_id_with_link_to_work_order,unused_parts_percent, first_po_date, last_po_date, order_count]
  }
}
