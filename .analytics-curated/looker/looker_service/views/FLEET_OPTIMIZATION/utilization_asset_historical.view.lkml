view: utilization_asset_historical {
  sql_table_name: "FLEET_OPTIMIZATION"."GOLD"."UTILIZATION_ASSET_HISTORICAL" ;;

  dimension: agg_dif_calculation_key {
    type: string
    sql: ${TABLE}."AGG_DIF_CALCULATION_KEY" ;;
  }
  dimension: agg_dor_calculation_key {
    type: string
    sql: ${TABLE}."AGG_DOR_CALCULATION_KEY" ;;
  }
  dimension: agg_rev_calculation_key {
    type: string
    sql: ${TABLE}."AGG_REV_CALCULATION_KEY" ;;
  }
  dimension: asset_company_id {
    type: string
    sql: ${TABLE}."ASSET_COMPANY_ID" ;;
  }
  dimension: asset_count {
    type: number
    sql: ${TABLE}."ASSET_COUNT" ;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: days_on_rent_clean {
    type: number
    sql: ${TABLE}."DAYS_ON_RENT_CLEAN" ;;
  }
  dimension: financial_utilization {
    type: number
    sql: ${TABLE}."FINANCIAL_UTILIZATION" ;;
  }
  dimension: in_fleet_oec {
    type: number
    sql: ${TABLE}."IN_FLEET_OEC" ;;
  }
  dimension: oec_adjusted {
    type: number
    sql: ${TABLE}."OEC_ADJUSTED" ;;
  }
  dimension: oec_used_for_calculations {
    type: number
    sql: ${TABLE}."OEC_USED_FOR_CALCULATIONS" ;;
  }
  dimension: rental_oec {
    type: number
    sql: ${TABLE}."RENTAL_OEC" ;;
  }
  dimension: revenue_clean {
    type: number
    sql: ${TABLE}."REVENUE_CLEAN" ;;
  }
  dimension: tf_key {
    type: string
    sql: ${TABLE}."TF_KEY" ;;
  }
  dimension: time_utilization {
    type: number
    value_format_name: percent_1
    sql: ${TABLE}."TIME_UTILIZATION" ;;
  }
  dimension: unit_utilization {
    type: number
    value_format_name: percent_1
    sql: ${TABLE}."UNIT_UTILIZATION" ;;
  }
  dimension: utilization_historical_key {
    type: string
    sql: ${TABLE}."UTILIZATION_HISTORICAL_KEY" ;;
  }
  measure: count {
    type: count
  }
}
