view: learning_plan {
  sql_table_name: "DOCEBO"."LEARNING_PLAN" ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
  }

  dimension: code {
    type: string
    sql: ${TABLE}."CODE" ;;
  }
  dimension: create {
    type: date_raw
    sql: ${TABLE}."CREATE_DATE" ;;
    hidden:  yes
  }
  dimension: date_last_updated {
    type: date_raw
    sql: ${TABLE}."DATE_LAST_UPDATED" ;;
    hidden:  yes
  }
  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }
  dimension: image {
    type: number
    sql: ${TABLE}."IMAGE" ;;
  }
  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }
  measure: count {
    type: count
    drill_fields: [id, name]
  }
}
