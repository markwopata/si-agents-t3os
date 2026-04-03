view: ad_spend {
  sql_table_name: "GREENHOUSE"."AD_SPEND"
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

  dimension: dribble {
    type: number
    sql: ${TABLE}."DRIBBLE" ;;
  }

  dimension: facebook {
    type: number
    sql: ${TABLE}."FACEBOOK" ;;
  }

  dimension: glassdoor {
    type: number
    sql: ${TABLE}."GLASSDOOR" ;;
  }

  dimension: indeed {
    type: number
    sql: ${TABLE}."INDEED" ;;
  }

  dimension: instagram {
    type: number
    sql: ${TABLE}."INSTAGRAM" ;;
  }

  dimension: linked_in {
    type: number
    sql: ${TABLE}."LINKED_IN" ;;
  }

  dimension: stack_overflow {
    type: number
    sql: ${TABLE}."STACK_OVERFLOW" ;;
  }

  #dimension: week_of {
  #  type: string
  #  sql: ${TABLE}."WEEK_OF" ;;
  #}

  dimension_group: week_of {
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
    sql: CAST(${TABLE}."WEEK_OF" AS TIMESTAMP_NTZ) ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
