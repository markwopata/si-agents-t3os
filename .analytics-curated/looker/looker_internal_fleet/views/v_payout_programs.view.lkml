view: v_payout_programs {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."V_PAYOUT_PROGRAMS" ;;

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: payout_program_assignment_id {
    type: number
    sql: ${TABLE}."PAYOUT_PROGRAM_ASSIGNMENT_ID" ;;
  }

  dimension: payout_program_id {
    type: number
    sql: ${TABLE}."PAYOUT_PROGRAM_ID" ;;
  }

  dimension: payout_program_name {
    type: string
    sql: ${TABLE}."PAYOUT_PROGRAM_NAME" ;;
  }

  dimension: payout_program_type_id {
    type: number
    sql: ${TABLE}."PAYOUT_PROGRAM_TYPE_ID" ;;
  }

  dimension_group: start_date {
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

  dimension_group: end_date {
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

  dimension: is_current {
    type: yesno
    sql: ${start_date_date} < CURRENT_DATE() AND (${end_date_date} > CURRENT_DATE() or ${end_date_date} is null)  ;;
  }
}
