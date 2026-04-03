view: historic_market_payroll_loss_count {
  sql_table_name: "CLAIMS"."HISTORIC_MARKET_PAYROLL_LOSS_COUNT"
    ;;

  dimension: loss_count {
    type: number
    sql: ${TABLE}."LOSS_COUNT" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension_group: month {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."MONTH" ;;
  }

  dimension: monthly_payroll {
    type: number
    value_format: "$0.00,,\" M\""
    sql: ${TABLE}."MONTHLY_PAYROLL" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }

  dimension: last_12 {
    type: yesno
    sql: ${month_date} > dateadd(year, -1, current_date) ;;
  }

  measure: count_loss_last_12 {
    type: sum
    sql: ${loss_count};;
    filters: [last_12: "yes"]
    link: {
      label: "View Work Comp Accidents"
      url: "https://equipmentshare.looker.com/dashboards/825?Market+Name={{ _filters['market_region_xwalk.market_name'] }}"
    }
    #html:  <u><p style="color:Blue;"><a href="https://equipmentshare.looker.com/dashboards/825?Market+Name={{ _filters['market_region_xwalk.market_name']}}">{{rendered_value}}</a></p></u>;;
  }

  measure: sum_payroll_last_12 {
    type: sum
    value_format: "$0.00,,\" M\""
    sql: ${monthly_payroll};;
    filters: [last_12: "yes"]
  }
}
