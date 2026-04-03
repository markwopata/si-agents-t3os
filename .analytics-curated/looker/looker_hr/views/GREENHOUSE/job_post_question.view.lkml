view: job_post_question {
  sql_table_name: "GREENHOUSE"."JOB_POST_QUESTION"
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

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: index {
    type: number
    sql: ${TABLE}."INDEX" ;;
  }

  dimension: job_post_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."JOB_POST_ID" ;;
  }

  dimension: label {
    type: string
    sql: ${TABLE}."LABEL" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: private {
    type: yesno
    sql: ${TABLE}."PRIVATE" ;;
  }

  dimension: required {
    type: yesno
    sql: ${TABLE}."REQUIRED" ;;
  }

  dimension: type {
    type: string
    sql: ${TABLE}."TYPE" ;;
  }

  measure: count {
    type: count
    drill_fields: [name, job_post.location_name, job_post.id]
  }
}
