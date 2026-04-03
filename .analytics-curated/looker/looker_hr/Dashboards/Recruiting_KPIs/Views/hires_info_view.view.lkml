view: hires_info_view {
  sql_table_name: "GREENHOUSE"."HIRES_INFO_VIEW"
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
    sql: ${TABLE}.CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: application_id_offer {
    type: number
    value_format_name: id
    sql: ${TABLE}."APPLICATION_ID_OFFER" ;;
  }

  dimension: application_id_xwalk {
    type: number
    value_format_name: id
    sql: ${TABLE}."APPLICATION_ID_XWALK" ;;
  }

  dimension_group: applied {
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
    sql: ${TABLE}.CAST(${TABLE}."APPLIED_AT" AS TIMESTAMP_NTZ) ;;
  }

  dimension: candidate_id {
    type: number
    sql: ${TABLE}."CANDIDATE_ID" ;;
  }

  dimension_group: created_at {
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
    sql: ${TABLE}.CAST(${TABLE}."CREATED_AT" AS TIMESTAMP_NTZ) ;;
  }

  dimension: credited_to_user_id {
    type: number
    sql: ${TABLE}."CREDITED_TO_USER_ID" ;;
  }

  dimension: current_stage_id {
    type: number
    sql: ${TABLE}."CURRENT_STAGE_ID" ;;
  }

  dimension: is_deleted {
    type: yesno
    sql: ${TABLE}."IS_DELETED" ;;
  }

  dimension: job_id {
    type: number
    sql: ${TABLE}."JOB_ID" ;;
  }

  dimension: job_post_id {
    type: number
    sql: ${TABLE}."JOB_POST_ID" ;;
  }

  dimension_group: last_activity {
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
    sql: ${TABLE}.CAST(${TABLE}."LAST_ACTIVITY_AT" AS TIMESTAMP_NTZ) ;;
  }

  dimension: location_address {
    type: string
    sql: ${TABLE}."LOCATION_ADDRESS" ;;
  }

  dimension: prospect {
    type: yesno
    sql: ${TABLE}."PROSPECT" ;;
  }

  dimension: prospect_owner_id {
    type: number
    sql: ${TABLE}."PROSPECT_OWNER_ID" ;;
  }

  dimension: prospect_pool_id {
    type: number
    sql: ${TABLE}."PROSPECT_POOL_ID" ;;
  }

  dimension: prospect_stage_id {
    type: number
    sql: ${TABLE}."PROSPECT_STAGE_ID" ;;
  }

  dimension_group: rejected {
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
    sql: ${TABLE}.CAST(${TABLE}."REJECTED_AT" AS TIMESTAMP_NTZ) ;;
  }

  dimension: rejected_reason_id {
    type: number
    sql: ${TABLE}."REJECTED_REASON_ID" ;;
  }

  dimension: source_id {
    type: number
    sql: ${TABLE}."SOURCE_ID" ;;
  }

  dimension_group: starts {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."STARTS_AT" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  measure: count {
    type: count
    drill_fields: [id]
  }
}
