view: work_orders_open_count_past_90_days {
  derived_table: {
    # datagroup_trigger: Every_Two_Hours_Update
    sql: with get_past_days as
      (
        select
          dateadd(
            day,
            '-' || row_number() over (order by null),
            dateadd(day, '+1', current_date())
          ) as generated_date
        from table (generator(rowcount => 90))
      ),
      wo_info as (
      select
        date_created::date as date_created,
        coalesce(date_completed::date,current_date) as date_completed,
          work_order_id,
          branch_id,
          wt.name as work_order_type,
          mrx.market_name as market_name,
          mrx.region_name as region_name,
          mrx.district
      from
          ES_WAREHOUSE.work_orders.work_orders wo
          left join ES_WAREHOUSE.work_orders.work_order_types wt on wo.work_order_type_id = wt.work_order_type_id
          inner join ANALYTICS.PUBLIC.market_region_xwalk mrx on mrx.market_id = wo.branch_id
      where
          archived_date is null
      )
      select
        generated_date::date as generateddate,
        work_order_type,
        market_name,
        branch_id,
        region_name,
        district,
        count(*) as ttl_open_work_orders
      from
        get_past_days pd
        inner join wo_info wo on pd.generated_date::date between wo.date_created::date and wo.date_completed::date
      group by
        generated_date,
        work_order_type,
        market_name,
        branch_id,
        region_name,
        district
 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: generateddate {
    type: date
    sql: ${TABLE}."GENERATEDDATE" ;;
  }

  dimension: work_order_type {
    type: string
    sql: ${TABLE}."WORK_ORDER_TYPE" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: ttl_open_work_orders {
    type: number
    sql: ${TABLE}."TTL_OPEN_WORK_ORDERS" ;;
  }

  measure: total_open_work_orders {
    type: sum
    sql: ${ttl_open_work_orders} ;;
    drill_fields: [detail*]
  }

  set: detail {
    fields: [
      generateddate,
      work_order_type,
      market_name,
      region_name,
      district,
      ttl_open_work_orders
    ]
  }
}
