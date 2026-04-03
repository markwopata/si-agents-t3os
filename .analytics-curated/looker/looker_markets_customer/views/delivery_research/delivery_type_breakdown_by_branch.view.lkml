
view: delivery_type_breakdown_by_branch {
  derived_table: {
    sql:
    select
      case when delivery_type_id in (1,3) then 'Drop Off'
      when delivery_type_id in (4,5,6) then 'Return'
      when delivery_type_id in (2,7) then 'Transport'
      else 'Unknown'
      end as delivery_type,
      dft.name as facilitator_type,
      m.name as branch,
      mx.region_name as region,
      mx.district as district,
      count(*) as deliveries_count
      from
      es_warehouse.public.deliveries d
      join es_warehouse.public.delivery_facilitator_types dft on d.facilitator_type_id = dft.delivery_facilitator_type_id
      join es_warehouse.public.orders o on o.order_id = d.order_id
      join es_warehouse.public.markets m on m.market_id = o.market_id
      left join analytics.public.market_region_xwalk mx on m.market_id = mx.market_id
      where
      d.completed_date BETWEEN {% date_start date_filter%} AND {% date_end date_filter%}
      --d.completed_date between '2023-08-20' AND current_date
      group by
      delivery_type,
      facilitator_type,
      branch,
      mx.region_name,
      mx.district
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: delivery_type {
    type: string
    sql: ${TABLE}."DELIVERY_TYPE" ;;
  }

  dimension: facilitator_type {
    type: string
    sql: ${TABLE}."FACILITATOR_TYPE" ;;
  }

  dimension: branch {
    type: string
    sql: ${TABLE}."BRANCH" ;;
  }

  dimension: deliveries_count {
    type: number
    sql: ${TABLE}."DELIVERIES_COUNT" ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  measure: total_deliveries {
    type: sum
    sql: ${deliveries_count} ;;
  }

  filter: date_filter {
    label: "Date Range"
    type: date
  }

  set: detail {
    fields: [
        delivery_type,
  facilitator_type,
  region,
  district,
  branch,
  total_deliveries
    ]
  }
}
