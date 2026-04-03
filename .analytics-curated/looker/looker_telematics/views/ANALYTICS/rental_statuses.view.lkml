view: rental_statuses {
  sql_table_name: "ANALYTICS"."PUBLIC"."RENTAL_STATUSES"
    ;;
  drill_fields: [rental_status_id]

  dimension: rental_status_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."RENTAL_STATUS_ID" ;;
  }

  dimension: domain_id {
    type: number
    sql: ${TABLE}."DOMAIN_ID" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  measure: count {
    type: count
    drill_fields: [rental_status_id, name]
  }
}
