connection: "es_snowflake"
# connection: "es_snowflake_analytics"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project
# include: "/**/*.view.lkml"                 # include all views in this project
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard
include: "/Dashboards/Ideal_Core_Fleet_Mix/views/*.view.lkml"
# include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
# include: "/views/ES_WAREHOUSE/companies.view.lkml"
# include: "/views/ES_WAREHOUSE/markets.view.lkml"

# for use with the Ideal Core Fleet Mix Dashboard
explore: assets_aggregate {
  case_sensitive: no
  label: "Ideal Core Fleet Mix"
  description: "Use this explore for pulling the ideal core fleet mix percentages"
  fields: [ALL_FIELDS*
  ]

  # join: companies {
  #   type: inner
  #   relationship: many_to_one
  #   sql_on: ${customer_rebates.customer_id} = ${companies.company_id} ;;
  # }

  # join: markets {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${v_line_items.branch_id} = ${markets.market_id};;
  # }

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = COALESCE(${assets_aggregate.rental_branch_id}, ${assets_aggregate.inventory_branch_id}) ;;
  }

  join: equipment_classes {
    type: left_outer
    relationship: many_to_one
    sql_on: ${equipment_classes.equipment_class_id} = ${assets_aggregate.equipment_class_id} ;;
  }

  # join: categories {
  #   type: left_outer
  #   relationship: one_to_one
  #   sql_on: ${categories.category_id} = ${equipment_classes.category_id} ;;
  # }

  join: ideal_core_fleet_mix {
    type: left_outer
    relationship: many_to_one
    sql_on: ${ideal_core_fleet_mix.equipment_class_id} = ${assets_aggregate.equipment_class_id} ;;
  }

  join: ideal_markets {
    type:  left_outer
    relationship:  many_to_one
    sql_on: ${ideal_markets.market_id} = COALESCE(${assets_aggregate.rental_branch_id}, ${assets_aggregate.inventory_branch_id}) ;;
  }

  join: asset_financing_snapshots {
    type: left_outer
    relationship: one_to_many
    sql_on: ${assets_aggregate.asset_id} = ${asset_financing_snapshots.asset_id} ;;
  }

  join: eom_oec_by_market {
    type: left_outer
    relationship: one_to_many
    sql_on: (${equipment_classes.equipment_class_id} = ${eom_oec_by_market.equipment_class_id}
    AND ${market_region_xwalk.market_id} = ${eom_oec_by_market.market_id}) ;;
  }

  join: eom_oec_by_class {
    type: left_outer
    relationship: one_to_many
    sql_on: ${equipment_classes.equipment_class_id} = ${eom_oec_by_class.equipment_class_id} ;;
    }

  join: time_and_fin_ute_by_class_market {
    type: left_outer
    relationship: one_to_one
    sql_on: (${eom_oec_by_market.equipment_class_id} = ${time_and_fin_ute_by_class_market.equipment_class_id}
      AND ${eom_oec_by_market.date_date} = ${time_and_fin_ute_by_class_market.date_date}
      AND ${eom_oec_by_market.market_id} = ${time_and_fin_ute_by_class_market.market_id}) ;;
  }

  join: time_and_fin_ute_by_class {
    type: left_outer
    relationship: one_to_one
    sql_on: (${equipment_classes.equipment_class_id} = ${time_and_fin_ute_by_class.equipment_class_id}
      AND ${eom_oec_by_class.date_date} = ${time_and_fin_ute_by_class.date_date}) ;;
  }

}
