connection: "es_snowflake_analytics"

include: "/views/ANALYTICS/form_2.view.lkml"
include: "/views/ANALYTICS/form_3.view.lkml"
include: "/views/ANALYTICS/form_4.view.lkml"
include: "/views/ANALYTICS/claims_road.view.lkml"
include: "/views/ES_WAREHOUSE/assets.view.lkml"
include: "/views/ES_WAREHOUSE/markets.view.lkml"
include: "/views/ES_WAREHOUSE/asset_purchase_history.view.lkml"
include: "/views/ANALYTICS/company_directory.view.lkml"
include: "/views/ANALYTICS/disc_master.view.lkml"
include: "/views/custom_sql/hr_greenhouse_link.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/custom_sql/ee_id_and_completed_disc.view.lkml"
include: "/views/ANALYTICS/claims_damage.view.lkml"
include: "/views/ES_WAREHOUSE/companies.view.lkml"
include: "/views/ANALYTICS/v_line_items.view.lkml"
include: "/views/ANALYTICS/wc_injuries_internal.view.lkml"
include: "/views/ANALYTICS/wc_loss_run.view.lkml"
include: "/views/custom_sql/wc_frequency_severity.view.lkml"
include: "/views/ANALYTICS/historic_market_vehicle_loss_count.view.lkml"
include: "/views/ANALYTICS/asset_nbv_all_owners.view.lkml"
include: "/views/custom_sql/historic_vehicle_market.view.lkml"
include: "/views/ANALYTICS/historic_market_payroll_loss_count.view.lkml"
include: "/views/ANALYTICS/historic_market_employee_loss_count.view.lkml"
include: "/views/custom_sql/monthly_trend_of_injures.view.lkml"
include: "/views/ANALYTICS/int_claims__historic_market_employee_claim_count.view.lkml"
include: "/views/ANALYTICS/int_claims__historic_market_vehicle_claim_count.view.lkml"
include: "/views/custom_sql/int_claims__auto_accident_insurance_claims_rolling_12mo.view.lkml"
include: "/views/custom_sql/int_claims__historic_market_employee_claim_count_rolling_12mo.view.lkml"
include: "/views/custom_sql/int_claims__historic_market_vehicle_claim_count_rolling_12mo.view.lkml"
include: "/views/custom_sql/int_claims__work_comp_insurance_claims_rolling_12mo.view.lkml"
include: "/views/ANALYTICS/int_assets.view.lkml"
include: "/views/custom_sql/plexi_periods.view.lkml"
include: "/views/custom_sql/company_directory_vault_active.view.lkml"
include: "/views/ANALYTICS/int_asset_historical_ownership.view.lkml"

explore: form_2 {case_sensitive: no}

explore: form_3 {case_sensitive: no}

explore: form_4 {case_sensitive: no}

explore: monthly_trend_of_injures {
  label: "Monthly_Trend_of_Injures"

  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${markets.market_id} = ${monthly_trend_of_injures.market_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on:${markets.market_id} = ${market_region_xwalk.market_id} ;;
  }
}

explore: claims_road {
  from: claims_road
  case_sensitive: no
  sql_always_where: 'god view' = {{ _user_attributes['department'] }}
  OR 'developer' = {{ _user_attributes['department'] }}
  OR 'insurance' = {{ _user_attributes['department'] }}
  OR 'safety'    = {{ _user_attributes['department'] }}
  OR ('managers' = {{ _user_attributes['department'] }} and ${market_region_xwalk.district_region_market_access}) ;;

  join: assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${claims_road.asset_number} = ${assets.asset_id} ;;
  }

  join: company_directory {
    type: left_outer
    relationship: many_to_one
    sql_on: ${claims_road.driver_employee_id} = ${company_directory.employee_id} ;;
  }

  join: disc_master {
    type: left_outer
    relationship: one_to_one
    sql_on: ${disc_master.disc_code} = ${ee_id_and_completed_disc.disc_code};;
  }

  join: ee_id_and_completed_disc {
    type: left_outer
    relationship: one_to_one
    sql_on: ${claims_road.driver_employee_id} = ${ee_id_and_completed_disc.employee_id} ;;
  }

  join: hr_greenhouse_link {
    type: left_outer
    relationship: one_to_one
    sql_on: ${company_directory.employee_id} = ${hr_greenhouse_link.employee_id} ;;
  }

  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${claims_road.market_id} = ${markets.market_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on:${markets.market_id} = ${market_region_xwalk.market_id} ;;
    fields: [market_region_xwalk.market_id,
      market_region_xwalk.district,
      market_region_xwalk.region,
      market_region_xwalk.market_name,
      market_region_xwalk.region_name,
      market_region_xwalk.district_region_market_access]
  }
}

# explore: claims_damage { --MB comment out 10-10-23 due to inactivity
#   from: claims_damage
#   case_sensitive: no
#   sql_always_where: 'god view' = {{ _user_attributes['department'] }}
#   OR 'developer' = {{ _user_attributes['department'] }}
#   OR ('managers' = {{ _user_attributes['department'] }} and ${market_region_xwalk.district_region_market_access}) ;;

#   join: assets {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${claims_damage.asset_number} = ${assets.asset_id} ;;
#   }
#   join: markets {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${claims_damage.market_id} = ${markets.market_id} ;;
#   }

#   join: market_region_xwalk {
#     type: left_outer
#     relationship: many_to_one
#     sql_on:${markets.market_id} = ${market_region_xwalk.market_id} ;;
#     fields: [market_region_xwalk.market_id,
#       market_region_xwalk.district,
#       market_region_xwalk.region,
#       market_region_xwalk.region_name,
#       market_region_xwalk.district_region_market_access]
#   }

#   join: companies {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${companies.company_id} = ${claims_damage.customer_no} ;;
#   }

#   join: v_line_items {
#     type: left_outer
#     relationship: one_to_many
#     sql_on: ${companies.company_id} = company ;;
#   }

#   }

explore: plexi_periods {hidden:yes}

explore: claims_work_comp {
  from: wc_injuries_internal
  case_sensitive: no
  sql_always_where: 'god view' = {{ _user_attributes['department'] }}
  OR 'developer' = {{ _user_attributes['department'] }}
  OR 'insurance' = {{ _user_attributes['department'] }}
  OR 'safety'    = {{ _user_attributes['department'] }}
  OR ('managers' = {{ _user_attributes['department'] }} and ${market_region_xwalk.district_region_market_access}) ;;

  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${claims_work_comp.market_id} = ${markets.market_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on:${markets.market_id} = ${market_region_xwalk.market_id} ;;
    fields: [market_region_xwalk.market_id,
      market_region_xwalk.district,
      market_region_xwalk.region,
      market_region_xwalk.market_name,
      market_region_xwalk.region_name,
      market_region_xwalk.district_region_market_access]
  }

  join: company_directory {
    type: left_outer
    relationship: many_to_one
    sql_on: ${claims_work_comp.employee_} = ${company_directory.employee_id} ;;
  }

  join: ee_id_and_completed_disc {
    type: left_outer
    relationship: one_to_one
    sql_on: ${claims_work_comp.employee_} = ${ee_id_and_completed_disc.employee_id} ;;
  }

  join: hr_greenhouse_link {
    type: left_outer
    relationship: one_to_one
    sql_on: ${company_directory.employee_id} = ${hr_greenhouse_link.employee_id} ;;
  }

  join: disc_master {
    type: left_outer
    relationship: one_to_one
    sql_on: ${disc_master.disc_code} = ${ee_id_and_completed_disc.disc_code};;
  }

  join: wc_loss_run {
    type: left_outer
    relationship: one_to_one
    sql_on: replace(${wc_loss_run.claim_number},' ') = ${claims_work_comp.claim_number};;
  }

  join: plexi_periods {
    type: left_outer
    relationship: many_to_one
    sql_on: ${claims_work_comp.date_of_injury_month} = ${plexi_periods.date} ;;
  }

   }

explore: wc_frequency_severity {
  from: wc_frequency_severity
  case_sensitive: no
}

explore: historic_market_vehicle_loss_count {
  from: historic_market_vehicle_loss_count
  case_sensitive: no
  sql_always_where: 'god view' = {{ _user_attributes['department'] }}
  OR 'developer' = {{ _user_attributes['department'] }}
  OR 'insurance' = {{ _user_attributes['department'] }}
  OR 'safety'    = {{ _user_attributes['department'] }}
  OR ('managers' = {{ _user_attributes['department'] }} and ${market_region_xwalk.district_region_market_access}) ;;

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${historic_market_vehicle_loss_count.market_id} ;;
  }
}

explore: historic_vehicle_market {
  from: historic_vehicle_market
  case_sensitive: no
  sql_always_where: 'god view' = {{ _user_attributes['department'] }}
  OR 'developer' = {{ _user_attributes['department'] }}
  OR 'insurance' = {{ _user_attributes['department'] }}
  OR 'safety'    = {{ _user_attributes['department'] }}
  OR ('managers' = {{ _user_attributes['department'] }} and ${market_region_xwalk.district_region_market_access}) ;;

    join: market_region_xwalk {
      type: left_outer
      relationship: many_to_one
      sql_on: ${market_region_xwalk.market_id} = ${historic_vehicle_market.market_id} ;;
    }

  join: assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${historic_vehicle_market.asset_id} = ${assets.asset_id} ;;
    fields: [assets.asset_id_link_to_asset_dashboard,
      assets.make_and_model]
  }
}

explore: historic_market_payroll_loss_count {
  from: historic_market_payroll_loss_count
  case_sensitive: no
  sql_always_where: 'god view' = {{ _user_attributes['department'] }}
  OR 'developer' = {{ _user_attributes['department'] }}
  OR 'insurance' = {{ _user_attributes['department'] }}
  OR 'safety'    = {{ _user_attributes['department'] }}
  OR ('managers' = {{ _user_attributes['department'] }} and ${market_region_xwalk.district_region_market_access}) ;;

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${historic_market_payroll_loss_count.market_id} ;;
  }
}

explore: historic_market_employee_loss_count {
  from: historic_market_employee_loss_count
  case_sensitive: no
  sql_always_where: 'god view' = {{ _user_attributes['department'] }}
  OR 'developer' = {{ _user_attributes['department'] }}
  OR 'insurance' = {{ _user_attributes['department'] }}
  OR 'safety'    = {{ _user_attributes['department'] }}
  OR ('managers' = {{ _user_attributes['department'] }} and ${market_region_xwalk.district_region_market_access}) ;;

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${historic_market_employee_loss_count.market_id} ;;
  }
}
# New Models
  ## Work Comp
explore: int_claims__historic_market_employee_claim_count {
  from:  int_claims__historic_market_employee_claim_count
  label: "Employee Work Comp Claims"
  sql_always_where: 'god view' = {{ _user_attributes['department'] }}
  OR 'developer' = {{ _user_attributes['department'] }}
  OR 'insurance' = {{ _user_attributes['department'] }}
  OR 'safety'    = {{ _user_attributes['department'] }}
  OR ('managers' = {{ _user_attributes['department'] }} and ${market_region_xwalk.district_region_market_access}) ;;

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id}::varchar = ${int_claims__historic_market_employee_claim_count.market_id}::varchar ;;
  }

  join: plexi_periods {
    type: left_outer
    relationship: many_to_one
    sql_on: ${plexi_periods.date}::date = ${int_claims__historic_market_employee_claim_count.date_month}::date;;
  }

  join: company_directory_vault_active {
    type: left_outer
    relationship: many_to_one
    sql_on: ${int_claims__historic_market_employee_claim_count.market_id}::varchar = ${company_directory_vault_active.market_id}::varchar
      and ${int_claims__historic_market_employee_claim_count.date_month}::date = ${company_directory_vault_active.date_month}::date;;
  }

}

explore: int_claims__historic_market_employee_claim_count_rolling_12mo {
  from: int_claims__historic_market_employee_claim_count_rolling_12mo
  label: "Monthly Work Comp Employee and Claims"
  sql_always_where: 'god view' = {{ _user_attributes['department'] }}
  OR 'developer' = {{ _user_attributes['department'] }}
  OR 'insurance' = {{ _user_attributes['department'] }}
  OR 'safety'    = {{ _user_attributes['department'] }}
  OR ('managers' = {{ _user_attributes['department'] }} and ${market_region_xwalk.district_region_market_access}) ;;

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id}::varchar = ${int_claims__historic_market_employee_claim_count_rolling_12mo.market_id}::varchar ;;
  }

  join: plexi_periods {
    type: left_outer
    relationship: many_to_one
    sql_on: ${plexi_periods.date}::date = ${int_claims__historic_market_employee_claim_count_rolling_12mo.date_month_month}::date;;
  }
}

explore: int_claims__work_comp_insurance_claims_rolling_12mo {
  from: int_claims__work_comp_insurance_claims_rolling_12mo
  label: "List of Work Comp Claims 12-Month Period"
  sql_always_where: 'god view' = {{ _user_attributes['department'] }}
      OR 'developer' = {{ _user_attributes['department'] }}
      OR 'insurance' = {{ _user_attributes['department'] }}
      OR 'safety'    = {{ _user_attributes['department'] }}
      OR ('managers' = {{ _user_attributes['department'] }} and ${market_region_xwalk.district_region_market_access}) ;;

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id}::varchar = ${int_claims__work_comp_insurance_claims_rolling_12mo.market_id}::varchar ;;
  }

  join: plexi_periods {
    type: left_outer
    relationship: many_to_one
    sql_on: ${plexi_periods.date}::date = ${int_claims__work_comp_insurance_claims_rolling_12mo.month_of_claim}::date;;
  }
}


  ## Auto
explore: int_claims__historic_market_vehicle_claim_count {
  from: int_claims__historic_market_vehicle_claim_count
  label: "Auto Comp Claims"
  sql_always_where: 'god view' = {{ _user_attributes['department'] }}
      OR 'developer' = {{ _user_attributes['department'] }}
      OR 'insurance' = {{ _user_attributes['department'] }}
      OR 'safety'    = {{ _user_attributes['department'] }}
      OR ('managers' = {{ _user_attributes['department'] }} and ${market_region_xwalk.district_region_market_access}) ;;

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id}::varchar = ${int_claims__historic_market_vehicle_claim_count.market_id}::varchar ;;
  }

  join: plexi_periods {
    type: left_outer
    relationship: many_to_one
    sql_on: ${plexi_periods.date}::date = ${int_claims__historic_market_vehicle_claim_count.date_month}::date;;
  }

  join: int_asset_historical_ownership {
    type: left_outer
    relationship: many_to_one
    sql_on: ${int_claims__historic_market_vehicle_claim_count.market_id}::varchar = ${int_asset_historical_ownership.market_id}::varchar
      and ${int_claims__historic_market_vehicle_claim_count.date_month}::date = ${int_asset_historical_ownership.month_end}::date;;
  }

  join: int_assets {
    type: inner
    relationship: many_to_one
    sql_on: ${int_assets.asset_id} = ${int_asset_historical_ownership.asset_id} ;;
  }

}

explore: int_claims__historic_market_vehicle_claim_count_rolling_12mo {
  from: int_claims__historic_market_vehicle_claim_count_rolling_12mo
  label: "Monthly Auto Count and Claims"
  sql_always_where: 'god view' = {{ _user_attributes['department'] }}
      OR 'developer' = {{ _user_attributes['department'] }}
      OR 'insurance' = {{ _user_attributes['department'] }}
      OR 'safety'    = {{ _user_attributes['department'] }}
      OR ('managers' = {{ _user_attributes['department'] }} and ${market_region_xwalk.district_region_market_access}) ;;

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id}::varchar = ${int_claims__historic_market_vehicle_claim_count_rolling_12mo.market_id}::varchar ;;
  }

  join: plexi_periods {
    type: left_outer
    relationship: many_to_one
    sql_on: ${plexi_periods.date}::date = date_trunc(month,${int_claims__historic_market_vehicle_claim_count_rolling_12mo.date_month_month}::date);;
  }

}

explore: int_claims__auto_accident_insurance_claims_rolling_12mo {
  from: int_claims__auto_accident_insurance_claims_rolling_12mo
  label: "List of Vehicle Accidents 12-Month Period"
  sql_always_where: 'god view' = {{ _user_attributes['department'] }}
      OR 'developer' = {{ _user_attributes['department'] }}
      OR 'insurance' = {{ _user_attributes['department'] }}
      OR 'safety'    = {{ _user_attributes['department'] }}
      OR ('managers' = {{ _user_attributes['department'] }} and ${market_region_xwalk.district_region_market_access}) ;;

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id}::varchar = ${int_claims__auto_accident_insurance_claims_rolling_12mo.market_id}::varchar ;;
  }

  join: plexi_periods {
    type: left_outer
    relationship: many_to_one
    sql_on: ${plexi_periods.date}::date = date_trunc(month,${int_claims__auto_accident_insurance_claims_rolling_12mo.date_of_claim}::date);;
  }

}
