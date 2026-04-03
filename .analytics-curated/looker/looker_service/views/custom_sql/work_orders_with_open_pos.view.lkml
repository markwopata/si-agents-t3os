view: work_orders_with_open_pos {
  derived_table: {
    sql:
select distinct wo.work_order_id
from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
left join PROCUREMENT.PUBLIC.PURCHASE_ORDER_LINE_ITEMS poli
    on poli.allocation_type ilike 'work_order'
        and poli.allocation_id = wo.work_order_id
left join PROCUREMENT.PUBLIC.PURCHASE_ORDERS po
    on po.purchase_order_id = poli.purchase_order_id
where po.date_archived is null
    and po.status = 'OPEN'
    and poli.quantity <> (poli.total_accepted + poli.total_rejected) ;;
  }
  dimension: work_order_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.work_order_id ;;
  }

  dimension: has_open_po {
    type: yesno
    sql: iff(${work_order_id} is not null, TRUE, FALSE)  ;;
  }
}
