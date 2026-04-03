view: cash_inflow_outflow_weekly_quarterly {
  derived_table: {
    sql: select distinct 'Inflow Outflow' as tile, io.DATE::date as date ,'' as dashboard,sum(io.CREDITAMOUNTCONVERTED) as metric_one,
      sum(-io.DEBITAMOUNTCONVERTED) as metric_two
      from analytics.TREASURY.NEW_INFLOW_OUTFLOW_HISTORY as io
      where  io.DATE::date >= '2022-07-01'
      --and  io.TAG_ID <> 'd3e1a43c-98ea-4404-aa12-79d2bb62dff3'
      and timestamp = (select max(timestamp) from analytics.TREASURY.NEW_INFLOW_OUTFLOW_HISTORY)
      group by io.date::date
      union all
      select 'Level Two Tags' as tile, lt.date::date as date ,ltt.DASHBOARD as dashboard, sum(lt.CREDITAMOUNTCONVERTED) - sum(lt.DEBITAMOUNTCONVERTED) as metric_one,
      0 as metric_two
      from analytics.TREASURY.LEVEL_TWO_TAGS_HISTORY as lt
      inner join analytics.TREASURY.LEVEL_TWO_TAGS_TAGS as ltt on lt.TAG_ID = ltt.TAG_ID
      where lt.DATE::date >= '2022-07-01'
      and dashboard <> 'Not Included'
      and timestamp = (select max(timestamp) from analytics.TREASURY.LEVEL_TWO_TAGS_HISTORY)
      group by lt.date::date, ltt.DASHBOARD
      having abs(metric_one) > 0
            ;;
  }

  filter: date_filter
  {
    type: date
    default_value: "1 day ago"
  }

  dimension_group: date {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year,
      day_of_week
    ]
    sql: ${TABLE}.DATE  ;;
  }

  dimension: weekday {
    type: string
    sql: case when dayofweek(${TABLE}.DATE) in (0,6) then 'Exclude' else 'Keep' end ;;
  }

  dimension: dashboard {
    type: string
    sql: ${TABLE}.DASHBOARD  ;;
  }

  dimension: tile {
    type: string
    sql: ${TABLE}.TILE  ;;
  }

  measure: metric_one {
    type: sum
    value_format: "$#;($#);-"
    sql: ${TABLE}.METRIC_ONE / 1000000 ;;
  }

  measure: metric_two {
    type: sum
    value_format: "$#;($#);-"
    sql: ${TABLE}.METRIC_TWO / 1000000 ;;
  }


  measure: metric_three {
    type: sum
    value_format: "$#.0;($#.0);-"
    sql: ${TABLE}.METRIC_ONE / 1000000 ;;
  }

  measure: metric_four {
    type: sum
    value_format: "$#.0;($#.0);-"
    sql: ${TABLE}.METRIC_TWO / 1000000 ;;
  }


}
