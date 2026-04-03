view: rental_revenue_proportion_isolate {
  derived_table: {
    sql:
      SELECT
        ASSET_ID,
        YEAR,
        MAKE,
        MODEL,
        COMPANY_NAME,
        MARKET_NAME,
        EQUIPMENT_MAKE_ID,
        EQUIPMENT_MODEL_ID,
        ORIGINAL_COST,
        RENTAL_REVENUE_TOTAL,
        RENTAL_PURCHASE_RATIO AS REVENUE_PURCHASE_RATIO,
        RPR_DISTANCE_FROM_GROUP
      from data_science.public.rental_revenue_ratios_temp;;
  }
  dimension: asset_id {}
  dimension: year {}
  dimension: make {}
  dimension: model {}
  dimension: company_name {}
  dimension: market_name {}
  dimension: equipment_make_id {}
  dimension: equipment_model_id {}
  dimension: original_cost {}
  dimension: rental_revenue_total {}
  dimension: revenue_purchase_ratio {}
  dimension: rpr_distance_from_group {}
}
