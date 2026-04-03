connection: "es_warehouse"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project
include: "/**/*.view.lkml"                 # include all views in this project

explore: fuel_purchases {
  label: "Fuel Purchases"
  description: "Fuel purchases per asset from es_warehouse.public.fuel_purchases"

    join: organization_asset_xref {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fuel_purchases.asset_id} = ${organization_asset_xref.asset_id} ;;
  }

  join: organizations {
    type: left_outer
    relationship: one_to_many
    sql_on: ${organization_asset_xref.organization_id} = ${organizations.organization_id} ;;
  }
}
