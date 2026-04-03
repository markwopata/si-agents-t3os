view: commissions_salesperson_data {
  sql_table_name: "ANALYTICS"."PUBLIC"."COMMISSIONS_SALESPERSON_DATA"
    ;;

  dimension_group: commission_end_date {
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
    sql: CAST(${TABLE}."COMMISSION_END_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: commission_start_date {
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
    sql: ${TABLE}."COMMISSION_START_DATE" ;;
  }

  dimension_group: payroll_commission_start_date {
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
    sql: DATEADD(MONTH, 1, ${TABLE}."COMMISSION_START_DATE") ;;
  }

  dimension: commission_tier_1_end {
    type: string
    sql: ${TABLE}."COMMISSION_TIER_1_END" ;;
  }

  dimension: commission_tier_1_percentage {
    type: string
    sql: ${TABLE}."COMMISSION_TIER_1_PERCENTAGE" ;;
  }

  dimension: commission_tier_1_start {
    type: number
    sql: ${TABLE}."COMMISSION_TIER_1_START" ;;
  }

  dimension: commission_tier_2_end {
    type: number
    sql: ${TABLE}."COMMISSION_TIER_2_END" ;;
  }

  dimension: commission_tier_2_percentage {
    type: string
    sql: ${TABLE}."COMMISSION_TIER_2_PERCENTAGE" ;;
  }

  dimension: commission_tier_2_start {
    type: number
    sql: ${TABLE}."COMMISSION_TIER_2_START" ;;
  }

  dimension: commission_tier_3_end {
    type: number
    sql: ${TABLE}."COMMISSION_TIER_3_END" ;;
  }

  dimension: commission_tier_3_percentage {
    type: string
    sql: ${TABLE}."COMMISSION_TIER_3_PERCENTAGE" ;;
  }

  dimension: commission_tier_3_start {
    type: number
    sql: ${TABLE}."COMMISSION_TIER_3_START" ;;
  }

  dimension: commission_type {
    type: string
    sql: ${TABLE}."COMMISSION_TYPE" ;;
  }

  dimension: guarantee_amount {
    type: number
    sql: ${TABLE}."GUARANTEE_AMOUNT" ;;
  }

  dimension_group: guarantee_end {
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
    sql: ${TABLE}."GUARANTEE_END_DATE" ;;
  }

  dimension_group: payroll_guarantee_end_date {
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
    sql: DATEADD(MONTH, 1, ${TABLE}."GUARANTEE_END_DATE") ;;
  }

  dimension_group: guarantee_start {
    label: "Date employee started in commission eligible position"
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
    sql: ${TABLE}."GUARANTEE_START_DATE" ;;
  }

  dimension_group: last_update {
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
    sql: ${TABLE}."LAST_UPDATE" ;;
  }

  dimension: name {
    label: "Salesperson Name"
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: note {
    type: string
    sql: ${TABLE}."NOTE" ;;
  }

  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
    value_format_name: id
  }

  measure: count {
    type: count
    drill_fields: [name]
  }
}
