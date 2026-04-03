view: job_office {
  sql_table_name: "GREENHOUSE"."JOB_OFFICE"
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

  dimension: office_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."OFFICE_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [job.name, job.id, office.location_name, office.name, office.id]
  }
}
