view: dim_jobs {
  sql_table_name: "PLATFORM"."GOLD"."V_JOBS" ;;

  # PRIMARY KEY
  dimension: job_key {
    primary_key: yes
    type: string
    sql: ${TABLE}."JOB_KEY" ;;
    hidden: yes
  }

  # NATURAL KEYS
  dimension: job_source {
    type: string
    sql: ${TABLE}."JOB_SOURCE" ;;
    description: "Source system for job data"
  }

  dimension: job_id {
    type: number
    sql: ${TABLE}."JOB_ID" ;;
    description: "Natural job ID"
    value_format_name: id
  }

  # JOB DETAILS
  dimension: job_name {
    type: string
    sql: ${TABLE}."JOB_NAME" ;;
    description: "Job site name"
    link: {
      label: "Job Details"
      url: "/dashboards/job_profile?job_id={{ job_id._value }}"
    }
  }

  dimension: job_number {
    type: string
    sql: ${TABLE}."JOB_NUMBER" ;;
    description: "Job number"
  }

  dimension: job_description {
    type: string
    sql: ${TABLE}."JOB_DESCRIPTION" ;;
    description: "Job description"
  }

  # JOB STATUS
  dimension: job_deleted {
    type: yesno
    sql: ${TABLE}."JOB_DELETED" ;;
    description: "Job is deleted"
  }

  # MEASURES
  measure: count {
    type: count
    description: "Number of job sites"
    drill_fields: [job_name, job_number, job_id]
  }

  # TIMESTAMP
  dimension_group: job_recordtimestamp {
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
    sql: CAST(${TABLE}."JOB_RECORDTIMESTAMP" AS TIMESTAMP_NTZ) ;;
    description: "When this job record was created"
  }
}
