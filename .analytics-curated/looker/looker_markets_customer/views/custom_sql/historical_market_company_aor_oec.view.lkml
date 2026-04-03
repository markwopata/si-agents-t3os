
view: historical_market_company_aor_oec {
  derived_table: {
    sql: select *
      FROM analytics.bi_ops.historical_arc
      UNION
      SELECT *
      FROM analytics.bi_ops.current_arc ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension_group: date {
    type: time
    sql: ${TABLE}."DATE" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: assets_on_rent {
    type: number
    sql: ${TABLE}."ASSETS_ON_RENT" ;;
  }

  measure: assets_on_rent_sum {
    type: sum
    sql: ${assets_on_rent} ;;

  }

  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  measure: actively_renting_customers {
    type: count_distinct
    sql: ${company_id} ;;
  }


  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: oec_on_rent {
    type: number
    sql: ${TABLE}."OEC_ON_RENT" ;;
    value_format_name: usd_0
  }

  measure: oec_on_rent_sum {
    type: sum
    sql:  ${oec_on_rent} ;;
  }

  dimension: one_flag {
    type: number
    sql: ${TABLE}."ONE_FLAG" ;;
  }

  set: detail {
    fields: [
        date_date,
  market_id,
  market_name,
  district,
  region,
  region_name,
  market_type,
  assets_on_rent,

  company_name,
  oec_on_rent,

    ]
  }
}
