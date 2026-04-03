view: q1_q2_missed_opp_tmp {
  sql_table_name: ANALYTICS.WARRANTIES.MISSED_OPP_TOTAL_TMP ;;

  dimension: quarter {
    type: date
    sql: ${TABLE}.quarter ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}.make ;;
  }

  dimension: missed_opp {
    type: number
    value_format_name: usd
    sql: ${TABLE}.missed_opp ;;
  }

  dimension: filed {
    type: number
    value_format_name: usd
    sql: ${TABLE}.filed ;;
  }

  dimension: reduction {
    type: number
    value_format_name: usd
    sql: ${TABLE}.total_reduction ;;
  }
}
