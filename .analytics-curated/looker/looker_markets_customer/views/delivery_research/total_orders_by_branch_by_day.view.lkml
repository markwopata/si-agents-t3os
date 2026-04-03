
view: total_orders_by_branch_by_day {
  derived_table: {
    sql:
    with date_series as (
      select
      series::date as date
      from table
      (generate_series(
      --'2023-08-20'::timestamp_tz,
      --current_timestamp()::timestamp_tz,
       {% date_start date_filter %}::timestamp_tz,
       {% date_end date_filter %}::timestamp_tz,
      'day')
      )
      )
      select
          ds.date::timestamp as date,
          m.name as branch,
          coalesce(count(distinct(o.order_id)),0) as total_orders
      from
          date_series ds
          left join es_warehouse.public.orders o on o.date_created::date = ds.date
          join es_warehouse.public.markets m on m.market_id = o.market_id
      where
      o.date_created BETWEEN {% date_start date_filter%} AND {% date_end date_filter%}
          --o.date_created between '2023-08-20' AND current_date
          AND o.deleted = FALSE
      group by
          ds.date,
          branch
  ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension_group: date {
    type: time
    sql: ${TABLE}."DATE" ;;
  }

  dimension: branch {
    type: string
    sql: ${TABLE}."BRANCH" ;;
  }

  dimension: total_orders {
    type: number
    sql: ${TABLE}."TOTAL_ORDERS" ;;
  }

  measure: average_orders {
    type: average
    sql: ${total_orders} ;;
  }

  measure: timeframe_total_orders {
    type: sum
    sql: ${total_orders} ;;
  }

  measure: average_orders_per_day {
    type: number
    sql: ${timeframe_total_orders}/datediff(days,{% date_start date_filter %},{% date_end date_filter %})  ;;
    value_format_name: decimal_1
  }

  filter: date_filter {
    label: "Date Range"
    type: date
  }

  parameter: duration_selection {
    type: string
    allowed_value: { value: "Daily"}
    allowed_value: { value: "Weekly"}
    allowed_value: { value: "Monthly"}
  }

  dimension: dynamic_timeframe {
    group_label: "Dynamic Date"
    label: "Date"
    type: string
    sql:
    CASE
    WHEN {% parameter duration_selection %} = 'Daily' THEN ${date_date}
    WHEN {% parameter duration_selection %} = 'Weekly' THEN ${date_week}
    WHEN {% parameter duration_selection %} = 'Monthly' THEN ${date_month}
    END ;;
    html: {% if duration_selection._parameter_value == "'Daily'" %}
          {{ rendered_value | date: "%b %d, %Y" }}
          {% elsif duration_selection._parameter_value == "'Weekly'"  %}
          {{ rendered_value | date: "%b %d, %Y" }}
          {% else %}
          {{ rendered_value | append: "-01" | date: "%b %Y" }}
          {% endif %} ;;
  }

  set: detail {
    fields: [
        date_date,
  branch,
  total_orders
    ]
  }
}
