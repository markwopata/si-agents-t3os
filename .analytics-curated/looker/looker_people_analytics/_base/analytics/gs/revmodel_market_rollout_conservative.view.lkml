view: revmodel_market_rollout_conservative {
  sql_table_name: "GS"."REVMODEL_MARKET_ROLLOUT_CONSERVATIVE" ;;

  dimension_group: _fivetran_synced {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
  }
  dimension: branch_earnings_start_month {
    type: string
    sql: ${TABLE}."BRANCH_EARNINGS_START_MONTH" ;;
  }
  dimension_group: financing_start_month {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."FINANCING_START_MONTH" ;;
  }
  dimension: market_end_month {
    type: string
    sql: ${TABLE}."MARKET_END_MONTH" ;;
  }
  dimension: market_factor {
    type: number
    sql: ${TABLE}."MARKET_FACTOR" ;;
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: market_level {
    type: string
    sql: ${TABLE}."MARKET_LEVEL" ;;
  }
  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }
  dimension_group: market_start_month {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."MARKET_START_MONTH" ;;
  }
  dimension: model_name {
    type: string
    sql: ${TABLE}."MODEL_NAME" ;;
  }
  dimension: outside_service_model {
    type: string
    sql: ${TABLE}."OUTSIDE_SERVICE_MODEL" ;;
  }
  dimension_group: outside_service_start_month {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."OUTSIDE_SERVICE_START_MONTH" ;;
  }
  dimension: rental_model_start_month {
    type: string
    sql: ${TABLE}."RENTAL_MODEL_START_MONTH" ;;
  }
  dimension: sale_leaseback {
    type: string
    sql: ${TABLE}."SALE_LEASEBACK" ;;
  }
  dimension: sale_leaseback_month {
    type: string
    sql: ${TABLE}."SALE_LEASEBACK_MONTH" ;;
  }
  dimension: sales_model {
    type: string
    sql: ${TABLE}."SALES_MODEL" ;;
  }
  dimension_group: sales_start_month {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."SALES_START_MONTH" ;;
  }
  dimension: xero_market_name {
    type: string
    sql: ${TABLE}."XERO_MARKET_NAME" ;;
  }
  measure: count {
    type: count
    drill_fields: [model_name, market_name, xero_market_name]
  }
}
