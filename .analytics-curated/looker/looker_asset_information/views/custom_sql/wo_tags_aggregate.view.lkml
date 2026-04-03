# Original wo_tags_aggregate created by Jack 4/29/22 is from the service project.  This was brought over here 5/5/25 for use.
view: wo_tags_aggregate {
  derived_table: {
    sql:
    SELECT wo.work_order_id,
           wo.work_order_status_id,
           LISTAGG(t.name, ', ') AS tags,
           COUNT(*)              AS total_tags
    FROM es_warehouse.work_orders.work_orders wo
    INNER JOIN es_warehouse.work_orders.work_order_company_tags ct
      ON ct.work_order_id = wo.work_order_id
    INNER JOIN es_warehouse.work_orders.company_tags t
      ON t.company_tag_id = ct.company_tag_id
    INNER JOIN es_warehouse.public.assets a
      ON wo.asset_id = a.asset_id
    INNER JOIN es_warehouse.public.markets m
      ON a.service_branch_id = m.market_id
    WHERE m.company_id = 1854 --only assets that we service
    --AND wo.date_created >= DATEADD('year', -2, CURRENT_DATE()) --HL 2.19.25 taking this out since it is used in the WO information explore which needs to see all work order history
    AND wo.archived_date IS NULL
    GROUP BY wo.work_order_id, wo.work_order_status_id;;
  }

  dimension: work_order_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }

  dimension: tags {
    type: string
    sql: ${TABLE}."TAGS" ;;
  }

  # 1-open, 2-pending, 3-closed, 4-billed
  dimension: work_order_status_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_STATUS_ID" ;;
  }

  measure: total_tags {
    type: sum
    sql: ${TABLE}."TOTAL_TAGS" ;;
  }

  measure: total_outside_service {
    type: count_distinct
    filters: [work_order_status_id: "1, 2", tags: "%outside repair%"]
    sql: ${work_order_id} ;;
    drill_fields: [
      work_orders.date_created_date,
      work_orders.work_order_id_with_link_to_work_order,
      assets.asset_id_wo_link,
      tags,
      market_region_xwalk.market_name
    ]
  }
}
