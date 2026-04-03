include: "/_base/es_warehouse/public/company_purchase_order_line_items.view.lkml"

# Fields referencing another view
# -company_purchase_order_line_items.delivery_truck_delta,
# -company_purchase_order_line_items.service_truck_delta,
# -company_purchase_order_line_items.pickup_overage_shortage,
# -company_purchase_order_line_items.t3_overage_shortage

view: +company_purchase_order_line_items {
  label: "Company Purchase Order Line Items"

  dimension: delivery_truck_yn {
    type: yesno
    sql: ${serial} ilike 'delivery truck%' ;;
  }

  dimension: tractor_yn {
    type: yesno
    sql: ${serial} ilike '%tractor%' ;;
  }

  dimension: delivery_trailer_yn {
    type: yesno
    sql: ${serial} ilike 'delivery trailer%' ;;
  }

  dimension: service_truck_yn {
    type: yesno
    sql: ${serial} ilike 'service truck%' ;;
  }

  dimension: premium_pickup_yn {
    type: yesno
    sql: ${serial} ilike 'Premium-1/2 Ton Pickup%' ;;
  }

  dimension: t3_van_yn {
    type: yesno
    sql: ${serial} ilike 'Van-T3%' ;;
  }

  measure: delivery_trucks {
    type: count_distinct
    sql: ${asset_id} ;;
    filters: [delivery_truck_yn: "yes"]
    drill_fields: [transportation_assets*]
  }

  measure: tractors {
    type: count_distinct
    sql: ${asset_id} ;;
    filters: [tractor_yn: "yes"]
    drill_fields: [transportation_assets*]
  }

  measure: total_delivery_trucks {
    type: number
    sql: ${delivery_trucks} + ${tractors} ;;
    drill_fields: [transportation_assets*]
  }

  measure: delivery_truck_delta {
    type: number
    sql: ${total_delivery_trucks} - ${int_asset_historical.model_delivery_trucks} ;;
    drill_fields: []
  }

  measure: delivery_trailers {
    type: count_distinct
    sql: ${asset_id} ;;
    filters: [delivery_trailer_yn: "yes"]
    drill_fields: [transportation_assets*]
  }

  measure: service_trucks {
    type: count_distinct
    sql: ${asset_id} ;;
    filters: [service_truck_yn: "yes"]
    drill_fields: [transportation_assets*]
  }

  measure: service_truck_delta {
    type: number
    sql: ${service_trucks} - ${int_asset_historical.model_service_trucks} ;;
    drill_fields: []
  }

  measure: premium_pickups {
    type: count_distinct
    sql: ${asset_id} ;;
    filters: [premium_pickup_yn: "yes"]
    drill_fields: [transportation_assets*]
  }

  measure: pickup_overage_shortage {
    type: number
    sql: ${premium_pickups} - ${company_directory.managers} ;;
    drill_fields: []
  }

  measure: t3_vans {
    type: count_distinct
    sql: ${asset_id} ;;
    filters: [t3_van_yn: "yes"]
    drill_fields: [transportation_assets*]
  }

  measure: t3_overage_shortage {
    type: number
    sql: ${t3_vans} - ${company_directory.telematics_installers} ;;
    drill_fields: []
  }

  set: transportation_assets {
    fields: [asset_id,
      fact_operator_assignments.operator_name,
      v_assets.asset_equipment_class_name,
      v_assets.asset_equipment_make,
      v_assets.asset_equipment_model_name,
      v_assets.asset_year,
      int_asset_historical.total_oec,
      financial_utilization.financial_utilization]
  }
}
