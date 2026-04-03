view: DIM_DATE {
  sql_table_name: "BRANCH_EARNINGS"."DIM_DATE"
    ;;

  dimension: CURRENT_MONTH {
    type: yesno
    sql: ${TABLE}."CURRENT_MONTH" ;;
  }

  dimension: DATE {
    type: date
    primary_key: yes
    sql: ${TABLE}."DATE" ;;
  }

  dimension: DAY {
    type: number
    sql: ${TABLE}."DAY" ;;
  }

  dimension: DAY_OF_WEEK {
    type: number
    sql: ${TABLE}."DAY_OF_WEEK" ;;
  }

  dimension: DAY_OF_YEAR {
    type: number
    sql: ${TABLE}."DAY_OF_YEAR" ;;
  }

  dimension: HAS_DATA {
    type: yesno
    sql: ${TABLE}."HAS_DATA" ;;
  }

  dimension: HAS_DATA_TIME_ENTRY {
    type: yesno
    sql: ${TABLE}."HAS_DATA_TIME_ENTRY" ;;
  }

  dimension: MONTH {
    type: number
    sql: ${TABLE}."MONTH" ;;
  }

  dimension: MONTH_NAME {
    type: string
    order_by_field: MONTH
    sql: ${TABLE}."MONTH_NAME" ;;
  }

  dimension: MONTH_TO_DATE {
    type: yesno
    sql: ${TABLE}."MONTH_TO_DATE" ;;
  }

  dimension: NEXT_PERIOD {
    type: string
    order_by_field: YEAR_MONTH
    sql: ${TABLE}."NEXT_PERIOD" ;;
  }

  dimension: PERIOD {
    type: string
    order_by_field: YEAR_MONTH
    sql: ${TABLE}."PERIOD" ;;
  }

  dimension: PRIOR_MONTH {
    type: yesno
    sql: ${TABLE}."PRIOR_MONTH" ;;
  }

  dimension: PRIOR_MONTH_TO_DATE {
    type: yesno
    sql: ${TABLE}."PRIOR_MONTH_TO_DATE" ;;
  }

  dimension: PRIOR_PERIOD {
    type: string
    order_by_field: YEAR_MONTH
    sql: ${TABLE}."PRIOR_PERIOD" ;;
  }

  dimension: PRIOR_QUARTER {
    type: yesno
    sql: ${TABLE}."PRIOR_QUARTER" ;;
  }

  dimension: QUARTER_TO_DATE {
    type: yesno
    sql: ${TABLE}."QUARTER_TO_DATE" ;;
  }

  dimension: RECORD_CREATED_TIMESTAMP {
    type: date_time
    sql: ${TABLE}."RECORD_CREATED_TIMESTAMP" ;;
  }

  dimension: RECORD_MODIFIED_TIMESTAMP {
    type: date_time
    sql: ${TABLE}."RECORD_MODIFIED_TIMESTAMP" ;;
  }

  dimension: WEEK_OF_YEAR {
    type: number
    sql: ${TABLE}."WEEK_OF_YEAR" ;;
  }

  dimension: YEAR {
    type: number
    sql: ${TABLE}."YEAR" ;;
  }

  dimension: YEAR_TO_DATE {
    type: yesno
    sql: ${TABLE}."YEAR_TO_DATE" ;;
  }

  dimension: YEAR_MONTH {
    type:  string
    sql:  ${TABLE}."YEAR_MONTH" ;;
  }

  measure: count {
    type: count
    hidden: yes
    drill_fields: [YEAR, MONTH_NAME, DAY, DATE]
  }

  measure: NUMBER_OF_PERIODS {
    type: count_distinct
    sql: ${PERIOD} ;;
    hidden: yes
    drill_fields: [PERIOD]
  }
}
