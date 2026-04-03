view: payout_programs {
  sql_table_name: "PUBLIC"."PAYOUT_PROGRAMS"
    ;;
  drill_fields: [payout_program_id]

  dimension: payout_program_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."PAYOUT_PROGRAM_ID" ;;
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
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: asset_payout_percentage {
    type: number
    sql: ${TABLE}."ASSET_PAYOUT_PERCENTAGE" ;;
  }

  dimension: name {
    type: string
    label: "Payout Program"
    sql: ${TABLE}."NAME" ;;
  }

  dimension: payout_program_type_id {
    type: number
    sql: ${TABLE}."PAYOUT_PROGRAM_TYPE_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [payout_program_id, name, payout_program_assignments.count]
  }
}
