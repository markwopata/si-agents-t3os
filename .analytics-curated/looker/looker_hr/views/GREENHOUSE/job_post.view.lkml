view: job_post {
  sql_table_name: "GREENHOUSE"."JOB_POST"
    ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
  }

  dimension: _fivetran_deleted {
    type: yesno
    sql: ${TABLE}."_FIVETRAN_DELETED" ;;
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

  dimension: content {
    type: string
    sql: ${TABLE}."CONTENT" ;;
  }

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
    sql: CAST(${TABLE}."CREATED_AT" AS TIMESTAMP_NTZ) ;;
  }

  dimension: external {
    type: yesno
    sql: ${TABLE}."EXTERNAL" ;;
  }

  dimension: internal {
    type: yesno
    sql: ${TABLE}."INTERNAL" ;;
  }

  dimension: internal_content {
    type: string
    sql: ${TABLE}."INTERNAL_CONTENT" ;;
  }

  dimension: job_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."JOB_ID" ;;
  }

  dimension: live {
    type: yesno
    sql: ${TABLE}."LIVE" ;;
  }

  dimension: location_name {
    type: string
    sql: ${TABLE}."LOCATION_NAME" ;;
  }

  dimension: title {
    type: string
    sql: ${TABLE}."TITLE" ;;
  }

  dimension_group: updated {
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
    sql: CAST(${TABLE}."UPDATED_AT" AS TIMESTAMP_NTZ) ;;
  }

  measure: count {
    type: count
    drill_fields: [id, location_name, job.name, job.id, job_post_question.count]
  }
}
