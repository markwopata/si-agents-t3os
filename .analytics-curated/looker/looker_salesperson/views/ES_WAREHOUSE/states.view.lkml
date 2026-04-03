view: states {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."STATES"
    ;;
  drill_fields: [state_id]

  dimension: state_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."STATE_ID" ;;
  }

  dimension_group: _es_update_timestamp {
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
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: abbreviation {
    type: string
    sql: ${TABLE}."ABBREVIATION" ;;
  }

  dimension: geom {
    type: string
    sql: ${TABLE}."GEOM" ;;
  }

  dimension: geom2 {
    type: string
    sql: ${TABLE}."GEOM2" ;;
  }

  dimension: geom3 {
    type: string
    sql: ${TABLE}."GEOM3" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  measure: count {
    type: count
    drill_fields: [state_id, name]
  }
}
