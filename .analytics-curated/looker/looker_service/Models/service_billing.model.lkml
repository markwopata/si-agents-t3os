connection: "es_snowflake_analytics"

include: "/views/ES_WAREHOUSE/invoices.view.lkml"
include: "/views/ES_WAREHOUSE/line_items.view.lkml"
include: "/views/ES_WAREHOUSE/assets_aggregate.view.lkml"
include: "/views/ES_WAREHOUSE/users.view.lkml"
include: "/views/WORK_ORDERS/work_orders.view.lkml"
include: "/views/custom_sql/current_own_program_assets.view.lkml"
include: "/views/WORK_ORDERS/billing_types.view.lkml"
include: "/views/ES_WAREHOUSE/companies.view.lkml"
include: "/views/custom_sql/service_team_pushed_warranty.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/custom_sql/5300_5301_revenue_intaact.view.lkml"
include: "/views/custom_sql/wo_tags_aggregate.view.lkml"
include: "/views/custom_sql/wo_expense_vs_revenue.view.lkml"
include: "/views/ES_WAREHOUSE/assets.view.lkml"
include: "/views/custom_sql/work_order_invoice_link.view.lkml"
include: "/views/custom_sql/es_ownership_3_flags.view.lkml"
include: "/views/payout_program_assignments.view.lkml"
include: "/views/payout_programs.view.lkml"
include: "/views/SCD/scd_asset_company.view.lkml"
include: "/views/ANALYTICS/line_item_types.view.lkml"
include: "/views/ANALYTICS/parts_inventory_parts.view.lkml"
include: "/views/SCD/scd_asset_inventory_status.view.lkml"
include: "/views/ES_WAREHOUSE/line_item_type_erp_refs.view.lkml"
include: "/views/WORK_ORDERS/work_order_originators.view.lkml"
include: "/views/originator_types.view.lkml"
include: "/views/WORK_ORDERS/urgency_levels.view.lkml"

explore: service_billing_intaact_link {
  from: 5300_5301_revenue_intaact
  case_sensitive: no

  join: work_orders {
    type: left_outer
    relationship: one_to_one
    sql_on: ${service_billing_intaact_link.work_order_id} = ${work_orders.work_order_id} ;;
  }

  join: wo_tags_aggregate {
    type: left_outer
    relationship: one_to_one
    sql_on: ${wo_tags_aggregate.work_order_id} = ${work_orders.work_order_id} ;;
  }

  join: invoices {
    type: inner
    relationship: one_to_one
    sql_on: ${invoices.invoice_id} = ${service_billing_intaact_link.invoice_id} ;;
  }

  join: assets_aggregate {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets_aggregate.asset_id} = ${service_billing_intaact_link.asset_id} ;;
  }
}

explore: wo_expense_vs_revenue {

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: ${wo_expense_vs_revenue.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${wo_expense_vs_revenue.asset_id} = ${assets.asset_id} ;;
  }

  join: companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${wo_expense_vs_revenue.company_id} = ${companies.company_id} ;;
  }

  join: billing_types {
    type: inner
    relationship: many_to_one
    sql_on: ${wo_expense_vs_revenue.billing_type_id} = ${billing_types.billing_type_id};;
  }
}

explore: service_team_pushed_warranty { #Originates at work orders
  case_sensitive: no

  join: work_orders {
    type: inner
    relationship: one_to_one
    sql_on: ${service_team_pushed_warranty.work_order_id} = ${work_orders.work_order_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_orders.branch_id} = ${market_region_xwalk.market_id} ;;
  }

  join: billing_types {
    type: inner
    relationship: many_to_one
    sql_on: ${work_orders.billing_type_id} = ${billing_types.billing_type_id} ;;
  }

  join: assets_aggregate {
    type: left_outer
    relationship: many_to_many
    sql_on: ${assets_aggregate.asset_id} = ${work_orders.asset_id} ;;
  }

  join: current_own_program_assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_orders.asset_id} = ${current_own_program_assets.asset_id} ;;
  }

  join: billing_approval_user {
    from: users
    type: inner
    relationship: many_to_one
    sql_on: ${service_team_pushed_warranty.user_id} = ${billing_approval_user.user_id} ;;
  }

  join: invoices {
    type: left_outer
    relationship: one_to_one
    sql_on: ${service_team_pushed_warranty.invoice_id} = ${invoices.invoice_id} ;;
  }


}

explore: invoices {
  case_sensitive: no

  join: line_items {
    type: inner
    relationship: one_to_many
    sql_on: ${invoices.invoice_id} = ${line_items.invoice_id} ;;
  }

  join: line_item_types {
    type: left_outer
    relationship: many_to_one
    sql_on: ${line_items.line_item_type_id} = ${line_item_types.line_item_type_id} ;;
  }

  join: line_item_type_erp_refs {
    type: left_outer
    relationship: many_to_one
    sql_on: ${line_items.line_item_type_id} = ${line_item_type_erp_refs.line_item_type_id}  ;;
  }

  join: parts {
    from: parts_inventory_parts
    type: left_outer
    relationship: many_to_one
    sql_on: ${line_items.part_id} = ${parts.part_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${line_items.branch_id} = ${market_region_xwalk.market_id} ;;
  }

  join: assets_aggregate {
    type: left_outer
    relationship: many_to_many
    sql_on: ${assets_aggregate.asset_id} = ${line_items.asset_id} ;;
  }

  join: billing_approval_user {
    from: users
    type: left_outer
    relationship: many_to_one
    sql_on: ${invoices.billing_approved_by_user_id} = ${billing_approval_user.user_id} ;;
  }

  join: created_by_user {
    from: users
    type: left_outer
    relationship: many_to_one
    sql_on: ${invoices.created_by_user_id} = ${created_by_user.user_id} ;;
  }

  join: work_orders {
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets_aggregate.asset_id} = ${work_orders.asset_id}
      and ${work_orders.invoice_id} = ${invoices.invoice_id};;
  }

  join: billing_types {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_orders.billing_type_id} = ${billing_types.billing_type_id} ;;
  }

  join: current_own_program_assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets_aggregate.asset_id} = ${current_own_program_assets.asset_id} ;;
  }

  join: companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${invoices.company_id} = ${companies.company_id} ;;
  }

  join: invoice_to_work_orders {
    type: left_outer
    relationship: one_to_one
    sql_on: ${invoice_to_work_orders.invoice_id} = ${invoices.invoice_id};;
  }

  join: work_orders_by_loop {
    from: work_orders
    type: left_outer
    relationship: one_to_one
    sql_on: ${work_orders_by_loop.work_order_id}::STRING = ${invoice_to_work_orders.work_order_id}   ;;
  }

  join: work_order_originators {
    type: left_outer
    relationship: one_to_one
    sql_on: ${work_orders_by_loop.work_order_id} = ${work_order_originators.work_order_id} ;;
  }

  join: urgency_levels_by_wo_loop {
    from: urgency_levels
    type: left_outer
    relationship: one_to_many
    sql_on: ${work_orders.urgency_level_id} = ${work_orders.urgency_level_id} ;;
  }

  join: originator_types {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_order_originators.originator_type_id} = ${originator_types.originator_type_id} ;;
  }
  join: wo_tags_aggregate {
    type: left_outer
    relationship: one_to_one
    sql_on: ${work_orders_by_loop.work_order_id} = ${wo_tags_aggregate.work_order_id} ;;
  }

  join: payout_program_assignments {
    type: left_outer
    relationship: many_to_one
    sql_on: ${payout_program_assignments.asset_id} = ${line_items.asset_id}
      and ${payout_program_assignments.start_date} < ${invoices.billing_approved_date}
      and coalesce(${payout_program_assignments.end_date}, '2099-12-31') >= ${invoices.billing_approved_date} ;;
  }

  join: payout_programs {
    type: left_outer
    relationship: many_to_one
    sql_on: ${payout_programs.payout_program_id} = ${payout_program_assignments.payout_program_id} ;;
  }

  join: scd_asset_company {
    type: left_outer
    relationship: one_to_one
    sql_on: ${line_items.asset_id} = ${scd_asset_company.asset_id}
      and ${invoices.billing_approved_date} BETWEEN ${scd_asset_company.date_start_date} AND ${scd_asset_company.date_end_date} ;;
  }

  join: current_asset_status {
    from: scd_asset_inventory_status
    type: left_outer
    relationship: one_to_one
    sql_on: ${line_items.asset_id} = ${current_asset_status.asset_id}
      and ${current_asset_status.current_flag} = 1;;
  }

  join: owner_at_billing {
    from: companies
    type: left_outer
    relationship: one_to_one
    sql_on: ${scd_asset_company.company_id} = ${owner_at_billing.company_id} ;;
  }

  join: scd_asset_company_at_wo_creation {
    from:  scd_asset_company
    type: left_outer
    relationship: one_to_one
    sql_on: ${line_items.asset_id} = ${scd_asset_company_at_wo_creation.asset_id}
      and ${work_orders_by_loop.date_created_date} BETWEEN ${scd_asset_company_at_wo_creation.date_start_date} AND ${scd_asset_company_at_wo_creation.date_end_date} ;;
  }

  join: owner_at_wo_creation {
    from: companies
    type: left_outer
    relationship: one_to_one
    sql_on: ${scd_asset_company_at_wo_creation.company_id} = ${owner_at_wo_creation.company_id} ;;
  }
}
