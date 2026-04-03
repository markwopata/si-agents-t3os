
view: market_region_xwalk {
  sql_table_name: analytics.public.market_region_xwalk;;


  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: parent_market_id {
    type: string
    sql: ${TABLE}."PARENT_MARKET_ID" ;;
  }

  dimension: parent_market_name {
    type: string
    sql: ${TABLE}."PARENT_MARKET_NAME" ;;
  }

  dimension: branch_earnings_start_month {
    type: date
    sql: ${TABLE}."BRANCH_EARNINGS_START_MONTH" ;;
  }

  dimension: current_months_open {
    type: number
    sql: ${TABLE}."CURRENT_MONTHS_OPEN" ;;
  }

  dimension: is_open_over_12_months {
    type: yesno
    sql: ${TABLE}."IS_OPEN_OVER_12_MONTHS" ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  dimension: abbreviation {
    type: string
    sql: ${TABLE}."ABBREVIATION" ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: area_code {
    type: string
    sql: ${TABLE}."AREA_CODE" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: region_district {
    type: string
    sql: ${TABLE}."REGION_DISTRICT" ;;
  }

  dimension: _id_dist {
    type: string
    sql: ${TABLE}."_ID_DIST" ;;
  }

  dimension: market_type_id {
    type: string
    sql: ${TABLE}."MARKET_TYPE_ID" ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: is_dealership {
    type: yesno
    sql: ${TABLE}."IS_DEALERSHIP" ;;
  }

  dimension: division_id {
    type: string
    sql: ${TABLE}."DIVISION_ID" ;;
  }

  dimension: division_name {
    type: string
    sql: ${TABLE}."DIVISION_NAME" ;;
  }

  dimension_group: date_updated {
    type: time
    sql: ${TABLE}."DATE_UPDATED" ;;
  }

  set: detail {
    fields: [
        market_id,
  market_name,
  parent_market_id,
  parent_market_name,
  branch_earnings_start_month,
  current_months_open,
  is_open_over_12_months,
  state,
  abbreviation,
  region,
  region_name,
  area_code,
  district,
  region_district,
  _id_dist,
  market_type_id,
  market_type,
  is_dealership,
  division_id,
  division_name,
  date_updated_time
    ]
  }
}
