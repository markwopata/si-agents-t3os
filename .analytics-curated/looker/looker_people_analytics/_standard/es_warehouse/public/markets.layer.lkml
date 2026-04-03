include: "/_base/es_warehouse/public/markets.view.lkml"

view: +markets {

  ############### DIMENSIONS ###############
  dimension: market_id {
    value_format_name: id
  }
  dimension: company_id {
    value_format_name: id
  }
  dimension: state_id {
    value_format_name: id
  }
  dimension: location_id {
    value_format_name: id
  }
  dimension: district_id {
    value_format_name: id
  }
  dimension: account_rep_user_id {
    value_format_name: id
  }
  dimension: default_zip_code_id {
    value_format_name: id
  }
  dimension: market_name {
    type: string
    sql: CASE WHEN ${TABLE}."NAME" IS NULL THEN 'Corporate' ELSE ${TABLE}."NAME" END ;;
    suggest_persist_for: "5 minutes"
  }

  ############### DATES ###############
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw,time,date,week,month,quarter,year]
    sql: ${_es_update_timestamp} ;;
  }
  dimension_group: date_updated {
    type: time
    timeframes: [raw,time,date,week,month,quarter,year]
    sql: ${date_updated} ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw,time,date,week,month,quarter,year]
    sql: ${date_created} ;;
  }
}
