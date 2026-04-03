view: requisition_info_view {
  sql_table_name: "GREENHOUSE"."REQUISITION_INFO_VIEW"
    ;;

  dimension: active_apps {
    type: number
    sql: ${TABLE}."ACTIVE_APPS" ;;
  }

  dimension_group: close {
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
    sql: CAST(${TABLE}."CLOSE_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: department {
    type: string
    sql: ${TABLE}."DEPARTMENT" ;;
  }

  dimension: department2 {
    type: string
    sql: CASE WHEN ${TABLE}."DEPARTMENT" in ('Engineering Positions','Software Engineering') then 'Engineering'
              WHEN ${TABLE}."DEPARTMENT" in ('Corporate Office Positions','Management','Business Support') then 'Other Corporate Positions'
              WHEN ${TABLE}."DEPARTMENT" in ('Operations','Operations ','Real Estate ') then 'Operations'
              WHEN ${TABLE}."DEPARTMENT" in ('Telematics Sales','T3 Positions','T3 Technology') then 'Telematics'
              WHEN ${TABLE}."DEPARTMENT" = 'Customer Service' then 'Sales Support'
              WHEN ${TABLE}."DEPARTMENT" = 'Marketing, Communications and Public Relations' then 'Marketing'
              WHEN ${TABLE}."DEPARTMENT" = 'Maintenance' then 'Service'
              else ${TABLE}."DEPARTMENT" end
              ;;
  }

  dimension: ftpt {
    type: string
    sql: ${TABLE}."FTPT" ;;
  }

  dimension: hires {
    type: number
    sql: ${TABLE}."HIRES" ;;
  }

  dimension: job_id {
    type: number
    sql: ${TABLE}."JOB_ID" ;;
  }

  dimension: job_name {
    type: string
    sql: ${TABLE}."JOB_NAME" ;;
  }

  dimension: job_status {
    type: string
    sql: ${TABLE}."JOB_STATUS" ;;
  }

  dimension_group: last_post_updated {
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
    sql: CAST(${TABLE}."LAST_POST_UPDATED_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: location {
    type: string
    sql: ${TABLE}."LOCATION" ;;
  }

  dimension_group: open_reopen {
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
    sql: CAST(${TABLE}."OPEN_REOPEN_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: post_is_live {
    type: yesno
    sql: ${TABLE}."POST_IS_LIVE" ;;
  }

  dimension: rejections {
    type: number
    sql: ${TABLE}."REJECTIONS" ;;
  }

  dimension: total_applications {
    type: number
    sql: ${TABLE}."TOTAL_APPLICATIONS" ;;
  }

  measure: count {
    type: count
    drill_fields: [job_name]
  }

  measure: dept_count {
    type: count
    drill_fields: [department]
  }

  measure: open_jobs {
    type: count_distinct
    sql: ${TABLE}."JOB_ID" ;;
    filters: [job_status: "open"]
  }

  measure: job_id_count {
    type: count
    drill_fields: [job_id, job_name, open_reopen_date, close_date]
  }

  measure: unique_job_id_count {
    type: count_distinct
    drill_fields: [job_id, job_name, open_reopen_date, close_date]
    sql: ${TABLE}."JOB_ID";;
  }

}
