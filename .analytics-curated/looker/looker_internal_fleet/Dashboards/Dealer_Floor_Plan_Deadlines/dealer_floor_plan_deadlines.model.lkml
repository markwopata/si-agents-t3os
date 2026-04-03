connection: "es_snowflake"

include: "/views/company_purchase_order_line_items.view.lkml"
include: "/views/company_purchase_orders.view.lkml"
include: "/views/company_purchase_order_types.view.lkml"
include: "/views/equipment_models.view.lkml"
include: "/views/equipment_makes.view.lkml"
include: "/views/equipment_classes_models_xref.view.lkml"
include: "/views/equipment_classes.view.lkml"
include: "/views/assets.view"
include: "/views/markets.view"
include: "/views/market_region_xwalk.view"
include: "/views/users.view"
include: "/views/asset_purchase_history.view"
include: "/views/asset_types.view"
include: "/views/companies.view"
include: "/Dashboards/Dealer_Floor_Plan_Deadlines/views/asset_purchase_history_extended.view"
include: "/views/financial_schedules.view"


# https://app.shortcut.com/businessanalytics/story/216492/dealer-floor-plan-unit-deadlines-andrew-cowherd
explore: company_purchase_order_line_items {
  label: "Floor Plan Deadlines"
  # always_join: [asset_purchase_history]
  persist_for: "15 minutes"
  sql_always_where: ${deleted_date} IS NULL and ${company_purchase_orders.approved_by_user_id} is not null
                   and ${companies.name} REGEXP 'IES[\\d|\\-].+' and ${assets.asset_type_id} = 1
                   and ${finance_status} like '%Floor Plan';; # only retail and only equipment


  join: asset_purchase_history_extended {
    from: asset_purchase_history_extended
    type: inner
    relationship: one_to_one
    sql_on: ${company_purchase_order_line_items.asset_id} = ${asset_purchase_history_extended.asset_id} ;;
  }

  join: assets {
    type: left_outer
    relationship: one_to_one
    sql_on: ${company_purchase_order_line_items.asset_id} = ${assets.asset_id} ;;
  }

  join: companies {
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets.company_id} = ${companies.company_id} ;;
  }

  join: company_purchase_orders {
    type: left_outer
    relationship: one_to_one
    sql_on: ${company_purchase_order_line_items.company_purchase_order_id} = ${company_purchase_orders.company_purchase_order_id} ;;
  }

  join: company_purchase_order_types {
    type: left_outer
    relationship: one_to_one
    sql_on: ${company_purchase_order_types.company_purchase_order_type_id} = ${company_purchase_orders.company_purchase_order_type_id} ;;
  }

  join: equipment_models {
    type: left_outer
    relationship: one_to_one
    sql_on: ${company_purchase_order_line_items.equipment_model_id} = ${equipment_models.equipment_model_id} ;;
  }

  join: equipment_makes {
    type: left_outer
    relationship: one_to_one
    sql_on: ${equipment_models.equipment_make_id} = ${equipment_makes.equipment_make_id} ;;
  }

  join: equipment_classes_models_xref {
    type: left_outer
    relationship: one_to_one
    sql_on: ${equipment_models.equipment_model_id} = ${equipment_classes_models_xref.equipment_model_id} ;;
  }

  join: equipment_classes {
    type: left_outer
    relationship: one_to_one
    sql_on: ${equipment_classes.equipment_class_id} = coalesce(${equipment_classes_models_xref.equipment_class_id}, ${company_purchase_order_line_items.equipment_class_id}) ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${company_purchase_order_line_items.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: financial_schedules {
    type: left_outer
    relationship: one_to_one
    sql_on: ${asset_purchase_history_extended.financial_schedule_id} = ${financial_schedules.financial_schedule_id} ;;
  }

}
