view: v_assets {

  sql_table_name: "FLEET_OPTIMIZATION"."GOLD"."DIM_ASSETS_FLEET_OPT" ;;

  dimension: asset_current_oec {
    type: number
    sql: ${TABLE}."ASSET_CURRENT_OEC" ;;
  }

  dimension: asset_class {
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
  }

  dimension: asset_equipment_make {
    type: string
    sql: ${TABLE}."ASSET_EQUIPMENT_MAKE" ;;
  }

  dimension: asset_equipment_model_name {
    type: string
    sql: ${TABLE}."ASSET_EQUIPMENT_MODEL_NAME" ;;
  }

  dimension: asset_id {
    type: number
    primary_key: yes
    sql: ${TABLE}."ASSET_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: average_oec {
    type: average
    sql: ${asset_current_oec} ;;
    value_format_name: usd
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      asset_current_oec,
      asset_equipment_make,
      asset_id,
      asset_equipment_model_name,
    ]
  }

}
