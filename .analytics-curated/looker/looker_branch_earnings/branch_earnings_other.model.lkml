connection: "es_snowflake_c_analytics"

include: "views/custom_sql/u12mo_spend.view.lkml"
include: "/**/**.view.lkml"                # include all views in the views/ folder in this project
include: "suggestions.lkml"

explore: u12mo_spend {
  label: "Less than 12 month spend - Branch Earnings"
}

explore: materials_kpis {
  label: "materials KPI table "
  sql_always_where: (
  ${market_region_xwalk.District_Region_Market_Access}
  and ${plexi_periods.period_published} = 'published'
  );;
  always_filter: {
    filters: [market_region_xwalk.market_type: "Materials"]
  }

  join: plexi_periods {
    type: inner
    relationship: many_to_one
    sql_on: date_trunc(month, ${materials_kpis.be_month}::date) = ${plexi_periods.date} ;;
}
  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on:
    ${materials_kpis.mkt_id}::text = ${market_region_xwalk.market_id}::text;;
  }


}

explore: materials_branch_earnings {
  label: "materials branch earnings"
  sql_always_where: (
  ${market_region_xwalk.District_Region_Market_Access_Materials}
  and ${plexi_periods.period_published} = 'published'
  );;


  join: plexi_periods {
    type: inner
    relationship: many_to_one
    sql_on: date_trunc(month, ${materials_branch_earnings.gl_date_date}::date) = ${plexi_periods.date} ;;
  }

  join: materials_kpis {
    type:  left_outer
    relationship: many_to_one
    sql_on: ${materials_branch_earnings.mkt_id} = ${materials_kpis.mkt_id} and ${materials_branch_earnings.gl_date_month} = ${materials_kpis.be_month} ;;
  }

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: ${materials_branch_earnings.mkt_id}::text = ${market_region_xwalk.market_id}::text ;;
  }

}

explore: materials_2mom {
  label: "Materials MoM"
  sql_always_where:
  (${materials_2mom.gl_date2} >= dateadd(month, -1, ${selected_period.date})
  AND ${materials_2mom.gl_date2} <= ${selected_period.date})
  and (
  ${market_region_xwalk.District_Region_Market_Access_Materials}
  and ${plexi_periods.period_published} = 'published'
  );;



  join: row_period {
    from: plexi_periods
    type: left_outer
    relationship: many_to_one
    sql_on: date_trunc('month', ${materials_2mom.gl_date2}) = ${row_period.date} ;;
  }

  # (dashboard filter should map to THIS)
  join: selected_period {
    from: plexi_periods
    type: left_outer
    relationship: many_to_one
    sql_on: 1=1 ;;
  }

  join: plexi_periods {
    type: inner
    relationship: many_to_one
    sql_on: ${selected_period.date} = ${plexi_periods.date} ;;
  }

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: ${materials_2mom.mkt_id}::text = ${market_region_xwalk.market_id}::text ;;
  }

  join: payroll_census {
    type: inner
    relationship: many_to_one
    sql_on: ${materials_2mom.mkt_id} = ${payroll_census.market_id}
and ${materials_2mom.gl_date2} = ${payroll_census.period_date}::date;;
  }

}



explore: materials_dashboard {
  label: "Materials Dashboard"


  join: materials_inventory_turnover {
    type: inner
    relationship: many_to_one
    sql_on:
    ${materials_dashboard.bt_branch_id} = ${materials_inventory_turnover.bt_branch_id}
    AND date_trunc('month',${materials_dashboard.datetime_created_date}::DATE)= date_trunc('month',${materials_inventory_turnover.month_start_raw}::DATE)
      and ${materials_detail.branch_id} = ${materials_inventory_turnover.bt_branch_id}
      and date_trunc('month',${materials_detail.entry_date_date}::DATE)= date_trunc('month',${materials_inventory_turnover.month_start_raw}::DATE);;
  }

  join: materials_detail {
    type: inner
    relationship: many_to_one
    sql_on: ${materials_dashboard.market_id} = ${materials_detail.market_id}
    and date_trunc('month',${materials_dashboard.datetime_created_date}::DATE)=
      date_trunc('month',${materials_detail.entry_date_raw}::DATE) ;;
  }

  join: materials_revenue_sqft {
    type: inner
    relationship: many_to_one
    sql_on:  ${materials_dashboard.bt_branch_id} = ${materials_revenue_sqft.bt_branch_id}
      and date_trunc('month',${materials_dashboard.datetime_created_date}::DATE)= ${materials_revenue_sqft.revenue_month}::DATE
      and ${materials_detail.market_name} = ${materials_revenue_sqft.market_name}
      and date_trunc('month',${materials_detail.entry_date_date}::DATE)= ${materials_revenue_sqft.revenue_month}::DATE

      ;;
  }

  join: materials_payroll {
    type: inner
    relationship: many_to_one
    sql_on:  ${materials_dashboard.market_id} = ${materials_payroll.market_id} and date_trunc('month',${materials_dashboard.datetime_created_date}::DATE)= (${materials_payroll.entry_month}::DATE)
      and ${materials_detail.market_id} = ${materials_payroll.market_id}
      and date_trunc('month',${materials_detail.entry_date_date}::DATE)= ${materials_payroll.entry_month}::DATE;;
  }

  join: v_dim_dates_bi {
    type:  left_outer
    relationship: many_to_one
    sql_on: ${materials_dashboard.datetime_created_date} = ${v_dim_dates_bi.date} ;;
  }
}


explore: fleet_status_new {
  from:  fleet_status_new
  label: "fleet status"
  description: "asset purchase order history and current status"
}

############################################################
### Regional Branch Earnings P&L Analysis Monthly ###
############################################################

explore: be_snap_comparison_to_py {
  label: "Branch Earnings P&L Current vs PY"

  sql_always_where: (
      ${market_region_xwalk.District_Region_Market_Access}
    )
    -- Let devs, admins, and jabbok see unpublished BE periods.
    or 'developer' = {{ _user_attributes['department'] }}
    or 'admin' = {{ _user_attributes['department'] }}
    or trim(lower('{{ _user_attributes['email'] | replace: "'", "\\'"}}')) = 'jabbok@equipmentshare.com'
    ;;

  join: parent_market {
    type: left_outer
    relationship: many_to_one
    sql_on: ${be_snap_comparison_to_py.mkt_id}::text = ${parent_market.market_id}
      and date_trunc("month", ${be_snap_comparison_to_py.gl_date}::date) >= date_trunc(month, ${parent_market.start_date}::date)
      and date_trunc("month", ${be_snap_comparison_to_py.gl_date}::date) <= coalesce(date_trunc(month, ${parent_market.end_date}::date), '2099-12-31')
      ;;
  }

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: coalesce(${parent_market.parent_market_id}, ${be_snap_comparison_to_py.mkt_id}::text) = ${market_region_xwalk.market_id}::text ;;
  }

  join: revmodel_market_rollout_conservative {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${revmodel_market_rollout_conservative.market_id} ;;
  }

  join: plexi_periods {
    type: left_outer
    relationship: many_to_one
    sql_on: date_trunc("month",${be_snap_comparison_to_py.gl_date}::date) = ${plexi_periods.date}::date;;
  }
}

explore: int_asset_historical_ownership {
  label: "Historical Asset Inventory Status"

  sql_always_where: (
      ${market_region_xwalk.District_Region_Market_Access}
    )
    -- Let devs, admins, and jabbok see unpublished BE periods.
    or 'developer' = {{ _user_attributes['department'] }}
    or 'admin' = {{ _user_attributes['department'] }}
    or trim(lower('{{ _user_attributes['email'] | replace: "'", "\\'"}}')) = 'jabbok@equipmentshare.com'
    ;;

  join: parent_market {
    type: left_outer
    relationship: many_to_one
    sql_on: ${int_asset_historical_ownership.market_id}::text = ${parent_market.market_id}
      and date_trunc("month", ${int_asset_historical_ownership.daily_timestamp_date}::date) >= date_trunc(month, ${parent_market.start_date}::date)
      and date_trunc("month", ${int_asset_historical_ownership.daily_timestamp_date}::date) <= coalesce(date_trunc(month, ${parent_market.end_date}::date), '2099-12-31')
      ;;
  }

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: coalesce(${parent_market.parent_market_id}, ${int_asset_historical_ownership.market_id}::text) = ${market_region_xwalk.market_id}::text ;;
  }

  join: revmodel_market_rollout_conservative {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${revmodel_market_rollout_conservative.market_id} ;;
  }

  join: plexi_periods {
    type: left_outer
    relationship: many_to_one
    sql_on: ${int_asset_historical_ownership.month_end_date} = ${plexi_periods.date}::date;;
  }
}

# new model, will need updating once we switch to the dynamic oec count
explore: int_asset_historical {
  label: "Asset Inventory Status with Rental Fleet"

  sql_always_where: (
      ${market_region_xwalk.District_Region_Market_Access}
    )
    -- Let devs, admins, and jabbok see unpublished BE periods.
    or 'developer' = {{ _user_attributes['department'] }}
    or 'admin' = {{ _user_attributes['department'] }}
    or trim(lower('{{ _user_attributes['email'] | replace: "'", "\\'"}}')) = 'jabbok@equipmentshare.com'
    ;;

  join: parent_market {
    type: left_outer
    relationship: many_to_one
    sql_on: ${int_asset_historical.market_id}::text = ${parent_market.market_id}
      and date_trunc("month", ${int_asset_historical.daily_timestamp_date}::date) >= date_trunc(month, ${parent_market.start_date}::date)
      and date_trunc("month", ${int_asset_historical.daily_timestamp_date}::date) <= coalesce(date_trunc(month, ${parent_market.end_date}::date), '2099-12-31')
      ;;
  }

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: coalesce(${parent_market.parent_market_id}, ${int_asset_historical.market_id}::text) = ${market_region_xwalk.market_id}::text ;;
  }

  join: revmodel_market_rollout_conservative {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${revmodel_market_rollout_conservative.market_id} ;;
  }

  join: plexi_periods {
    type: left_outer
    relationship: many_to_one
    sql_on: ${int_asset_historical.month_end_date} = ${plexi_periods.date}::date;;
  }
}

explore: be_snap_trailing_12_months {
  label: "Trailing 12 Months P&L Detail"
  sql_always_where: (
      ${market_region_xwalk.District_Region_Market_Access}
    )
    -- Let devs, admins, and jabbok see unpublished BE periods.
    or 'developer' = {{ _user_attributes['department'] }}
    or 'admin' = {{ _user_attributes['department'] }}
    or trim(lower('{{ _user_attributes['email'] | replace: "'", "\\'"}}')) = 'jabbok@equipmentshare.com'
    ;;

  join: parent_market {
    type: left_outer
    relationship: many_to_one
    sql_on: ${be_snap_trailing_12_months.mkt_id}::text = ${parent_market.market_id}
      and date_trunc("month", ${be_snap_trailing_12_months.gl_date_date}::date) >= date_trunc(month, ${parent_market.start_date}::date)
      and date_trunc("month", ${be_snap_trailing_12_months.gl_date_date}::date) <= coalesce(date_trunc(month, ${parent_market.end_date}::date), '2099-12-31')
      ;;
  }

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: coalesce(${parent_market.parent_market_id}, ${be_snap_trailing_12_months.mkt_id}::text) = ${market_region_xwalk.market_id}::text ;;
  }

  join: revmodel_market_rollout_conservative {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${revmodel_market_rollout_conservative.market_id} ;;
  }

  join: plexi_periods {
    type: left_outer
    relationship: many_to_one
    sql_on: date_trunc("month",${be_snap_trailing_12_months.gl_date_date}::date) = ${plexi_periods.date}::date;;
  }
}

explore: max_month_oec_by_asset_inventory_status {
  label: "Max Period Asset Inventory Status by OEC and Count"

  sql_always_where: (
      ${market_region_xwalk.District_Region_Market_Access}
    )
    -- Let devs, admins, and jabbok see unpublished BE periods.
    or 'developer' = {{ _user_attributes['department'] }}
    or 'admin' = {{ _user_attributes['department'] }}
    or trim(lower('{{ _user_attributes['email'] | replace: "'", "\\'"}}')) = 'jabbok@equipmentshare.com'
    ;;

  join: parent_market {
    type: left_outer
    relationship: many_to_one
    sql_on: ${max_month_oec_by_asset_inventory_status.market_id}::text = ${parent_market.market_id}
      and date_trunc("month", ${max_month_oec_by_asset_inventory_status.daily_timestamp_date}::date) >= date_trunc(month, ${parent_market.start_date}::date)
      and date_trunc("month", ${max_month_oec_by_asset_inventory_status.daily_timestamp_date}::date) <= coalesce(date_trunc(month, ${parent_market.end_date}::date), '2099-12-31')
      ;;
  }

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: coalesce(${parent_market.parent_market_id}, ${max_month_oec_by_asset_inventory_status.market_id}::text) = ${market_region_xwalk.market_id}::text ;;
  }

  join: revmodel_market_rollout_conservative {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${revmodel_market_rollout_conservative.market_id} ;;
  }

  join: plexi_periods {
    type: left_outer
    relationship: many_to_one
    sql_on: ${max_month_oec_by_asset_inventory_status.month_end_date} = ${plexi_periods.date}::date;;
  }
}

explore: in_out_market_revenue_ttm {
  label: "In Market and Out of Market Revenue TTM"
  sql_always_where: (
      ${market_region_xwalk.District_Region_Market_Access}
    )
    -- Let devs, admins, and jabbok see unpublished BE periods.
    or 'developer' = {{ _user_attributes['department'] }}
    or 'admin' = {{ _user_attributes['department'] }}
    or trim(lower('{{ _user_attributes['email'] | replace: "'", "\\'"}}')) = 'jabbok@equipmentshare.com'
    ;;

  join: parent_market {
    type: left_outer
    relationship: many_to_one
    sql_on: ${in_out_market_revenue_ttm.market_id}::text = ${parent_market.market_id}
      and date_trunc("month",${in_out_market_revenue_ttm.billing_approved_date_date}::date) >= date_trunc(month, ${parent_market.start_date}::date)
      and date_trunc("month",${in_out_market_revenue_ttm.billing_approved_date_date}::date) <= coalesce(date_trunc(month, ${parent_market.end_date}::date), '2099-12-31')
      ;;
  }

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: coalesce(${parent_market.parent_market_id}, ${in_out_market_revenue_ttm.market_id}::text) = ${market_region_xwalk.market_id}::text ;;
  }

  join: revmodel_market_rollout_conservative {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${revmodel_market_rollout_conservative.market_id} ;;
  }

  join: plexi_periods {
    type: left_outer
    relationship: many_to_one
    sql_on: date_trunc("month",${in_out_market_revenue_ttm.billing_approved_date_date}::date) = ${plexi_periods.date}::date;;
  }
}

explore: int_asset_asset_transfer_by_branch {
  label: "Asset Transfer by Inventory Status"

  sql_always_where: (
      ${market_region_xwalk.District_Region_Market_Access}
    )
    -- Let devs, admins, and jabbok see unpublished BE periods.
    or 'developer' = {{ _user_attributes['department'] }}
    or 'admin' = {{ _user_attributes['department'] }}
    or trim(lower('{{ _user_attributes['email'] | replace: "'", "\\'"}}')) = 'jabbok@equipmentshare.com'
    ;;

  join: parent_market {
    type: left_outer
    relationship: many_to_one
    sql_on: ${int_asset_asset_transfer_by_branch.market_id}::text = ${parent_market.market_id}
      and date_trunc("month", ${int_asset_asset_transfer_by_branch.transfer_date_date}::date) >= date_trunc(month, ${parent_market.start_date}::date)
      and date_trunc("month",  ${int_asset_asset_transfer_by_branch.transfer_date_date}::date) <= coalesce(date_trunc(month, ${parent_market.end_date}::date), '2099-12-31')
      ;;
  }

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: coalesce(${parent_market.parent_market_id}, ${int_asset_asset_transfer_by_branch.market_id}::text) = ${market_region_xwalk.market_id}::text ;;
  }

  join: revmodel_market_rollout_conservative {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${revmodel_market_rollout_conservative.market_id} ;;
  }

  join: plexi_periods {
    type: left_outer
    relationship: many_to_one
    sql_on: ${int_asset_asset_transfer_by_branch.transfer_date_month} = ${plexi_periods.date}::date;;
  }
}

explore: high_level_financials_ttm {
  label: "High Level Financials Trailing 12 Months"

  sql_always_where: (
      ${market_region_xwalk.District_Region_Market_Access}
      -- and ${plexi_periods.period_published} = 'published'
    )
    -- Let devs, admins, and jabbok see unpublished BE periods.
    or 'developer' = {{ _user_attributes['department'] }}
    or 'admin' = {{ _user_attributes['department'] }}
    or trim(lower('{{ _user_attributes['email'] | replace: "'", "\\'"}}')) = 'jabbok@equipmentshare.com'
    ;;

  join: parent_market {
    type: left_outer
    relationship: many_to_one
    sql_on: ${high_level_financials_ttm.market_id}::text = ${parent_market.market_id}
      and date_trunc(month, ${high_level_financials_ttm.gl_date_date}::date) >= date_trunc(month, ${parent_market.start_date}::date)
      and date_trunc(month, ${high_level_financials_ttm.gl_date_date}::date) <= coalesce(date_trunc(month, ${parent_market.end_date}::date), '2099-12-31')
      ;;
  }

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: coalesce(${parent_market.parent_market_id}, ${high_level_financials_ttm.market_id}::text) = ${market_region_xwalk.market_id}::text ;;
  }

  join: revmodel_market_rollout_conservative {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${revmodel_market_rollout_conservative.market_id} ;;
  }

  join: plexi_periods {
    type: inner
    relationship: many_to_one
    sql_on: ${high_level_financials_ttm.gl_date_date}::date = ${plexi_periods.date}::date;;
  }
}

############################################################
### Monthly Revenue Bucketing Dashboard ###
# ############################################################

explore: branch_earnings_market_comparison {
  label: "Revenue Bucketing by Market"
  sql_always_where: (
      ${market_region_xwalk.District_Region_Market_Access}
      )
      -- Let devs, admins, and jabbok see unpublished BE periods.
      or 'developer' = {{ _user_attributes['department'] }}
      or 'admin' = {{ _user_attributes['department'] }}
      or trim(lower('{{ _user_attributes['email'] | replace: "'", "\\'"}}')) = 'jabbok@equipmentshare.com'
      ;;

  join: plexi_periods {
    type: left_outer
    relationship: many_to_one
    sql_on: ${branch_earnings_market_comparison.gl_month} = ${plexi_periods.date} ;;
  }


  join: revenue_bucketing_by_market {
    type: left_outer
    relationship: many_to_one
    sql_on: ${revenue_bucketing_by_market.gl_month} = ${branch_earnings_market_comparison.gl_month}
            and ${revenue_bucketing_by_market.is_market_over_12} = ${branch_earnings_market_comparison.is_market_over_12}
            and ${revenue_bucketing_by_market.revenue_bucket} = ${branch_earnings_market_comparison.revenue_bucket}
            and ${revenue_bucketing_by_market.market_type} = ${branch_earnings_market_comparison.market_type}
          ;;
  }

  join: parent_market {
    type: left_outer
    relationship: many_to_one
    sql_on: ${revenue_bucketing_by_market.market_id} = ${parent_market.market_id}
      and ${revenue_bucketing_by_market.gl_month} >= date_trunc(month, ${parent_market.start_date}::date)
      and ${revenue_bucketing_by_market.gl_month} <= coalesce(date_trunc(month, ${parent_market.end_date}::date), '2099-12-31')
      ;;
  }

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: coalesce(${parent_market.parent_market_id}, ${revenue_bucketing_by_market.market_id}::text) = ${market_region_xwalk.market_id}::text ;;
  }


  join: revmodel_market_rollout_conservative {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${revmodel_market_rollout_conservative.market_id} ;;
  }


  join: be_transaction_listing_pm {
    type: left_outer
    relationship: many_to_many
    sql_on: coalesce(${parent_market.market_id},${market_region_xwalk.market_id}) = ${be_transaction_listing_pm.parent_mkt_id}
            and date_trunc(month,${be_transaction_listing_pm.gl_date}::date) = ${plexi_periods.date}::date
            and ${branch_earnings_market_comparison.account_name}::varchar = ${be_transaction_listing_pm.gl_acct}::varchar
            and ${branch_earnings_market_comparison.account_number}::varchar = ${be_transaction_listing_pm.gl_acctno}::varchar
          ;;
  }
}
##############################

explore: countless_order_and_invoice_detail {
  label: "Countless Supply KPI Dashboard"
  sql_always_where: (${market_region_xwalk.District_Region_Market_Access}
  and ${market_region_xwalk.division_name} = 'Site Solutions')
  -- Let devs, admins, and jabbok see unpublished BE periods.
  or 'developer' = {{ _user_attributes['department'] }}
  or 'admin' = {{ _user_attributes['department'] }}
  or trim(lower('{{ _user_attributes['email'] | replace: "'", "\\'"}}')) = 'jabbok@equipmentshare.com'
  ;;

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: ${countless_order_and_invoice_detail.market_id} = ${market_region_xwalk.market_id} ;;
  }
}

explore: countless_kpi_quotes {
  label: "Countless Supply Quotes"
  sql_always_where: (${market_region_xwalk.District_Region_Market_Access}
  and ${market_region_xwalk.division_name} = 'Site Solutions')
  -- Let devs, admins, and jabbok see unpublished BE periods.
  or 'developer' = {{ _user_attributes['department'] }}
  or 'admin' = {{ _user_attributes['department'] }}
  or trim(lower('{{ _user_attributes['email'] | replace: "'", "\\'"}}')) = 'jabbok@equipmentshare.com'
  ;;

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: ${countless_kpi_quotes.branch_id} = ${market_region_xwalk.market_id} ;;
  }
}

explore: po_detail {
  label: "Countless Supply PO Detail"
  sql_always_where: (${market_region_xwalk.District_Region_Market_Access}
      and ${market_region_xwalk.division_name} = 'Site Solutions')
      -- Let devs, admins, and jabbok see unpublished BE periods.
      or 'developer' = {{ _user_attributes['department'] }}
      or 'admin' = {{ _user_attributes['department'] }}
      or trim(lower('{{ _user_attributes['email'] | replace: "'", "\\'"}}')) = 'jabbok@equipmentshare.com'
      ;;

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: ${po_detail.department_id}::varchar = ${market_region_xwalk.market_id}::varchar ;;
  }
}

explore: high_level_financials {
  label: "Tooling KPI's"
  sql_always_where: (${market_region_xwalk.District_Region_Market_Access}
  and ${market_region_xwalk.division_name} = 'Site Solutions')
  -- Let devs, admins, and jabbok see unpublished BE periods.
  or 'developer' = {{ _user_attributes['department'] }}
  or 'admin' = {{ _user_attributes['department'] }}
  or trim(lower('{{ _user_attributes['email'] | replace: "'", "\\'"}}')) = 'jabbok@equipmentshare.com'
  ;;

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: ${high_level_financials.market_id}::varchar = ${market_region_xwalk.market_id}::varchar ;;
  }

  join: plexi_periods {
    type: inner
    relationship: many_to_one
    sql_on: date_trunc(month, ${high_level_financials.gl_date}::date) = ${plexi_periods.date} ;;
  }

  join: revmodel_market_rollout_conservative {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${revmodel_market_rollout_conservative.market_id} ;;
  }

  join: int_claims__historic_market_vehicle_claim_count_rolling_12mo {
    type: left_outer
    relationship: one_to_one
    sql_on: ${market_region_xwalk.market_id} = ${int_claims__historic_market_vehicle_claim_count_rolling_12mo.market_id}
            and ${plexi_periods.date} = date_trunc(month,${int_claims__historic_market_vehicle_claim_count_rolling_12mo.date_month_date}::date);;
  }

  join: int_claims__historic_market_employee_claim_count_rolling_12mo {
    type: left_outer
    relationship: one_to_one
    sql_on: ${market_region_xwalk.market_id} = ${int_claims__historic_market_employee_claim_count_rolling_12mo.market_id}
                and ${plexi_periods.date} = date_trunc(month,${int_claims__historic_market_employee_claim_count_rolling_12mo.date_month_date}::date);;
  }

  join: tooling_region_market_mapping {
    type:  left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${tooling_region_market_mapping.market_id} ;;
  }

  join: cod_outstanding_action_items {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${cod_outstanding_action_items.market_id}
              and ${plexi_periods.date} = date_trunc(month,${cod_outstanding_action_items.invoice_date}::date);;
  }

  join: v_dim_dates_bi {
    type: left_outer
    relationship: many_to_one
    sql_on: ${plexi_periods.date} = ${v_dim_dates_bi.month} ;;
  }

  join: market_level_asset_metrics_daily {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${market_level_asset_metrics_daily.market_id}
              and ${market_level_asset_metrics_daily.month_end_date} = ${plexi_periods.date} ;;
  }

  join: market_rental_revenue_hist_with_goals {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${market_rental_revenue_hist_with_goals.market_id}
    and ${market_rental_revenue_hist_with_goals.month_date} = ${plexi_periods.date} ;;
  }

  join: region_hierarchy_discount {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${region_hierarchy_discount.market_id} ;;
  }
}

  explore: vsg_credit_card_expenses {
    label: "VSG Credit Card Expenses"
  }
