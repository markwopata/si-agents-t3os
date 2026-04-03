view: assets_with_multiple_open_wos {
  derived_table: {
    sql:
      select asset_id, count(work_order_id) number_of_work_orders
      from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
      join ANALYTICS.PUBLIC.MARKET_REGION_XWALK m
        on m.market_id = wo.branch_id
      where date_completed is null
        and archived_date is null
        and asset_id is not null
      group by asset_id
      having number_of_work_orders > 1 ;;
  }

  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.asset_id ;;
  }

  dimension: number_of_open_work_orders {
    type: number
    sql: ${TABLE}.number_of_work_orders ;;
  }
  }
