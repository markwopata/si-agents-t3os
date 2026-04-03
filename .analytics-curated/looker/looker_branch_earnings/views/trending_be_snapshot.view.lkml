view: trending_be_snapshot {
  sql_table_name: "BRANCH_EARNINGS"."TRENDING_BE_SNAPSHOT" ;;

  dimension_group: dbt_valid_to {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DBT_VALID_TO" ;;
  }
  dimension: delta {
    type: number
    sql: ${TABLE}."DELTA" ;;
    value_format: "$#,##0.00"

  }
  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }
  dimension: filter_month {
    type: string
    sql: ${TABLE}."FILTER_MONTH" ;;
  }
  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: pk_id {
    type: string
    sql: ${TABLE}."PK_ID" ;;
  }


  dimension_group: snapshot_day {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."SNAPSHOT_DAY" ;;
  }
  dimension: source_model {
    type: string
    sql: ${TABLE}."SOURCE_MODEL" ;;
  }
  dimension_group: timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP" ;;
  }
  dimension: transaction_number {
    type: string
    sql: ${TABLE}."TRANSACTION_NUMBER" ;;
  }
  dimension: transaction_number_format {
    type: string
    sql: ${TABLE}."TRANSACTION_NUMBER_FORMAT" ;;
  }
  measure: count {
    type: count
  }
}
