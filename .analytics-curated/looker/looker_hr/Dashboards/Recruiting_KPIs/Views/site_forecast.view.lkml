view: site_forecast {
  sql_table_name: "GREENHOUSE"."SITE_FORECAST"
    ;;

  dimension: market_name {
    primary_key: yes
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: msa {
    type: string
    sql: ${TABLE}."MSA" ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  dimension: target_open_date {
    type: string
    sql: ${TABLE}."TARGET_OPEN_DATE" ;;
  }

  dimension: tier {
    type: string
    sql: ${TABLE}."TIER" ;;
  }

  dimension: year {
    type: string
    sql: ${TABLE}."YEAR" ;;
  }

  dimension: year_quarter {
    type: string
    sql: ${TABLE}."YEAR_QUARTER" ;;
  }

  measure: count {
    type: count
    drill_fields: [market_name, region_name]
  }
}
