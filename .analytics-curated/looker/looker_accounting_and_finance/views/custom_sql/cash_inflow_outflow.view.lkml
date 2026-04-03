view: cash_inflow_outflow {
  derived_table: {
    sql: select distinct io.DATE::date as date ,sum(io.CREDITAMOUNTCONVERTED) as cash_inflow, sum(-io.DEBITAMOUNTCONVERTED) as cash_outflow
from analytics.TREASURY.INFLOW_OUTFLOW_HISTORY as io
where io.DATE::date between dateadd(day, -7, {% date_start date_filter %}) and dateadd(day, -1, {% date_start date_filter %})
and  io.TAG_ID <> 'd3e1a43c-98ea-4404-aa12-79d2bb62dff3'
group by io.date::date
order by io.DATE::date

      ;;
  }

  filter: date_filter
 {
    type: date
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


  measure: cash_inflow {
    type: sum
    value_format: "$#;($#);-"
    sql: ${TABLE}.CASH_INFLOW / 1000000 ;;
  }

  measure: cash_outflow {
    type: sum
    value_format: "$#;($#);-"
    sql: ${TABLE}.CASH_OUTFLOW / 1000000 ;;
  }

  measure: net_cash_inflow_outflow {
    type: number
    value_format: "$#;($#);-"
    sql: ${cash_inflow} + ${cash_outflow} ;;
  }



}
