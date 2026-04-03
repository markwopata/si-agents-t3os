view: greenhouse_permission_overrides {
  sql_table_name: "GS"."GREENHOUSE_PERMISSION_OVERRIDES"
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

  dimension: job_id {
    type: number
    sql: ${TABLE}."JOB_ID" ;;
  }

  dimension: job_id_user {
    primary_key: yes
    type: string
    sql: concat(${job_id},'-',${user_email}) ;;
  }

  dimension: job_name {
    type: string
    sql: ${TABLE}."JOB_NAME" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: user {
    type: string
    sql: ${TABLE}."USER" ;;
  }

  dimension: user_email {
    type: string
    sql: ${TABLE}."USER_EMAIL" ;;
  }

  measure: count {
    type: count
    drill_fields: [job_name, market_name]
  }
}
