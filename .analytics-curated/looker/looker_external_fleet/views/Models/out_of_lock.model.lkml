connection: "es_warehouse"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project
#testing push to staging

explore: out_of_lock {
  sql_always_where: ${asset_id} in (select asset_id from table(assetlist({{ _user_attributes['user_id'] }}::numeric)))
      OR
      ${asset_id} in ${rental_asset_list_current.asset_id} ;;
  group_label: "Fleet"
  label: "Out of Lock Assets"
  case_sensitive: no
  persist_for: "10 minutes"

  join: assets {
    type: inner
    relationship: one_to_one
    sql_on: ${out_of_lock.asset_id} = ${assets.asset_id} ;;
  }

  join: rental_asset_list_current {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${rental_asset_list_current.asset_id} ;;
  }

  join: categories {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.category_id} = ${categories.category_id} ;;
  }

  join: asset_types {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_type_id} = ${asset_types.asset_type_id} ;;
  }

  # join: last_asset_location {
  #   type: left_outer
  #   relationship: one_to_one
  #   sql_on: ${assets.asset_id} = ${last_asset_location.asset_id} ;;
  # }

  join: asset_last_location {
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets.asset_id} = ${asset_last_location.asset_id} ;;
  }

  # join: states {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${states.state_id} = ${last_asset_location.state_id} ;;
  # }

  join: trackers {
    type: left_outer
    relationship: one_to_many
    sql_on: ${trackers.tracker_id} = ${assets.tracker_id} ;;
  }

  join: tracker_types {
    type: left_outer
    relationship: many_to_one
    sql_on: ${tracker_types.tracker_type_id} = ${trackers.tracker_type_id} ;;
  }

  join: organization_asset_xref {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${organization_asset_xref.asset_id} ;;
  }

  join: organizations {
    type: left_outer
    relationship: one_to_one
    sql_on: ${organization_asset_xref.organization_id} = ${organizations.organization_id} ;;
  }

  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${markets.market_id} = ${assets.inventory_branch_id} ;;
  }

  join: out_of_lock_count_seven_days_ago {
    type: left_outer
    relationship: one_to_one
    sql_on: ${out_of_lock.asset_id} = ${out_of_lock_count_seven_days_ago.asset_id} ;;
  }

  join: out_of_lock_history_count_by_day {
    type: inner
    relationship: one_to_one
    sql_on: ${out_of_lock_history_count_by_day.asset_id} = ${out_of_lock.asset_id} ;;
  }

  join: out_of_lock_7_days_rolling {
    type: inner
    relationship: one_to_one
    sql_on: ${out_of_lock_7_days_rolling.asset_id} = ${out_of_lock_history_count_by_day.asset_id} and ${out_of_lock_7_days_rolling.snapshot_date} = ${out_of_lock_history_count_by_day.snapshot_date}  ;;
  }

}
