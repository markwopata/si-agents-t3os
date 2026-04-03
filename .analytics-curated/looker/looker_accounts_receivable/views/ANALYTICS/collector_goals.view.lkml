view: collector_goals {
  sql_table_name: "GS"."COLLECTOR_GOALS"
    ;;

  dimension_group: _fivetran_synced {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
  }

  dimension: collector {
    primary_key: yes
    type: string
    sql: CASE WHEN(UPPER(${TABLE}."COLLECTOR") LIKE '%OIL%') THEN 'OIL' ELSE ${TABLE}."COLLECTOR" END ;;
  }

  dimension: goals_120_plus {
    type: number
    sql: ${TABLE}."GOALS_120_PLUS" ;;
  }

  dimension: goals_91_120 {
    type: number
    sql: ${TABLE}."GOALS_91_120" ;;
  }

  measure: goals_91_120_measure {
    type: sum
    sql: ${goals_91_120} ;;
  }

  measure: goals_120_plus_measure {
    type: sum
    sql: ${goals_120_plus} ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
