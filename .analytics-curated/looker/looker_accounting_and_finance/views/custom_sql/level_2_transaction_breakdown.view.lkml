view: level_2_transaction_breakdown {
  derived_table: {
    sql: select lt.date::date as date ,ltt.DASHBOARD, sum(lt.CREDITAMOUNTCONVERTED) - sum(lt.DEBITAMOUNTCONVERTED) as net_cash
from analytics.TREASURY.LEVEL_TWO_TAGS_HISTORY as lt
inner join analytics.TREASURY.LEVEL_TWO_TAGS_TAGS as ltt on lt.TAG_ID = ltt.TAG_ID
--where lt.DATE::date between dateadd(day, -7, {% date_start date_filter %}) and dateadd(day, -1, {% date_start date_filter %})
group by lt.date::date, ltt.DASHBOARD
having abs(net_cash) > 0
order by lt.date::date, net_cash desc

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


  dimension: dashboard {
    type: string
    sql: ${TABLE}.DASHBOARD ;;
    }

  measure: net_cash {
    type: sum
    value_format: "$#;($#);-"
    sql: ${TABLE}.NET_CASH / 1000000 ;;
  }




}
