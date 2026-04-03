view: part_billing_cycle {
  sql_table_name: "TOOLS_TRAILER"."PART_BILLING_CYCLE"
    ;;

  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension_group: cycle_end {
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
    sql: ${TABLE}."CYCLE_END_DATE" ;;
  }

  dimension_group: cycle_start {
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
    sql: ${TABLE}."CYCLE_START_DATE" ;;
  }

  dimension: part_id {
    type: number
    sql: ${TABLE}."PART_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
