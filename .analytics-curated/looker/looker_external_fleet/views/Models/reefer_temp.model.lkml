connection: "es_warehouse"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project

explore: reefer_temp_report {
  group_label: "Fleet"
  label: "Reefer Temperature Report"
  case_sensitive: no
  sql_always_where: ${assets.asset_id} in (select asset_id from table(assetlist({{ _user_attributes['user_id'] }}::numeric))) ;;
  persist_for: "10 minutes"

  join: assets {
    sql_on: ${reefer_temp_report.asset_id} = ${assets.asset_id} ;;
    relationship: one_to_one
    #sql_where: ${assets.asset_id} in (select asset_id from table(assetlist({{ _user_attributes['user_id'] }}::numeric))) ;;
  }

  join: asset_types {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_type_id} = ${asset_types.asset_type_id} ;;
  }

  join: organization_asset_xref {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${organization_asset_xref.asset_id} ;;
  }

  join: categories {
    type: left_outer
    relationship: many_to_one
    sql_on: ${categories.category_id} = ${assets.category_id} ;;
  }
}
