view: user_permission {
  sql_table_name: "GREENHOUSE"."USER_PERMISSION"
    ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
  }

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

  dimension: job_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."JOB_ID" ;;
  }

  dimension: user_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: user_role_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."USER_ROLE_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      id,
      user.id,
      user.first_name,
      user.last_name,
      job.name,
      job.id,
      user_role.id,
      user_role.name
    ]
  }
}
