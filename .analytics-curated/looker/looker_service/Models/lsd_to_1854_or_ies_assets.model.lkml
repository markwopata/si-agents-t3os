connection: "es_snowflake_analytics"
label: "Asset Company Transitions"

include: "/views/FLEET_OPTIMIZATION/dim_asset_company_pit.view.lkml"
include: "/views/FLEET_OPTIMIZATION/dim_companies_fleet_opt.view.lkml"
include: "/views/FLEET_OPTIMIZATION/dim_assets_fleet_opt.view.lkml"



explore: dim_asset_company_pit {
  label: "LSD to 1854 or IES Assets"

  join: previous_company {
    from: dim_companies_fleet_opt
    view_label: "Previous"
    relationship: many_to_one
    sql_on: ${dim_asset_company_pit.previous_company_id} = ${previous_company.company_id} ;;
  }

  join: current_company {
    from: dim_companies_fleet_opt
    view_label: "Current"
    relationship: many_to_one
    sql_on: ${dim_asset_company_pit.current_company_id} = ${current_company.company_id} ;;
  }

  join: dim_assets_fleet_opt {
    relationship: many_to_one
    sql_on: ${dim_asset_company_pit.asset_id} = ${dim_assets_fleet_opt.asset_id} ;;
  }
}
