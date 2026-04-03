view: revenue_to_goal {
  derived_table: {
    sql: Select hf.gl_date::DATE as Date
    ,  hf.market_id
    ,  hf.market_name
    ,  hf.total_revenue
    ,  mg.REVENUE_GOALS
    ,  hf.net_income
from analytics.branch_earnings.high_level_financials hf
LEFT JOIN (SELECT *
           FROM analytics.public.market_goals
           WHERE END_DATE is null )mg
    ON hf.GL_DATE = mg.months AND hf.market_id = mg.market_ID ;;
  }
  dimension_group: month {
    type: time
    timeframes: [date,month]
    sql: ${TABLE}."DATE" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  # dimension: months_open {
  #   type: number
  #   sql: ${TABLE}."MONTHS_OPEN" ;;
  # }

  measure: revenue {
    type: sum
    value_format: "$#,##0.00"
    sql: ${TABLE}."TOTAL_REVENUE" ;;
  }

  measure: goal {
    type: sum
    value_format: "$#,##0.00"
    sql: ${TABLE}."REVENUE_GOALS" ;;
  }

  measure: net_income {
    type: sum
    value_format: "$#,##0.00"
    sql: ${TABLE}."NET_INCOME" ;;
  }
  measure: revenue_to_goal_perc {
    type: number
    sql: ${revenue}/nullifzero(${goal}) ;;
  }

measure: revenue_to_goal_spread {
  type: number
  value_format: "$#,##0.00"
  sql: ${goal}-${revenue} ;;
}
 }
