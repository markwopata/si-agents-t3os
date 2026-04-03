view: rentals_by_user {
  sql_table_name: "ANALYTICS"."PUBLIC"."RENTALS_BY_USER"
    ;;

  dimension_group: created {
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
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: rental_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension_group: task_exec {
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
    sql: ${TABLE}."TASK_EXEC_DATE" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
