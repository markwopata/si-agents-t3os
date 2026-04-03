connection: "es_snowflake_c_analytics"

include: "/**/**.view.lkml"                # include all views in the views/ folder in this project
include: "suggestions.lkml"
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard

explore: help_be_slack_responses {
  label: "Help Branch Earnings Slack Questions"
  sql_always_where:
    'developer' = {{ _user_attributes['department'] }}
    or 'admin' = {{ _user_attributes['department'] }}
    or TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'jabbok@equipmentshare.com';;

  join: parent_market {
    type: left_outer
    relationship: many_to_one
    sql_on: ${help_be_slack_responses.market_id} = ${parent_market.market_id}
      and date_trunc(month, ${help_be_slack_responses.event_date} >= date_trunc(month, ${parent_market.start_date}::date)
      and date_trunc(month, ${help_be_slack_responses.event_date} <= coalesce(date_trunc(month, ${parent_market.end_date}::date), '2099-12-31'))
      ;;
  }

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: coalesce(${parent_market.parent_market_id}, ${help_be_slack_responses.market_id}) = ${market_region_xwalk.market_id} ;;
  }

  join: revmodel_market_rollout_conservative {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${revmodel_market_rollout_conservative.market_id}::text ;;
  }

  join: plexi_periods {
    type: inner
    relationship: many_to_one
    sql_on: ${help_be_slack_responses.event_date}::date = ${plexi_periods.date}::date ;; #Might need to offset event_date by -1 months to account for BE lag
  }
}

explore: district_region_manager_directory {}

explore: dbt_results {
  label: "fa_dbt_run_results"
  description: "dbt run results for dashboard viewing."
}

explore: market_info {
  label: "Market Information"
  description: "Market information for Kinzie and team."
}

explore: stat_gaap_account_comparison {
  label: "Branch Earnings/GAAP P/L Comparison"

  join: plexi_periods {
    type: left_outer
    relationship: many_to_one
    sql_on: ${stat_gaap_account_comparison.gl_month} = ${plexi_periods.date} ;;
  }
}

explore: asset_category_utilization_metrics {
  label: "Asset Category Utilization Metrics"

  sql_always_where: (${market_region_xwalk.District_Region_Market_Access})
  or 'developer' = {{ _user_attributes['department'] }}
  or 'admin' = {{ _user_attributes['department'] }};;

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_category_utilization_metrics.market_id}::text = ${market_region_xwalk.market_id}::text ;;
  }
}

explore: target_market_account_comp {
  label: "Target Market Account Comp"

  sql_always_where: (${market_region_xwalk.District_Region_Market_Access})
  or 'developer' = {{ _user_attributes['department'] }}
  or 'admin' = {{ _user_attributes['department'] }};;

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${target_market_account_comp.market_id}::text = ${market_region_xwalk.market_id}::text ;;
  }

  join: plexi_periods {
    type: left_outer
    relationship: many_to_one
    sql_on: date_trunc(month,${target_market_account_comp.gl_month_date}::date) = ${plexi_periods.date}::date;;
  }
}

explore: target_market_kpi_comp {
  label: "Target Market KPI Comp"

  sql_always_where: (${market_region_xwalk.District_Region_Market_Access})
  or 'developer' = {{ _user_attributes['department'] }}
  or 'admin' = {{ _user_attributes['department'] }};;


  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${target_market_kpi_comp.market_id}::text = ${market_region_xwalk.market_id}::text ;;
  }

  join: plexi_periods {
    type: left_outer
    relationship: many_to_one
    sql_on: date_trunc(month,${target_market_kpi_comp.gl_month}::date) = ${plexi_periods.date}::date;;
  }
}

explore: be_account_targets_and_projections {
  label: "Account Targets"

  sql_always_where: (${market_region_xwalk.District_Region_Market_Access})
      or 'developer' = {{ _user_attributes['department'] }}
      or 'admin' = {{ _user_attributes['department'] }};;

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${be_account_targets_and_projections.market_id}::text = ${market_region_xwalk.market_id}::text ;;
  }

  join: plexi_periods {
    type: left_outer
    relationship: many_to_one
    sql_on: date_trunc(month,${be_account_targets_and_projections.gl_month_date}::date) = ${plexi_periods.date}::date;;
  }
}

explore: rpo_quote_asset_details {
  label: "RPO Quote Asset Details"
}

explore: retail_asset_inventory {
  label: "Retail Asset Inventory"
}

explore: price_volume_mix_analysis {
  label: "Price Volume Mix Analysis"
}

explore: price_volume_mix_analysis_market {
  label: "Price Volume Mix Analysis - Branch-Level"

  sql_always_where: (${market_region_xwalk.District_Region_Market_Access})
  or 'developer' = {{ _user_attributes['department'] }}
  or 'admin' = {{ _user_attributes['department'] }};;


  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${price_volume_mix_analysis_market.market_id}::text = ${market_region_xwalk.market_id}::text ;;
  }
}

explore: high_level_financials {
  label: "Region Market Ranking"
  #filtering so that GMs can only see ranking at their Regional level
  sql_always_where:
            (${market_region_xwalk.region_name} in ({{ _user_attributes['region'] }})
            AND ${market_region_xwalk.market_type_id} != 4)
    OR 'developer' = {{ _user_attributes['department'] }}
    OR 'admin' = {{ _user_attributes['department'] }}
    OR trim(lower('{{ _user_attributes['email'] | replace: "'", "\\'"}}')) = 'jabbok@equipmentshare.com'
   ;;

  join: parent_market {
    type: left_outer
    relationship: many_to_one
    sql_on: ${high_level_financials.market_id}::text = ${parent_market.market_id}
      AND date_trunc(month, ${high_level_financials.gl_date}::date) >= date_trunc(month, ${parent_market.start_date}::date)
      AND date_trunc(month, ${high_level_financials.gl_date}::date) <= coalesce(date_trunc(month, ${parent_market.end_date}::date), '2099-12-31')
    ;;
  }

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: coalesce(${parent_market.parent_market_id},${high_level_financials.market_id}::text)
      = ${market_region_xwalk.market_id}::text ;;
  }

  join: revmodel_market_rollout_conservative {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${revmodel_market_rollout_conservative.market_id} ;;
  }

  join: plexi_periods {
    type: inner
    relationship: many_to_one
    sql_on: ${high_level_financials.gl_date}::date = ${plexi_periods.date}::date ;;
  }
}
