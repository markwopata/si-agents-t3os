view: job_department {
  sql_table_name: "GREENHOUSE"."JOB_DEPARTMENT"
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

  dimension: department_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."DEPARTMENT_ID" ;;
  }

  dimension: job_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."JOB_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [department.name, department.id, job.name, job.id]
  }
}
