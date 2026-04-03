connection: "es_snowflake_analytics"

include: "/views/custom_sql/outside_hauling_deliveries.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/ASSET_TRANSFER/PUBLIC/transfer_orders.view.lkml"
include: "/views/FLEET_OPTIMIZATION/dim_assets_fleet_opt.view.lkml"
include: "/views/FLEET_OPTIMIZATION/dim_users_fleet_opt.view.lkml"
include: "/views/FLEET_OPTIMIZATION/dim_markets_fleet_opt.view.lkml"
include: "/views/FLEET_OPTIMIZATION/dim_companies_fleet_opt.view.lkml"
include: "/views/FLEET_OPTIMIZATION/dim_work_orders_fleet_opt.view.lkml"
include: "/views/SCD/scd_asset_inventory_status.view.lkml"
include: "/views/ANALYTICS/BRANCH_EARNINGS/int_high_level_financials_trending.view.lkml"
include: "/views/DATA_SCIENCE/all_equipment_rouse_estimates.view.lkml"
include: "/views/ANALYTICS/PAYROLL/stg_analytics_payroll__company_directory_vault.view.lkml"

explore: outside_hauling_deliveries {
  label: "Outside Hauling Deliveries with PO Expenses"
  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: ${outside_hauling_deliveries.market_id}=${market_region_xwalk.market_id} ;;
  }
  join: dim_assets_fleet_opt {
    type: inner
    relationship: many_to_one
    sql_on: ${outside_hauling_deliveries.asset_id}=${dim_assets_fleet_opt.asset_id} ;;
  }
}

explore: transfer_orders {
  label: "Transfers with Asset and Market Attributes"
  join: requesting_user {
    from: dim_users_fleet_opt
    type: inner
    relationship: many_to_one
    sql_on: ${transfer_orders.requester_id}=${requesting_user.user_id} and ${requesting_user.user_company_id}=1854 ;;
  }
  join: requesting_user_company_directory {
    from: stg_analytics_payroll__company_directory_vault
    type: left_outer
    relationship: many_to_one
    sql: asof join ${stg_analytics_payroll__company_directory_vault.SQL_TABLE_NAME}  as requesting_user_company_directory
          match_condition (${transfer_orders.date_created_raw}>=${requesting_user_company_directory._es_update_timestamp_raw})
          on ${requesting_user.user_employee_id}=${requesting_user_company_directory.employee_id}
          ;;
  }
  join: approving_user {
    from: dim_users_fleet_opt
    type: inner
    relationship: many_to_one
    sql_on: ${transfer_orders.approver_id}=${approving_user.user_id} and ${approving_user.user_company_id}=1854 ;;
  }
  join: approving_user_company_directory {
    from: stg_analytics_payroll__company_directory_vault
    type: left_outer
    relationship: many_to_one
    sql: asof join ${stg_analytics_payroll__company_directory_vault.SQL_TABLE_NAME}  as approving_user_company_directory
    match_condition (${transfer_orders.date_approved_raw}>=${approving_user_company_directory._es_update_timestamp_raw})
    on ${approving_user.user_employee_id}=${approving_user_company_directory.employee_id}
    ;;
  }
  join: receiving_user {
    from: dim_users_fleet_opt
    type: inner
    relationship: many_to_one
    sql_on: ${transfer_orders.received_by_id}=${receiving_user.user_id} and ${receiving_user.user_company_id}=1854 ;;
  }
  join: receiving_user_company_directory {
    from: stg_analytics_payroll__company_directory_vault
    type: left_outer
    relationship: many_to_one
    sql: asof join ${stg_analytics_payroll__company_directory_vault.SQL_TABLE_NAME}  as receiving_user_company_directory
          match_condition (${transfer_orders.date_received_raw}>=${receiving_user_company_directory._es_update_timestamp_raw})
          on ${receiving_user.user_employee_id}=${receiving_user_company_directory.employee_id}
          ;;
  }
  join: dim_assets_fleet_opt {
    type: inner
    relationship: many_to_one
    sql_on: ${transfer_orders.asset_id}=${dim_assets_fleet_opt.asset_id} ;;
  }
  join: asset_scoring {
    type: left_outer
    relationship: one_to_one
    sql_on: ${dim_assets_fleet_opt.asset_id}=${asset_scoring.asset_id} ;;
  }
  join: all_equipment_rouse_estimates {
    type: left_outer
    relationship: one_to_one
    sql_on: ${dim_assets_fleet_opt.asset_id}=${all_equipment_rouse_estimates.asset_id} ;;
  }
  join: current_asset_company {
    from: dim_companies_fleet_opt
    type: inner
    relationship: many_to_one
    sql_on: ${dim_assets_fleet_opt.asset_company_id}=${current_asset_company.company_id} ;;
  }
  join: current_rental_market {
    from: dim_markets_fleet_opt
    type: inner #should maybe be left join if a rsp isnt assigned, but wont fail using dbt models
    relationship: many_to_one
    sql_on: ${dim_assets_fleet_opt.asset_rental_market_key}=${current_rental_market.market_key} ;;
  }
  join: asset_status_at_reception {
    from: scd_asset_inventory_status
    type: inner
    relationship: one_to_one
    sql_on: ${transfer_orders.asset_id}=${asset_status_at_reception.asset_id}
          and ${transfer_orders.date_received_date}>=${asset_status_at_reception.date_start_date}
          and ${transfer_orders.date_received_date}<${asset_status_at_reception.date_end_date};;
  }
  join: sending_market {
    from: dim_markets_fleet_opt
    type: inner
    relationship: many_to_one
    sql_on: ${transfer_orders.from_branch_id}=${sending_market.market_id} ;;
  }
  join: sending_market_month_earnings {
    from: int_high_level_financials_trending
    type: left_outer
    relationship: one_to_one
    sql_on: (${sending_market.market_id}=${sending_market_month_earnings.market_id}
          and date_trunc(month,${transfer_orders.date_received_date}::date)=${sending_market_month_earnings.gl_date})
           and ({{ _user_attributes['department'] }} in ('developer','admin')
        or (${sending_market_month_earnings.Market_Access}));;
  }
  join: receiving_market {
    from: dim_markets_fleet_opt
    type: inner
    relationship: many_to_one
    sql_on: ${transfer_orders.to_branch_id}=${receiving_market.market_id} ;;
  }
  join: receiving_market_month_earnings {
    from: int_high_level_financials_trending
    type: left_outer
    relationship: many_to_one
    sql_on: (${receiving_market.market_id}=${receiving_market_month_earnings.market_id}
    and date_trunc(month,${transfer_orders.date_received_date}::date)=${receiving_market_month_earnings.gl_date})
     and ({{ _user_attributes['department'] }} in ('developer','admin')
  or (${receiving_market_month_earnings.Market_Access}));;
  }
  join: dim_work_orders_fleet_opt {
    type: left_outer
    relationship: many_to_many #should be one to many but technically multiple transports could happen with a work orders life
    sql_on: ((${transfer_orders.date_received_date} >= ${dim_work_orders_fleet_opt.work_order_created_date}
      and ${transfer_orders.date_received_date}< iff(${dim_work_orders_fleet_opt.work_order_status_name}='Open', current_date, coalesce(nullif(${dim_work_orders_fleet_opt.work_order_completed_date},'0001-01-01'),current_date)))
      or (${dim_work_orders_fleet_opt.work_order_created_date}>${transfer_orders.date_received_date}
      and ${dim_work_orders_fleet_opt.work_order_created_date}<=dateadd(day,7, ${transfer_orders.date_received_date})))
      and ${transfer_orders.asset_id}=${dim_work_orders_fleet_opt.work_order_asset_id}
      and ${dim_work_orders_fleet_opt.work_order_date_archived_date}!='0001-01-01'
      and ${dim_work_orders_fleet_opt.work_order_originator_type_id}!=3
      and ${dim_work_orders_fleet_opt.work_order_type_id}=1;;
  }

}
