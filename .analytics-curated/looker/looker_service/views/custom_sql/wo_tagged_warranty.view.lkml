view: wo_tagged_warranty {
  derived_table: {
    sql: with wo_tag_count as (
            select
              work_order_id,
              name as tag_name,
              count(*) as tag_count
            from
              ES_WAREHOUSE.work_orders.work_orders_by_tag wobt
            where
              name = 'Warranty'
            group by
              work_order_id,
              name
            )
            select
              work_order_id,
              tag_name,
              case when tag_count >= 1 then 1 end as warranty_flag
            from
              wo_tag_count
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }

  dimension: tag_name {
    type: string
    sql: ${TABLE}."TAG_NAME" ;;
  }

  dimension: warranty_flag {
    type: number
    sql: ${TABLE}."WARRANTY_FLAG" ;;
  }

  dimension: wo_has_warranty_tag {
    type: yesno
    sql: ${warranty_flag} = 1 ;;
  }

    set: detail {
      fields: [work_order_id, tag_name, warranty_flag]
    }
  }
