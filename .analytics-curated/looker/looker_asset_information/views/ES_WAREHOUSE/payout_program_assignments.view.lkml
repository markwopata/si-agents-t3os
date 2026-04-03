view: payout_program_assignments {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."PAYOUT_PROGRAM_ASSIGNMENTS"
    ;;
  drill_fields: [payout_program_assignment_id]

  dimension: payout_program_assignment_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."PAYOUT_PROGRAM_ASSIGNMENT_ID" ;;
  }

  dimension_group: _es_update_timestamp {
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
    sql: ${TABLE}.CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension_group: end {
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
    sql: CAST(${TABLE}."END_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: payout_program_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."PAYOUT_PROGRAM_ID" ;;
  }

  dimension_group: start {
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
    sql: CAST(${TABLE}."START_DATE" AS TIMESTAMP_NTZ) ;;
  }

  measure: count {
    type: count
    drill_fields: [payout_program_assignment_id, payout_programs.name, payout_programs.payout_program_id]
  }
}
