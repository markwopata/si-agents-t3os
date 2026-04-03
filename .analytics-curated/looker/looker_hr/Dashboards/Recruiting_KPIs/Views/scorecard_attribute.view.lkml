view: scorecard_attribute {
  sql_table_name: "GREENHOUSE"."SCORECARD_ATTRIBUTE"
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

  dimension: index {
    type: number
    sql: ${TABLE}."INDEX" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: note {
    type: string
    sql: ${TABLE}."NOTE" ;;
  }

  dimension: rating {
    type: string
    sql: ${TABLE}."RATING" ;;
  }

  dimension: scorecard_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."SCORECARD_ID" ;;
  }

  dimension: type {
    type: string
    sql: ${TABLE}."TYPE" ;;
  }

  measure: count {
    type: count
    drill_fields: [name, scorecard.id]
  }
}
