view: job {
  sql_table_name: "GREENHOUSE"."JOB"
    ;;
  drill_fields: [job_id]

  dimension: job_id {
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

  dimension_group: closed {
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
    sql: CAST(${TABLE}."CLOSED_AT" AS TIMESTAMP_NTZ) ;;
  }

  dimension: confidential {
    type: yesno
    sql: ${TABLE}."CONFIDENTIAL" ;;
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

  dimension: custom_employment_type {
    type: string
    sql: ${TABLE}."CUSTOM_EMPLOYMENT_TYPE" ;;
  }

  dimension: custom_options {
    type: number
    sql: ${TABLE}."CUSTOM_OPTIONS" ;;
  }

  dimension: custom_salary {
    type: string
    sql: ${TABLE}."CUSTOM_SALARY" ;;
  }

  dimension: job {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  # dimension: job_plus_market {
  #   type: string
  #   sql: CASE WHEN ${market_region_xwalk.market_name} is null THEN concat(${job},' - ','Corporate') else
  #   concat(${job},' - ',${market_region_xwalk.market_name}) END  ;;
  # }

  dimension: notes {
    type: string
    sql: ${TABLE}."NOTES" ;;
  }

  dimension: requisition_id {
    type: string
    sql: ${TABLE}."REQUISITION_ID" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
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
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      job_id,
      job,
      hiring_team.count,
      job_application.count,
      job_department.count,
      job_office.count,
      job_opening.count,
      job_post.count,
      job_stage.count,
      user_permission.count
    ]
  }
}
