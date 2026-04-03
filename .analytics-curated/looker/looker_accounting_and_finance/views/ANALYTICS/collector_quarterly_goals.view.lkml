view: collector_quarterly_goals {
  sql_table_name: "ANALYTICS"."TREASURY"."COLLECTOR_QUARTERLY_GOALS" ;;

  ###### DIMENSIONS ######

  dimension: collector {
    type: string
    sql: ${TABLE}."COLLECTOR" ;;
  }

  dimension: current_manager {
    type: string
    sql: ${TABLE}."CURRENT_MANAGER" ;;
  }

  dimension: team_manager {
    type: string
    sql: ${TABLE}."TEAM_MANAGER" ;;
  }

  dimension: quarter {
    type: string
    sql: ${TABLE}."QUARTER" ;;
  }

  ###### MEASURES ######

  measure: actuals {
    type: sum
    value_format_name: usd
    sql: ${TABLE}."ACTUALS" ;;
  }

  measure: target {
    type: sum
    value_format_name: usd
    sql: ${TABLE}."TARGET" ;;
  }

  measure: result_pct {
    label: "Result (%)"
    type: number
    value_format_name: percent_2
    sql: iff(${target}=0,0,${actuals} / ${target}) ;;
  }

}
