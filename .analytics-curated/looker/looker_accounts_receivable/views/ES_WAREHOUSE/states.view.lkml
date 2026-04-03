view: states {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."STATES";;
  drill_fields: [state_id]

  dimension: state_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."STATE_ID" ;;
  }

  dimension: abbreviation {
    type: string
    sql: ${TABLE}."ABBREVIATION" ;;
  }

  dimension: domain_id {
    type: number
    sql: ${TABLE}."DOMAIN_ID" ;;
  }

  dimension: geom {
    type: string
    sql: ${TABLE}."GEOM" ;;
  }

  dimension: geom2 {
    type: string
    sql: ${TABLE}."GEOM2" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  measure: count {
    type: count
    drill_fields: [state_id, name, locations.count]
  }
}
