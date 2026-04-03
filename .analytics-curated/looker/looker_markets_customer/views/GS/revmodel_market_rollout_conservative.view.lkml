
view: revmodel_market_rollout_conservative {
  sql_table_name: ANALYTICS.GS.REVMODEL_MARKET_ROLLOUT_CONSERVATIVE ;;


  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: financing_start_month {
    type: date
    sql: ${TABLE}."FINANCING_START_MONTH" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: sales_start_month {
    type: date
    sql: ${TABLE}."SALES_START_MONTH" ;;
  }

  dimension_group: _fivetran_synced {
    type: time
    sql: ${TABLE}."_FIVETRAN_SYNCED" ;;
  }

  dimension: branch_earnings_start_month {
    type: date
    sql: ${TABLE}."BRANCH_EARNINGS_START_MONTH" ;;
  }

  dimension: current_months_open {
    type: number
    sql: datediff(months, ${branch_earnings_start_month}, current_date) + 1 ;;
  }

 dimension: is_current_months_open_greater_than_twelve {
    type: yesno
    sql: ${current_months_open} > 12 ;;
  }

  dimension: market_level {
    type: string
    sql: ${TABLE}."MARKET_LEVEL" ;;
  }

  dimension: market_start_month {
    type: string
    sql: ${TABLE}."MARKET_START_MONTH" ;;
  }

  set: detail {
    fields: [
  market_id,
  market_name,
  branch_earnings_start_month,
  current_months_open,
  is_current_months_open_greater_than_twelve,
  _fivetran_synced_time,
    ]
  }
}
