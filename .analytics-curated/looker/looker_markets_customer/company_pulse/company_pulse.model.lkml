connection: "es_snowflake_analytics"

include: "/company_pulse/*.view.lkml"
include: "/company_pulse/Company_Pulse_2.0/*.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/ES_WAREHOUSE/users.view.lkml"
include: "/views/ANALYTICS/company_directory.view.lkml"
include: "/company_pulse/Company_Pulse_2.0/*"
include: "/views/custom_sql/platform_gold_v_dates.view.lkml"
include: "/views/custom_sql/v_dim_dates_bi.view.lkml"
include: "/views/GS/revmodel_market_rollout_conservative.view.lkml"
include: "/views/ANALYTICS/int_equipment_assignments.view.lkml"
include: "/views/ES_WAREHOUSE/rentals.view.lkml"
include: "/views/ES_WAREHOUSE/orders.view.lkml"
include: "/views/ES_WAREHOUSE/companies.view.lkml"
include: "/markets_dashboard/*.view.lkml"
include: "/location_permissions/*.view.lkml"

include: "/views/Procurement/*.view.lkml"
include: "/views/ANALYTICS/top_vendor_mapping.view.lkml"
include: "/views/ES_WAREHOUSE/entities.view.lkml"
include: "/views/ES_WAREHOUSE/entity_vendor_settings.view.lkml"
include: "/views/ES_WAREHOUSE/parts.view.lkml"
include: "/views/ES_WAREHOUSE/markets.view.lkml"
include: "/views/Business_Intelligence/stg_t3__on_rent.view.lkml"

include: "/views/custom_sql/work_orders_for_markets.view.lkml"

include: "/market_insights/market_newsletter_insights.view.lkml"

datagroup: market_level_hourly_data_update {
  sql_trigger: select max(daily_timestamp) from analytics.assets.market_level_asset_metrics_daily ;;
  max_cache_age: "4 hours"
  description: "Looking at analytics.assets.market_level_asset_metrics_daily to get most recent update."
}

datagroup: int_asset_historical_hourly_data_update {
  sql_trigger: select max(daily_timestamp) from analytics.assets.int_asset_historical ;;
  max_cache_age: "4 hours"
  description: "Looking at analytics.assets.int_asset_historical to get most recent update."
}

datagroup: stg_bi__daily_actively_renting_customers_data_update {
  sql_trigger: select max(update_timestamp) from business_intelligence.triage.stg_bi__daily_actively_renting_customers ;;
  max_cache_age: "24 hours"
  description: "Looking at business_intelligence.triage.stg_bi__daily_actively_renting_customers to get most recent update."
}

datagroup: first_day_breakdowns_by_market_30_days_data_update {
  sql_trigger: select max(_update_timestamp) from analytics.bi_ops.first_day_breakdowns_by_market_30_days ;;
  max_cache_age: "24 hours"
  description: "Looking at analytics.bi_ops.first_day_breakdowns_by_market_30_days  to get most recent update."
}

datagroup: first_day_breakdowns_by_market_ttm_data_update {
  sql_trigger: select max(_update_timestamp) from analytics.bi_ops.first_day_breakdowns_by_market_ttm ;;
  max_cache_age: "770 hours"
  #this is just over 32 days. this updates once a month
  description: "Looking at analytics.bi_ops.first_day_breakdowns_by_market_ttm  to get most recent update."
}

datagroup: stg_t3_on_rent_data_update {
  sql_trigger: select max(data_refresh_timestamp) from BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__ON_RENT ;;
  max_cache_age: "8 hours"
  description: "Looking at STG_T3__ON_RENT to get most recent update."
}



explore: company_pulse_oec {
  group_label: "Company Pulse"
  label: "Region OEC On Rent Last 90 Days"
  case_sensitive: no
  persist_for: "8 hours"
}

explore: company_pulse_inventory_information {
  group_label: "Company Pulse"
  label: "Region Inventory Status"
  case_sensitive: no
  persist_for: "8 hours"
}

explore: company_pulse_eom_oec_on_rent {
  group_label: "Company Pulse"
  label: "Region OEC On Rent TTM End of Month"
  case_sensitive: no
  persist_for: "8 hours"
}

explore: company_pulse_financial_utilization_history {
  group_label: "Historical Metrics for Regional/District Ranking"
  label: "Monthly Historical Financial Utilization"
  case_sensitive: no
  persist_for: "8 hours"
}

# explore: company_pulse_time_ute_history {
#   group_label: "Regional/District Ranking"
#   label: "Time Utilization by Region Hierarchy Historical"
#   case_sensitive: no
#   persist_for: "8 hours"
# }

explore: company_pulse_bulk_historical {
  group_label: "Company Pulse"
  label: "Total Bulk Quantity Last Day of Month by Region"
  case_sensitive: no
  persist_for: "8 hours"
  sql_always_where: (${location_permissions.market_access} OR ${location_permissions.district_access} OR  ${location_permissions.region_access} );;
  join: location_permissions {
    type: inner
    relationship: many_to_one
    sql_on: ${company_pulse_bulk_historical.market_id} = ${location_permissions.market_id} ;;
  }

  join: v_dim_dates_bi {
    view_label: "V Dim Dates BI"
    type: inner
    sql_on: ${company_pulse_bulk_historical.rental_day_date} = ${v_dim_dates_bi.date} ;;
    relationship: many_to_one
  }

}

explore: company_pulse_bulk_historical_market {
  group_label: "Company Pulse"
  label: "Total Bulk Quantity Last Day of Month - Market Highlighting"
  case_sensitive: no
  persist_for: "8 hours"
  sql_always_where: (${location_permissions.market_access} OR ${location_permissions.district_access} OR  ${location_permissions.region_access} );;
  join: location_permissions {
    type: inner
    relationship: many_to_one
    sql_on: ${company_pulse_bulk_historical_market.market_id} = ${location_permissions.market_id} ;;
}
  join: v_dim_dates_bi {
    view_label: "V Dim Dates BI"
    type: inner
    sql_on: ${company_pulse_bulk_historical_market.rental_day_date} = ${v_dim_dates_bi.date} ;;
    relationship: many_to_one
  }
}

explore: company_pulse_bulk_historical_district {
  group_label: "Company Pulse"
  label: "Total Bulk Quantity Last Day of Month - District Highlighting"
  case_sensitive: no
  persist_for: "8 hours"
  sql_always_where: (${location_permissions.market_access} OR ${location_permissions.district_access} OR  ${location_permissions.region_access} );;
  join: location_permissions {
    type: inner
    relationship: many_to_one
    sql_on: ${company_pulse_bulk_historical_district.market_id} = ${location_permissions.market_id} ;;
  }
  join: v_dim_dates_bi {
    view_label: "V Dim Dates BI"
    type: inner
    sql_on: ${company_pulse_bulk_historical_district.rental_day_date} = ${v_dim_dates_bi.date} ;;
    relationship: many_to_one
  }
}

explore: company_pulse_first_day_breakdowns_30_days {
  group_label: "Company Pulse"
  label: "First Day Breakdowns By Market (30 days)"
  case_sensitive: no
  description: "View of first day breakdowns by market, region"
  persist_with: first_day_breakdowns_by_market_30_days_data_update
  sql_always_where: (${location_permissions.market_access} OR ${location_permissions.district_access} OR  ${location_permissions.region_access} );;
  join: location_permissions {
    type: inner
    relationship: many_to_one
    sql_on: ${company_pulse_first_day_breakdowns_30_days.market_id} = ${location_permissions.market_id} ;;
  }
}

explore: company_pulse_first_day_breakdowns_30_days_market {
  group_label: "Company Pulse"
  label: "First Day Breakdowns By Market (30 days) - Market Highlight"
  case_sensitive: no
  description: "View of first day breakdowns by market"
  persist_with: first_day_breakdowns_by_market_30_days_data_update
  sql_always_where: (${location_permissions.market_access} OR ${location_permissions.district_access} OR  ${location_permissions.region_access} );;
  join: location_permissions {
    type: inner
    relationship: many_to_one
    sql_on: ${company_pulse_first_day_breakdowns_30_days_market.market_id} = ${location_permissions.market_id} ;;
  }
}

explore: company_pulse_first_day_breakdowns_30_days_district {
  group_label: "Company Pulse"
  label: "First Day Breakdowns By Market (30 days) - District Highlight"
  case_sensitive: no
  description: "View of first day breakdowns by district"
  persist_with: first_day_breakdowns_by_market_30_days_data_update
  sql_always_where: (${location_permissions.market_access} OR ${location_permissions.district_access} OR  ${location_permissions.region_access} );;
  join: location_permissions {
    type: inner
    relationship: many_to_one
    sql_on: ${company_pulse_first_day_breakdowns_30_days_district.market_id} = ${location_permissions.market_id} ;;
  }
}

explore: company_pulse_first_day_breakdowns_ttm {
  group_label: "Company Pulse"
  label: "First Day Breakdowns By Market (trailing 12 months)"
  case_sensitive: no
  description: "View of first day breakdowns by market, region"
  persist_with: first_day_breakdowns_by_market_ttm_data_update
  sql_always_where: (${location_permissions.market_access} OR ${location_permissions.district_access} OR  ${location_permissions.region_access} );;
  join: location_permissions {
    type: inner
    relationship: many_to_one
    sql_on: ${company_pulse_first_day_breakdowns_ttm.market_id} = ${location_permissions.market_id} ;;
  }
}

explore: company_pulse_first_day_breakdowns_by_market_ttm_market {
  group_label: "Company Pulse"
  label: "First Day Breakdowns By Market (trailing 12 months) - Market Highlight"
  case_sensitive: no
  description: "View of first day breakdowns by market"
  persist_with: first_day_breakdowns_by_market_ttm_data_update
  sql_always_where: (${location_permissions.market_access} OR ${location_permissions.district_access} OR  ${location_permissions.region_access} );;
  join: location_permissions {
    type: inner
    relationship: many_to_one
    sql_on: ${company_pulse_first_day_breakdowns_by_market_ttm_market.market_id} = ${location_permissions.market_id} ;;
  }
}

explore: company_pulse_first_day_breakdowns_by_market_ttm_district {
  group_label: "Company Pulse"
  label: "First Day Breakdowns By Market (trailing 12 months) - District Highlight"
  case_sensitive: no
  description: "View of first day breakdowns by market"
  persist_with: first_day_breakdowns_by_market_ttm_data_update

  sql_always_where: (${location_permissions.market_access} OR ${location_permissions.district_access} OR  ${location_permissions.region_access} );;
  join: location_permissions {
    type: inner
    relationship: many_to_one
    sql_on: ${company_pulse_first_day_breakdowns_by_market_ttm_district.market_id} = ${location_permissions.market_id} ;;
  }
}


explore: company_pulse_unavailable_oec_by_market {
  group_label: "Unavailable OEC by Market"
  label: "Unavailable OEC by Market"
  case_sensitive: no
  description: "View of unavailable OEC by market, region, and date"
  persist_for: "8 hours"
}

explore: company_pulse_hist_time_ute_w_model {
  group_label: "Historical Metrics for Regional/District Ranking"
  label: "Time Utilization by Region Hierarchy Historical - Utilization Model"
  case_sensitive: no
  persist_for: "8 hours"
}

explore: company_pulse_rolling_30_time_ute_w_model {
  group_label: "Company Pulse"
  label: "Rolling 30 Time Utilization by Region Hierarchy - Utilization Model"
  case_sensitive: no
  persist_for: "8 hours"
}

explore: int_asset_historical_rental{
  group_label: "Company Pulse 2.0"
  sql_always_where: ${v_dim_dates_bi.date} >= DATEADD(month, -14, DATE_TRUNC(month, current_date)) and ${in_rental_fleet} and
  (${market_region_xwalk.division_name} <> 'Materials' OR ${market_region_xwalk.division_name} is null) AND

  (${location_permissions.market_access} OR ${location_permissions.district_access} OR  ${location_permissions.region_access} )
    ;;
    case_sensitive: no
  persist_with: int_asset_historical_hourly_data_update
 # persist_for: "1 hour"

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: ${int_asset_historical_rental.market_id} = ${market_region_xwalk.market_id} ;;
    }

  join: v_dim_dates_bi {
    view_label: "V Dim Dates BI"
    type: inner
    sql_on: ${int_asset_historical_rental.daily_timestamp_date} = ${v_dim_dates_bi.date} ;;
    relationship: many_to_one
  }

  join: location_permissions {
    from: location_permissions_optimized

    type: inner
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${location_permissions.market_id} ;;
  }

  }


explore: market_level_asset_metrics_daily {
  group_label: "Company Pulse 2.0"
  description: "Daily OEC, unavailable, rental revenue at market level"
  persist_with: market_level_hourly_data_update
  case_sensitive: no
  # persist_for: "1 hour"
  sql_always_where:  (${market_region_xwalk.division_name} <> 'Materials' OR ${market_region_xwalk.division_name} is null) AND

  (${location_permissions.market_access} OR ${location_permissions.district_access} OR  ${location_permissions.region_access} );;

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: ${market_level_asset_metrics_daily.market_id} = ${market_region_xwalk.market_id}  ;;
  }

  join: v_dim_dates_bi {
    view_label: "V Dim Dates BI"
    type: inner
    sql_on: ${market_level_asset_metrics_daily.daily_timestamp_date} =  ${v_dim_dates_bi.date} ;;
    relationship: many_to_one
  }


  join: location_permissions {
    from: location_permissions_optimized
    type: inner
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${location_permissions.market_id} ;;
  }

}

explore: market_rental_revenue_hist_with_goals {
  group_label: "Company Pulse 2.0"
  description: "Monthly rental revenue at market level with goals from analytics.public.market_goals as of July 29th, 2025"
  persist_with:  market_level_hourly_data_update
  case_sensitive: no
  sql_always_where:
  (${location_permissions.market_access} OR ${location_permissions.district_access} OR  ${location_permissions.region_access} ) ;;

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: ${market_rental_revenue_hist_with_goals.market_id} = ${market_region_xwalk.market_id} and (${market_region_xwalk.division_name} <> 'Materials' OR ${market_region_xwalk.division_name} is null) ;;
  }

  join: location_permissions {
    from: location_permissions_optimized

    type: inner
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${location_permissions.market_id} ;;
  }
}

explore: int_asset_historical_current_day {
  group_label: "Company Pulse 2.0"
  label: "Current Date Int Asset Historical"
  description: "Rental fleet asset status for the current date."
  persist_with: int_asset_historical_hourly_data_update
  case_sensitive: no
  #persist_for: "1 hour"

  sql_always_where: ${int_asset_historical_current_day.daily_timestamp_date} >= CURRENT_DATE
    AND ${int_asset_historical_current_day.daily_timestamp_date} < DATEADD(day, 1, CURRENT_DATE)
  AND ${int_asset_historical_current_day.in_rental_fleet}
  AND COALESCE(${market_region_xwalk.division_name}, '') <> 'Materials' AND

  (${location_permissions.market_access} OR ${location_permissions.district_access} OR  ${location_permissions.region_access} ) ;;

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: ${int_asset_historical_current_day.rental_branch_id} = ${market_region_xwalk.market_id} ;;
  }

  join: location_permissions {
    from: location_permissions_optimized

    type: inner
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${location_permissions.market_id} ;;
  }

  join: work_orders_for_markets {
    type: left_outer
    relationship: one_to_many
    sql_on: ${int_asset_historical_current_day.asset_id} = ${work_orders_for_markets.asset_id} ;;
  }
}

explore: int_asset_historical_rerents {
  group_label: "Company Pulse 2.0"
  label: "Int Asset Historical - Re-Rents ONLY"
  description: "Current date rerent assets."
  persist_with: int_asset_historical_hourly_data_update
  case_sensitive: no
  #persist_for: "1 hour"

  sql_always_where: ${int_asset_historical_rerents.daily_timestamp_date} >= CURRENT_DATE
    AND ${int_asset_historical_rerents.daily_timestamp_date} < DATEADD(day, 1, CURRENT_DATE)
  AND COALESCE(${market_region_xwalk.division_name}, '') <> 'Materials' AND
    ${int_asset_historical_rerents.is_rerent_asset} and
    (${location_permissions.market_access} OR ${location_permissions.district_access} OR  ${location_permissions.region_access} ) ;;

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: ${int_asset_historical_rerents.rental_branch_id} = ${market_region_xwalk.market_id};;
  }

  join: location_permissions {
    from: location_permissions_optimized

    type: inner
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${location_permissions.market_id} ;;
  }
}



explore: mlamd_region_highlighted {
  group_label: "Company Pulse 2.0"
  description: "Daily oec, unavailable, rental revenue at market level WITH REGION HIGHLIGHTING"
  persist_with:  market_level_hourly_data_update
  case_sensitive: no
  #persist_for: "1 hour"
  sql_always_where:
  (${location_permissions.market_access} OR ${location_permissions.district_access} OR  ${location_permissions.region_access} ) ;;

  join: v_dim_dates_bi {
    view_label: "V Dim Dates BI"
    type: inner
    sql_on: ${mlamd_region_highlighted.daily_timestamp_date} =  ${v_dim_dates_bi.date} ;;
    relationship: many_to_one
  }

  join: location_permissions {
    from: location_permissions_optimized

    type: inner
    relationship: many_to_one
    sql_on: ${mlamd_region_highlighted.market_id} = ${location_permissions.market_id} ;;
  }
}


explore: mlamd_market_highlighted {
  group_label: "Company Pulse 2.0"
  description: "Daily oec, unavailable, rental revenue at market level WITH MARKET HIGHLIGHTING"
  persist_with: market_level_hourly_data_update
  case_sensitive: no
  sql_always_where:
  (${location_permissions.market_access} OR ${location_permissions.district_access} OR  ${location_permissions.region_access} ) ;;

  join: v_dim_dates_bi {
    view_label: "V Dim Dates BI"
    type: inner
    sql_on: ${mlamd_market_highlighted.daily_timestamp_date} =  ${v_dim_dates_bi.date} ;;
    relationship: many_to_one
  }

  join: location_permissions {
    from: location_permissions_optimized

    type: inner
    relationship: many_to_one
    sql_on: ${mlamd_market_highlighted.market_id} = ${location_permissions.market_id} ;;
  }
}

explore: mlamd_district_highlighted {
  group_label: "Company Pulse 2.0"
  description: "Daily oec, unavailable, rental revenue at market level WITH DISTRICT HIGHLIGHTING"
  persist_with: market_level_hourly_data_update
  case_sensitive: no
  sql_always_where:
  (${location_permissions.market_access} OR ${location_permissions.district_access} OR  ${location_permissions.region_access} ) ;;

  join: v_dim_dates_bi {
    view_label: "V Dim Dates BI"
    type: inner
    sql_on: ${mlamd_district_highlighted.daily_timestamp_date} =  ${v_dim_dates_bi.date} ;;
    relationship: many_to_one
  }

  join: location_permissions {
    from: location_permissions_optimized

    type: inner
    relationship: many_to_one
    sql_on: ${mlamd_district_highlighted.market_id} = ${location_permissions.market_id} ;;
  }
}

explore: ancillary_rev_market_refresh_dash_v2 {
  group_label: "Company Pulse 2.0"
  label: "Ancillary Revenue - Company Pulse 2.0"
  description: "Log of all ancillary invoices over the last 14 months by line item id type"
  case_sensitive: no
  sql_always_where: ${ancillary_rev_market_refresh_dash_v2.gl_date_date} IS NOT NULL AND ${ancillary_rev_market_refresh_dash_v2.gl_date_date}
            >= DATEADD(month, -14, date_trunc(month, current_date)) AND
    ${ancillary_rev_market_refresh_dash_v2.revenue_type} IS NOT NULL AND
    NOT ${ancillary_rev_market_refresh_dash_v2.is_intercompany}
    and COALESCE(${market_region_xwalk.division_name}, '') <> 'Materials' AND

  (${location_permissions.market_access} OR ${location_permissions.district_access} OR  ${location_permissions.region_access} );;
  persist_for: "1 hour"

  join: v_dim_dates_bi {
    view_label: "V Dim Dates BI"
    type: inner
    sql_on:  ${ancillary_rev_market_refresh_dash_v2.gl_date_date} =  ${v_dim_dates_bi.date} ;;
    relationship: many_to_one
  }

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: ${ancillary_rev_market_refresh_dash_v2.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: location_permissions {
    from: location_permissions_optimized

    type: inner
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${location_permissions.market_id} ;;
  }

}



explore: rental_rev_market_refresh_dash_v2 {
  group_label: "Company Pulse 2.0"
  sql_always_where: ${rental_rev_market_refresh_dash_v2.is_rental_revenue} and not ${rental_rev_market_refresh_dash_v2.intercompany} and ${rental_rev_market_refresh_dash_v2.gl_approved_date} >= dateadd('month', -14, current_date()) and COALESCE(${market_region_xwalk.division_name}, '') <> 'Materials'AND

  (${location_permissions.market_access} OR ${location_permissions.district_access} OR  ${location_permissions.region_access} );;
  persist_for: "1 hour"
  case_sensitive: no

  join: v_dim_dates_bi {
    view_label: "V Dim Dates BI"
    type: inner
    sql_on:  ${rental_rev_market_refresh_dash_v2.gl_approved_date}::DATE = ${v_dim_dates_bi.date} ;;
    relationship: many_to_one
  }

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: ${rental_rev_market_refresh_dash_v2.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rental_rev_market_refresh_dash_v2.primary_salesperson_id} = ${users.user_id};;
  }

  join: company_directory {
    type: left_outer
    relationship: many_to_one
    sql_on: LOWER(${company_directory.work_email}) = LOWER(${users.email_address}) ;;
  }

  join: location_permissions {
    from: location_permissions_optimized

    type: inner
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${location_permissions.market_id} ;;
  }

}



explore: arc_equip_assignments_iah {
  persist_with: stg_bi__daily_actively_renting_customers_data_update
  description: "Daily actively renting customers based on rentable assets assignments."
  case_sensitive: no
  sql_always_where: COALESCE(${market_region_xwalk.division_name}, '') <> 'Materials'AND

  (${location_permissions.market_access} OR ${location_permissions.district_access} OR  ${location_permissions.region_access} ) ;;


  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${arc_equip_assignments_iah.market_id};;
  }

  join: location_permissions {
    from: location_permissions_optimized

    type: inner
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${location_permissions.market_id} ;;
  }

}

explore: arc_equip_assignments_iah_region_highlighted {
  persist_with: stg_bi__daily_actively_renting_customers_data_update
  description: "Daily actively renting customers based on rentable assets assignments with regional highlighting."
  case_sensitive: no
sql_always_where:
  (${location_permissions.market_access} OR ${location_permissions.district_access} OR ${location_permissions.region_access} ) ;;


  join: location_permissions {
    from: location_permissions_optimized

    type: inner
    relationship: many_to_one
    sql_on: ${arc_equip_assignments_iah_region_highlighted.market_id} = ${location_permissions.market_id} ;;
  }
}

explore: arc_equip_assignments_iah_market_highlighted {
  persist_with: stg_bi__daily_actively_renting_customers_data_update
  description: "Daily actively renting customers based on rentable assets assignments with market highlighting."
  case_sensitive: no
  sql_always_where:
  (${location_permissions.market_access} OR ${location_permissions.district_access} OR  ${location_permissions.region_access} ) ;;


  join: location_permissions {
    from: location_permissions_optimized

    type: inner
    relationship: many_to_one
    sql_on: ${arc_equip_assignments_iah_market_highlighted.market_id} = ${location_permissions.market_id} ;;
  }
}

explore: arc_equip_assignments_iah_district_highlighted {
  persist_with: stg_bi__daily_actively_renting_customers_data_update
  description: "Daily actively renting customers based on rentable assets assignments with district highlighting."
  case_sensitive: no
  sql_always_where:
  (${location_permissions.market_access} OR ${location_permissions.district_access} OR  ${location_permissions.region_access} ) ;;


  join: location_permissions {
    from: location_permissions_optimized

    type: inner
    relationship: many_to_one
    sql_on: ${arc_equip_assignments_iah_district_highlighted.market_id} = ${location_permissions.market_id} ;;
  }
}

explore: int_asset_hist_today_by_status  {
  label: "Current Date Asset Inventory Status"
  group_label: "Company Pulse 2.0"
  persist_with: int_asset_historical_hourly_data_update
  case_sensitive: no
sql_always_where:  (${location_permissions.market_access} OR ${location_permissions.district_access} OR  ${location_permissions.region_access} ) ;;
  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: ${int_asset_hist_today_by_status.rental_branch_id} = ${market_region_xwalk.market_id} ;;
  }

  join: location_permissions {
    from: location_permissions_optimized

    type: inner
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${location_permissions.market_id} ;;
  }

  join: int_asset_historical_current_day {
    type: inner
    sql_on: ${market_region_xwalk.market_id} = ${int_asset_historical_current_day.rental_branch_id}
      and ${int_asset_hist_today_by_status.asset_inventory_status} = ${int_asset_historical_current_day.asset_inventory_status} and
      ${int_asset_historical_current_day.rental_branch_id} = ${int_asset_hist_today_by_status.rental_branch_id};;
    relationship: one_to_many
  }

  join: work_orders_for_markets {
    type: left_outer
    relationship: one_to_many
    sql_on: ${int_asset_historical_current_day.asset_id} = ${work_orders_for_markets.asset_id} ;;
  }
}

explore: purchase_order_line_items {
  label: "Open PO Information"
  group_label: "Company Pulse 2.0"
  case_sensitive: no
  sql_always_where: ${procurement_purchase_orders.date_archived_date} IS NULL AND
    ${items.date_archived_date} IS NULL AND
    ${purchase_order_line_items.date_archived_date} IS NULL AND
    ${procurement_purchase_orders.status} = 'OPEN' AND
     (${location_permissions.market_access} OR ${location_permissions.district_access} OR  ${location_permissions.region_access} )
  ;;

  join: location_permissions {
    from: location_permissions_optimized

    type: inner
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${location_permissions.market_id} ;;
  }

  join: procurement_purchase_orders {
    type: inner
    relationship: many_to_one
    sql_on: ${procurement_purchase_orders.purchase_order_id} = ${purchase_order_line_items.purchase_order_id} ;;
  }

  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${procurement_purchase_orders.requesting_branch_id} = ${markets.market_id} ;;
  }

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: ${procurement_purchase_orders.requesting_branch_id} = ${market_region_xwalk.market_id} ;;
  }

  join: entities {
    type: left_outer
    relationship: many_to_one
    sql_on: ${entities.entity_id} = ${procurement_purchase_orders.vendor_id} ;;
  }

  join: entity_vendor_settings {
    type: left_outer
    relationship: one_to_one
    sql_on: ${entity_vendor_settings.entity_id} = ${entities.entity_id} ;;
  }

  join: top_vendor_mapping {
    type: left_outer
    relationship: one_to_one
    sql_on: ${top_vendor_mapping.vendorid} = ${entity_vendor_settings.external_erp_vendor_ref} ;;
  }

  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: ${procurement_purchase_orders.created_by_id} = ${users.user_id} ;;
  }

  join: items {
    type: left_outer
    relationship: many_to_one
    sql_on: ${purchase_order_line_items.item_id} = ${items.item_id} ;;
  }

  join: non_inventory_items {
    type: left_outer
    relationship: many_to_one
    sql_on: ${non_inventory_items.item_id} = ${purchase_order_line_items.item_id} ;;
  }

  join: purchase_order_receiver_items {
    type: left_outer
    relationship: one_to_one
    sql_on: ${purchase_order_line_items.purchase_order_line_item_id} = ${purchase_order_receiver_items.purchase_order_line_item_id} ;;
  }

  join: purchase_order_receivers {
    type: left_outer
    relationship: many_to_one
    sql_on: ${purchase_order_receiver_items.purchase_order_receiver_id} = ${purchase_order_receivers.purchase_order_receiver_id} ;;
  }

  join: parts {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts.item_id} = ${purchase_order_line_items.item_id} ;;
  }

}


explore: customer_trends_by_priority {
  label: "Customer Trends by Priority"
  group_label: "Company Pulse 2.0"
  ##persist_with: int_asset_historical_hourly_data_update
  persist_for: "8 hours"
  case_sensitive: no
  sql_always_where:  (${location_permissions.market_access} OR ${location_permissions.district_access} OR  ${location_permissions.region_access} ) ;;
  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: ${customer_trends_by_priority.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: location_permissions {
    from: location_permissions_optimized

    type: inner
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${location_permissions.market_id} ;;
  }
}

explore: market_level_asset_metrics_current_date_review {
  from: market_level_asset_metrics_daily
  label: "Market Level Asset Metrics Current Date Review"
  description: "Daily OEC, unavailable, rental revenue at market level for the current date, a week out, two weeks out, three weeks out, and a month ago."
  persist_with: market_level_hourly_data_update
  case_sensitive: no
  # persist_for: "1 hour"
  sql_always_where:  (${market_region_xwalk.division_name} <> 'Materials' OR ${market_region_xwalk.division_name} is null)
    AND (${v_dim_dates_bi.is_current_day} OR dateadd(week, -1, current_date)::DATE = ${v_dim_dates_bi.date} OR dateadd(week, -2, current_date)::DATE = ${v_dim_dates_bi.date} or dateadd(week, -3, current_date)::DATE = ${v_dim_dates_bi.date} OR dateadd(month, -1, current_date) = ${v_dim_dates_bi.date})
    AND (${location_permissions.market_access} OR ${location_permissions.district_access} OR  ${location_permissions.region_access} );;

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: ${market_level_asset_metrics_current_date_review.market_id} = ${market_region_xwalk.market_id}  ;;
  }

  join: v_dim_dates_bi {
    view_label: "V Dim Dates BI"
    type: inner
    sql_on: ${market_level_asset_metrics_current_date_review.daily_timestamp_date} =  ${v_dim_dates_bi.date} ;;
    relationship: many_to_one
  }


  join: location_permissions {
    from: location_permissions_optimized

    type: inner
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${location_permissions.market_id} ;;
  }

}


explore: stg_t3__on_rent {
  label: "On Rent Report"
  persist_with: stg_t3_on_rent_data_update
  case_sensitive: no
  sql_always_where:  (${location_permissions.market_access} OR ${location_permissions.district_access} OR  ${location_permissions.region_access} ) ;;

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: ${stg_t3__on_rent.rental_location} = ${market_region_xwalk.market_name}  ;;
  }

  join: location_permissions {
    from: location_permissions_optimized

    type: inner
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${location_permissions.market_id} ;;
  }

}

explore: arc_equip_assignments_rollup_market {
  case_sensitive:  no
  persist_for: "12 hours"

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: ${arc_equip_assignments_rollup_market.market_id} = ${market_region_xwalk.market_id}  ;;
  }

}

explore: arc_equip_assignments_rollup_district {
  case_sensitive:  no
  persist_for: "12 hours"



}

explore: arc_equip_assignments_rollup_region {
  case_sensitive:  no
  persist_for: "12 hours"



}

explore:  market_newsletter_insights {
  case_sensitive: no
  group_label: "Market Insights"
  label: "Market Newsletter Insights Testing"
}
