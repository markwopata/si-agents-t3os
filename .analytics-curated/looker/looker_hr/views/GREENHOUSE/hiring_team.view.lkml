view: hiring_team {
  sql_table_name: "GREENHOUSE"."HIRING_TEAM"
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

  dimension: job_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."JOB_ID" ;;
  }

  dimension: role {
    type: string
    sql: ${TABLE}."ROLE" ;;
  }

  dimension: recruiter {
    type: yesno
    sql: ${role} = 'recruiters' ;;
  }

  dimension: user_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."USER_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [user.id, user.first_name, user.last_name, job.name, job.id]
  }
}
