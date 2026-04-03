connection: "es_warehouse"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project

explore: keypad_utilization {
  group_label: "Fleet"
  label: "Keypad Utilization Report"
  case_sensitive: no
  persist_for: "10 minutes"

  join: assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${keypad_utilization.asset_id} = ${assets.asset_id} ;;
    # and ${assets.company_id} = {{ _user_attributes['company_id'] }}::numeric;;
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

}
