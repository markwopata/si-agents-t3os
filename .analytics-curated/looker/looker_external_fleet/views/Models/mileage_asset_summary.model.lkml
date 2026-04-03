connection: "reportingc_warehouse"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project

explore: mileage_asset_summary {
  group_label: "Fleet"
  label: "Mileage Report (Asset)"
  case_sensitive: no
  persist_for: "10 minutes"

  sql_always_where: ${mileage_asset_summary.asset_id} in (select asset_id from business_intelligence.triage.stg_t3__asset_info where company_id in (select USERS.company_id from users where user_id = {{_user_attributes['user_id']}}::numeric)) ;;

  join: assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${mileage_asset_summary.asset_id} = ${assets.asset_id};;
  }

  join: asset_settings {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_settings_id} = ${asset_settings.asset_settings_id};;
  }

  join: company_dot_numbers {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.dot_number_id} = ${company_dot_numbers.dot_number_id} ;;
  }

  join:asset_types {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_type_id} = ${asset_types.asset_type_id} ;;
  }

  join: categories {
    type: left_outer
    relationship: many_to_one
    sql_on: ${categories.category_id} = ${assets.category_id} ;;
  }

  join: organization_asset_xref {
    type: left_outer
    relationship: one_to_many
    sql_on: ${assets.asset_id} = ${organization_asset_xref.asset_id} ;;
  }

  join: organizations {
    type: left_outer
    relationship: one_to_many
    sql_on: ${organization_asset_xref.organization_id} = ${organizations.organization_id} ;;
  }

}
