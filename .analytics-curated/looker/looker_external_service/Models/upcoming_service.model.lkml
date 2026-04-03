connection: "es_warehouse"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project

explore: asset_service_intervals {
  group_label: "Service"
  label: "Upcoming Service"
  sql_always_where:
  ${assets.deleted} = 'No'
  and
  (
  ${assets.company_id} = {{ _user_attributes['company_id'] }}
  OR ${markets_service.company_id} = {{ _user_attributes['company_id'] }}
  )

    ;;
  # persist_for: "10 minutes"

  join: assets {
    type: inner
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${asset_service_intervals.asset_id} ;;
  }

  join: categories {
    type: left_outer
    relationship: many_to_one
    sql_on: ${categories.category_id} = ${assets.category_id} ;;
  }

  join: asset_status_key_values {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_status_key_values.asset_id} = ${assets.asset_id} ;;
  }

  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${markets.market_id} = ${assets.inventory_branch_id} ;;
  }

  join: markets_service {
    from: markets
    type: inner
    relationship: one_to_many
    sql_on: ${markets_service.market_id} = ${assets.service_branch_id} ;;
  }

  join: asset_projected_service_parts {
    type: inner
    relationship: many_to_one
    sql_on: ${asset_projected_service_parts.asset_id} = ${asset_service_intervals.asset_id} and ${asset_projected_service_parts.maintenance_group_interval_id} = ${asset_service_intervals.maintenance_group_interval_id} ;;
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

  join: work_orders {
    type: left_outer
    relationship: one_to_one
    sql_on: ${work_orders.work_order_id} = ${asset_service_intervals.work_order_id} ;;
  }

  join: work_order_originators {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_order_originators.work_order_id} = ${work_orders.work_order_id} ;;
  }

  join: originator_types {
    type: left_outer
    relationship: many_to_one
    sql_on: ${originator_types.originator_type_id} = ${work_order_originators.originator_type_id} ;;
  }

  join: work_order_user_assignments {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_order_user_assignments.work_order_id} = ${work_orders.work_order_id} AND (${work_order_user_assignments.end_raw} is null OR ${work_order_user_assignments.end_raw} <= current_timestamp()) ;;
  }

  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_order_user_assignments.user_id} = ${users.user_id} ;;
  }

}
