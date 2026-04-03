view: v_part_billing {
  sql_table_name: "TOOLS_TRAILER"."V_PART_BILLING"
    ;;

  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: branch_name {
    type: string
    sql: ${TABLE}."BRANCH_NAME" ;;
  }

  dimension: class {
    type: string
    sql: ${TABLE}."CLASS" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
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

  dimension: daily_rate {
    type: number
    sql: ${TABLE}."DAILY_RATE" ;;
  }

  dimension: day_rate {
    type: number
    sql: ${TABLE}."DAY_RATE" ;;
  }

  dimension: days_on_rent {
    type: number
    sql: ${TABLE}."DAYS_ON_RENT" ;;
  }

  dimension: lowest_rate {
    type: number
    sql: ${TABLE}."LOWEST_RATE" ;;
  }

  dimension: month_rate {
    type: number
    sql: ${TABLE}."MONTH_RATE" ;;
  }

  dimension: monthly_rate {
    type: number
    sql: ${TABLE}."MONTHLY_RATE" ;;
  }

  dimension: num_class_units_on_rent {
    type: number
    sql: ${TABLE}."NUM_CLASS_UNITS_ON_RENT" ;;
  }

  dimension: part_id {
    type: number
    sql: ${TABLE}."PART_ID" ;;
  }

  dimension: pk {
    type: number
    sql: ${TABLE}."PK" ;;
  }

  dimension: rent_charge {
    type: number
    sql: ${TABLE}."RENT_CHARGE" ;;
  }

  dimension: week_only_rate {
    type: number
    sql: ${TABLE}."WEEK_ONLY_RATE" ;;
  }

  dimension: week_plus_day_rate {
    type: number
    sql: ${TABLE}."WEEK_PLUS_DAY_RATE" ;;
  }

  dimension: weekly_rate {
    type: number
    sql: ${TABLE}."WEEKLY_RATE" ;;
  }

  measure: count {
    type: count
    drill_fields: [branch_name, company_name]
  }
}
