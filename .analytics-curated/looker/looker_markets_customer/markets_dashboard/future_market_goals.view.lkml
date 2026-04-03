
view: future_market_goals {
  derived_table: {
    sql: select
        mrx.market_name as market,
        mrx.district,
        mrx.region_name,
        mrx.market_type,
        mg.months as goal_month,
        mg.revenue_goals
      from
        analytics.public.market_goals mg
        JOIN analytics.public.market_region_xwalk mrx on mg.market_id = mrx.market_id
      where
        mg.months BETWEEN dateadd(months,1,date_trunc(month,current_date)) AND dateadd(months,6,date_trunc(month,current_date))
        AND mg.end_date is null;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: market {
    group_label: "Location"
    view_label: " "
    type: string
    sql: ${TABLE}."MARKET" ;;
  }

  dimension: district {
    group_label: "Location"
    view_label: " "
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: region {
    group_label: "Location"
    view_label: " "
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: market_type {
    group_label: "Location"
    view_label: " "
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension_group: goal_month {
    type: time
    sql: ${TABLE}."GOAL_MONTH" ;;
  }

  dimension: revenue_goals {
    type: string
    sql: ${TABLE}."REVENUE_GOALS" ;;
  }

  dimension: goal_date {
    group_label: "HTML Formatted Date"
    label: "Month"
    type: date
    sql: ${goal_month_raw} ;;
    html: {{ rendered_value | date: "%B %Y"  }};;
  }

  measure: revenue_goal {
    type: sum
    sql: ${revenue_goals} ;;
    value_format_name: usd_0
  }

  set: detail {
    fields: [
        market,
  goal_month_time,
  revenue_goals
    ]
  }
}
