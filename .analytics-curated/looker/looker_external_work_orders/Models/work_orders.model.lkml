connection: "reportingc_warehouse"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project

explore: work_orders {
  group_label: "Work Orders"
  label: "Work Orders Info"
  case_sensitive: no
  sql_always_where: ${archived_date} is null
  AND ${markets.company_id} in ('{{ _user_attributes['company_id'] }}'::numeric)
  AND ${markets.active} = TRUE;;
  #AND
  #(${asset_id} in (select asset_id from table(assetlist({{ _user_attributes['user_id'] }}::numeric)))
  #OR
  #${assets.asset_id} in (select asset_id from table(rental_asset_list({{ _user_attributes['user_id'] }}::numeric, convert_timezone('UTC', '{{ _user_attributes['user_timezone'] }}', current_date::timestamp_ntz), convert_timezone('UTC', '{{ _user_attributes['user_timezone'] }}',  current_date::timestamp_ntz), '{{ _user_attributes['user_timezone'] }}')))) ;;
  # AND ${assets.company_id} in ('{{ _user_attributes['company_id'] }}'::numeric) ;;
  # ${work_order_type_id} = 1 AND
  # AND ${markets.company_id} in '{{ _user_attributes['company_id'] }}'
  persist_for: "10 minutes"

  join: markets {
    type: inner
    relationship: many_to_one
    sql_on: ${work_orders.branch_id} = ${markets.market_id} ;;
  }

  join: assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${work_orders.asset_id} ;;
  }

  join: categories {
    type: left_outer
    relationship: many_to_one
    sql_on: ${categories.category_id} = ${assets.category_id} ;;
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

  join: work_orders_status_last_seven_days {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_orders.work_order_id} = ${work_orders_status_last_seven_days.work_order_id} ;;
    #${work_orders_status_last_seven_days.asset_id} = ${assets.asset_id} and
  }

  join: urgency_levels {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_orders.urgency_level_id} = ${urgency_levels.urgency_level_id} ;;
  }

  join: asset_last_location {
    type: inner
    relationship: one_to_one
    sql_on: ${assets.asset_id} = ${asset_last_location.asset_id} ;;
  }

  join: markets_branch {
    from: markets
    type: left_outer
    relationship: many_to_one
    sql_on: ${markets_branch.market_id} = ${assets.service_branch_id} ;;
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

  # join: work_order_user_assignments {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${work_order_user_assignments.work_order_id} = ${work_orders.work_order_id} AND (${work_order_user_assignments.end_raw} is null OR ${work_order_user_assignments.end_raw} <= current_timestamp()) ;;
  # }

  # join: users {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${work_order_user_assignments.user_id} = ${users.user_id} ;;
  # }

  # join: work_order_company_tags {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${work_order_company_tags.work_order_id} = ${work_orders.work_order_id} ;;
  # }

  # join: company_tags {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${work_order_company_tags.company_tag_id} = ${company_tags.company_tag_id} ;;
  # }

}

explore: wo_to_hard_down_assets {
  group_label: "Work Orders"
  label: "Work Orders tied to Hard Down Assets"
  case_sensitive: no
  sql_always_where: ${markets_branch.company_id} in ('{{ _user_attributes['company_id'] }}'::numeric) ;;
  # ${asset_id} in (select asset_id from table(assetlist({{ _user_attributes['user_id'] }}::numeric))) ;;
  persist_for: "10 minutes"

  join: assets {
    type: inner
    relationship: many_to_one
    sql_on: ${wo_to_hard_down_assets.asset_id} = ${assets.asset_id} ;;
  }

  join: categories {
    type: left_outer
    relationship: many_to_one
    sql_on: ${categories.category_id} = ${assets.category_id} ;;
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

  join: markets_branch {
    from: markets
    type: left_outer
    relationship: many_to_one
    sql_on: ${markets_branch.market_id} = ${work_orders.branch_id} ;;
  }

  join: work_orders {
    type: inner
    relationship: one_to_one
    sql_on: ${work_orders.work_order_id} = ${wo_to_hard_down_assets.work_order_id} ;;
  }

  join: asset_status_key_values {
    type: inner
    relationship: many_to_one
    sql_on: ${asset_status_key_values.asset_id} = ${work_orders.asset_id} ;;
  }
}

explore: inspection_failures_last_30_days {
  group_label: "Work Orders"
  label: "Failed Inspections Last 30 Days"
  case_sensitive: no
  sql_always_where: ${markets_branch.company_id} in ('{{ _user_attributes['company_id'] }}'::numeric) ;;
  # sql_always_where: ${asset_id} in (select asset_id from table(assetlist({{ _user_attributes['user_id'] }}::numeric))) ;;

  join: assets {
    type: inner
    relationship: many_to_one
    sql_on: ${inspection_failures_last_30_days.asset_id} = ${assets.asset_id} ;;
  }

  join: categories {
    type: left_outer
    relationship: many_to_one
    sql_on: ${categories.category_id} = ${assets.category_id} ;;
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

  join: markets_branch {
    from: markets
    type: left_outer
    relationship: many_to_one
    sql_on: ${markets_branch.market_id} = ${inspection_failures_last_30_days.branch_id} ;;
  }

}

# explore: work_orders_time {
#   from: work_orders
#   group_label: "Work Orders"
#   label: "Time Spent on WO"
#   case_sensitive: no
#   # sql_always_where: ${asset_id} in (select asset_id from table(assetlist({{ _user_attributes['user_id'] }}::numeric))) ;;
#   sql_always_where: ${markets_branch.company_id} in ('{{ _user_attributes['company_id'] }}'::numeric) ;;

#   join: work_order_user_times {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${work_order_user_times.work_order_id} = ${work_orders_time.work_order_id} ;;
#   }

#   join: users {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${users.user_id} = ${work_order_user_times.user_id} ;;
#   }

#   join: assets {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${work_orders_time.asset_id} = ${assets.asset_id} ;;
#   }

#   join: categories {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${categories.category_id} = ${assets.category_id} ;;
#   }

#   join: asset_types {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${assets.asset_type_id} = ${asset_types.asset_type_id} ;;
#   }

#   join: organization_asset_xref {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${assets.asset_id} = ${organization_asset_xref.asset_id} ;;
#   }

#   join: markets_branch {
#     from: markets
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${markets_branch.market_id} = ${work_orders_time.branch_id} ;;
#   }
# }

explore: open_inspections_with_avg_completion_time {
  group_label: "Work Orders"
  label: "Open Inspections with Average Completion Time"
  case_sensitive: no

  join: work_orders {
    type: inner
    relationship: one_to_one
    sql_on: ${work_orders.work_order_id} = ${open_inspections_with_avg_completion_time.work_order_id} ;;
  }

  join: work_order_user_times {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_order_user_times.work_order_id} = ${work_orders.work_order_id} ;;
  }

  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: ${users.user_id} = ${work_order_user_times.user_id} ;;
  }

  join: assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_orders.asset_id} = ${assets.asset_id} ;;
  }

  join: categories {
    type: left_outer
    relationship: many_to_one
    sql_on: ${categories.category_id} = ${assets.category_id} ;;
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

  join: markets_branch {
    from: markets
    type: left_outer
    relationship: many_to_one
    sql_on: ${markets_branch.market_id} = ${work_orders.branch_id} ;;
  }

  join: inspection_time_by_work_order {
    type: inner
    relationship: many_to_one
    sql_on: ${inspection_time_by_work_order.make_and_model} = ${assets.make_and_model} ;;
  }

}

explore: wo_response_completion_time {
  group_label: "Work Orders"
  label: "WO Reponse and Completion Time"
  case_sensitive: no
  sql_always_where: ${markets_branch.company_id} in ('{{ _user_attributes['company_id'] }}'::numeric) ;;

  join: work_orders {
    type: inner
    relationship: one_to_one
    sql_on: ${work_orders.work_order_id} = ${wo_response_completion_time.work_order_id} ;;
  }

  join: work_order_user_times {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_order_user_times.work_order_id} = ${work_orders.work_order_id} ;;
  }

  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: ${users.user_id} = ${work_order_user_times.user_id} ;;
  }

  join: assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_orders.asset_id} = ${assets.asset_id} ;;
  }

  join: categories {
    type: left_outer
    relationship: many_to_one
    sql_on: ${categories.category_id} = ${assets.category_id} ;;
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

  join: markets_branch {
    from: markets
    type: left_outer
    relationship: many_to_one
    sql_on: ${markets_branch.market_id} = ${wo_response_completion_time.branch_id} ;;
  }

  join: wo_branch_avg_response_completion_time {
    type: left_outer
    relationship: many_to_one
    sql_on: ${wo_branch_avg_response_completion_time.branch_id} = ${wo_response_completion_time.branch_id} ;;
  }

  join: work_codes_xref {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_order_user_times.time_entry_id} = ${work_codes_xref.time_entry_id} ;;
  }

  join: work_codes {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_codes_xref.work_code_id} = ${work_codes.work_code_id} ;;
  }

  join: job_list {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_order_user_times.job_id} = ${job_list.job_id} ;;
  }

  join: wo_detailed_time_entrys {
    type: inner
    relationship: one_to_many
    sql_on: ${wo_response_completion_time.work_order_id} = ${wo_detailed_time_entrys.work_order_id} ;;
  }


}

explore: wo_detailed_time_entrys {
  view_name: wo_detailed_time_entrys
  group_label: "Work Orders"
  label: "WO Detailed Time Entrys"
  case_sensitive: no
  sql_always_where: ${markets_branch.company_id} in ('{{ _user_attributes['company_id'] }}'::numeric) ;;

  join: work_orders {
    type: inner
    relationship: one_to_one
    sql_on: ${work_orders.work_order_id} = ${wo_detailed_time_entrys.work_order_id} ;;
  }

  join: work_order_user_times {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_order_user_times.work_order_id} = ${work_orders.work_order_id} ;;
  }

  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: ${users.user_id} = ${work_order_user_times.user_id} ;;
  }

  join: assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_orders.asset_id} = ${assets.asset_id} ;;
  }

  join: categories {
    type: left_outer
    relationship: many_to_one
    sql_on: ${categories.category_id} = ${assets.category_id} ;;
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

  join: markets_branch {
    from: markets
    type: left_outer
    relationship: many_to_one
    sql_on: ${markets_branch.market_id} = ${wo_detailed_time_entrys.branch_id} ;;
  }

  join: work_codes_xref {
    type: left_outer
    relationship: many_to_one
    sql_on: ${wo_detailed_time_entrys.time_entry_id} = ${work_codes_xref.time_entry_id} ;;
  }

  join: work_codes {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_codes_xref.work_code_id} = ${work_codes.work_code_id} ;;
  }

  join: job_list {
    type: left_outer
    relationship: many_to_one
    sql_on: ${wo_detailed_time_entrys.job_id} = ${job_list.job_id} ;;
  }

  join: employee_names {
    type: left_outer
    relationship: many_to_one
    sql_on: ${wo_detailed_time_entrys.time_entry_user_id_name} = ${employee_names.user_id} ;;
  }

  join: wo_response_completion_time {
    type: left_outer
    relationship: many_to_one
    sql_on: ${wo_response_completion_time.work_order_id} = ${wo_detailed_time_entrys.work_order_id} ;;
  }

}
