view: service_revenue_ratios_v0_0_1 {
  derived_table: {
    sql:
      SELECT
        ASSET_ID,
        MAKE,
        MODEL,
        EQUIPMENT_MAKE_ID,
        EQUIPMENT_MODEL_ID,
        SERVICE_COST_TOTAL,
        SERVICE_PURCHASE_RATIO,
        SPR_DISTANCE_FROM_GROUP,
        RENTAL_REVENUE_TOTAL,
        REVENUE_PURCHASE_RATIO,
        RPR_DISTANCE_FROM_GROUP,
        SERVICE_REVENUE_RATIO,
        SRR_DISTANCE_FROM_GROUP
      from data_science.public.service_revenue_ratios_temp;;
  }
  dimension: asset_id {}
  dimension: make {}
  dimension: model {}
  dimension: equipment_make_id {}
  dimension: equipment_model_id {}
  dimension: service_cost_total {}
  dimension: service_purchase_ratio {}
  dimension: spr_distance_from_group {}
  dimension: rental_revenue_total {}
  dimension: revenue_purchase_ratio {}
  dimension: rpr_distance_from_group {}
  dimension: service_revenue_ratio {}
  dimension: srr_distance_from_group {}
}
