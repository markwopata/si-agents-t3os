view: v_asset_billing {
  sql_table_name: "TOOLS_TRAILER"."V_ASSET_BILLING"
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

  dimension: day_rate {
    type: number
    sql: ${TABLE}."DAY_RATE" ;;
  }

  dimension: days_on_rent {
    type: number
    sql: ${TABLE}."DAYS_ON_RENT" ;;
  }

  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }

  dimension: lowest_rate {
    type: number
    sql: ${TABLE}."LOWEST_RATE" ;;
  }

  dimension: month_rate {
    type: number
    sql: ${TABLE}."MONTH_RATE" ;;
  }

  dimension: num_class_units_on_rent {
    type: number
    sql: ${TABLE}."NUM_CLASS_UNITS_ON_RENT" ;;
  }

  dimension: pk {
    type: number
    primary_key: yes
    sql: ${TABLE}."PK" ;;
  }

  dimension: price_per_day {
    type: number
    sql: ${TABLE}."PRICE_PER_DAY" ;;
  }

  dimension: price_per_month {
    type: number
    sql: ${TABLE}."PRICE_PER_MONTH" ;;
  }

  dimension: price_per_week {
    type: number
    sql: ${TABLE}."PRICE_PER_WEEK" ;;
  }

  dimension: week_only_rate {
    type: number
    sql: ${TABLE}."WEEK_ONLY_RATE" ;;
  }

  dimension: week_plus_day_rate {
    type: number
    sql: ${TABLE}."WEEK_PLUS_DAY_RATE" ;;
  }

  dimension: rent_charge {
    type: number
    sql: ${TABLE}."RENT_CHARGE" ;;
  }

  measure: count {
    type: count
    drill_fields: [company_name, branch_name]
  }
}
