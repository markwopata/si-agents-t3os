view: greenhouse_job_id_sample {
  sql_table_name: "GS"."GREENHOUSE_JOB_ID_SAMPLE"
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

  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
  }

  dimension: job_title {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: hiring_manager_2 {
    type: string
    sql: ${TABLE}."HIRING_MANAGER_2" ;;
  }

  dimension: hiring_manager_3 {
    type: string
    sql: ${TABLE}."HIRING_MANAGER_3" ;;
  }

  dimension: hiring_manager_4 {
    type: string
    sql: ${TABLE}."HIRING_MANAGER_4" ;;
  }

  dimension: hiring_manger_ {
    type: string
    sql: ${TABLE}."HIRING_MANGER_" ;;
  }

  dimension: job_id {
    primary_key: yes
    type: number
    sql: CASE WHEN ${TABLE}."JOB_ID" like '%Not%' OR ${TABLE}."JOB_ID" like '%PENDING%' then NULL else ${TABLE}."JOB_ID" END ;;
  }

  dimension: market_id {
    type: number
    sql: CASE WHEN ${TABLE}."MARKET_ID" like '%Corporate%' THEN 0 else ${TABLE}."MARKET_ID" END ;;
  }

  dimension: recruiter {
    type: string
    sql: ${TABLE}."RECRUITER" ;;
  }

  dimension: recruiter_email {
    type: string
    sql: ${TABLE}."RECRUITER_EMAIL" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
