view: payout_program_schedule_assignments {
  sql_table_name: "ANALYTICS"."CONTRACTOR_PAYOUTS"."PAYOUT_PROGRAM_SCHEDULE_ASSIGNMENTS"
    ;;

  dimension: asset_id {
    primary_key: yes
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
    sql: ${TABLE}."END_DATE" ;;
  }

  dimension: program_schedule_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."PAYOUT_PROGRAM_SCHEDULE_ID" ;;
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
    sql: ${TABLE}."START_DATE" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
