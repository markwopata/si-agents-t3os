connection: "es_warehouse"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project

explore: assets {
  case_sensitive: no
  group_label: "Demo"
  label: "Assets View"
  sql_always_where: ${asset_id} in (select asset_id from table(assetlist('{{ _user_attributes['user_id'] }}'::numeric))) ;;

  join: asset_statuses {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${asset_statuses.asset_id} ;;
  }

  join: assets_aggregate {
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets.asset_id} = ${assets_aggregate.asset_id} ;;
  }

  join: categories {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.category_id} = ${categories.category_id} ;;
  }
}

explore: work_orders {
  sql_always_where: ${assets_aggregate.company_id} =  '{{ _user_attributes['company_id'] }}' ;;

  join: work_orders_by_tag {
    type: left_outer
    relationship: many_to_many
    sql_on: ${work_orders_by_tag.work_order_id} = ${work_orders.work_order_id} ;;
  }

  join: assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_orders.asset_id} = ${assets.asset_id} ;;
  }

  join: assets_aggregate {
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets.asset_id} = ${assets_aggregate.asset_id} ;;
  }
}

explore: driver_log_summary {
  sql_always_where: ${users.company_id} =  '{{ _user_attributes['company_id'] }}' ;;

  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: ${users.user_id} = ${users.employer_user_id} ;;
  }

}

explore: time_tracking_entries {
  sql_always_where: ${user_id} =  '{{ _user_attributes['user_id'] }}' ;;


}

explore: tracking_diagnostic_and_obd_codes {
  sql_always_where: ${assets_aggregate.company_id} =  '{{ _user_attributes['company_id'] }}' ;;

  join: assets_aggregate {
    type: left_outer
    relationship: one_to_one
    sql_on: ${tracking_diagnostic_and_obd_codes.asset_id} = ${assets_aggregate.asset_id} ;;
  }

}

explore: assets_test {
  from: assets
  sql_always_where: ${asset_id} in (select asset_id from table(assetlist(5688))) ;;
  # sql_always_where: ${asset_id} in (select asset_id from table(assetlist('{{ _user_attributes['user_id'] }}'::numeric))) ;;

  join: organization_asset_xref {
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets_test.asset_id} = ${organization_asset_xref.asset_id} ;;
  }

  join: markets {
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets_test.inventory_branch_id} = ${markets.market_id} ;;
  }

  join: asset_hours {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_hours.asset_id} = ${assets_test.asset_id} ;;
  }

  # join: scd_asset_hours {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${assets_test.asset_id} = ${scd_asset_hours.asset_id} ;;
  # }

  # join: asset_start_hours {
  #   type: left_outer
  #   relationship: one_to_one
  #   sql_on: ${asset_start_hours.asset_id} = ${assets_test.asset_id} ;;
  # }

  # join: asset_end_hours {
  #   type: left_outer
  #   relationship: one_to_one
  #   sql_on: ${asset_end_hours.asset_id} = ${asset_start_hours.asset_id} ;;
  # }

  join: organizations {
    type: left_outer
    relationship: one_to_one
    sql_on: ${organization_asset_xref.organization_id} = ${organizations.organization_id} ;;
  }
}
