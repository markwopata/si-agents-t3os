view: fleet_track_allocations {
  derived_table: {
    sql: SELECT cpoli.MARKET_ID,
       aa.EQUIPMENT_CLASS_ID,
       sum(cpoli.QUANTITY) as QUANTITY
FROM ES_WAREHOUSE.PUBLIC.COMPANY_PURCHASE_ORDER_LINE_ITEMS cpoli
left join (select distinct equipment_model_id, equipment_class_id from es_warehouse.public.assets_aggregate) aa on
    cpoli.equipment_class_id = aa.equipment_class_id or cpoli.equipment_model_id = aa.equipment_model_id
where cpoli.order_status in ('Okay to Ship','Shipped')
group by cpoli.MARKET_ID, aa.EQUIPMENT_CLASS_ID
;;
  }

# dimension: market_id_x_class {
#   primary_key: yes
#   type: string
#   sql: concat(${market_id}, ${name}) ;;
# }

dimension: market_id {
  type: number
  sql: ${TABLE}.MARKET_ID ;;
}

# dimension: name {
#   type: string
#   sql: ${TABLE}.NAME ;;
# }

dimension: equipment_class_id {
  type: number
  sql: ${TABLE}.EQUIPMENT_CLASS_ID ;;
}

dimension: quantity {
  type: number
  sql: ${TABLE}.QUANTITY ;;
}

# measure: sum {
#   type: sum
#   sql:quantity ;;
# }
 }
