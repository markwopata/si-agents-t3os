connection: "es_snowflake_analytics"

# include: "/views/FLEET_OPTIMIZATION/dim_assets_fleet_opt.view.lkml"
# include: "/views/FLEET_OPTIMIZATION/dim_dates_fleet_opt.view.lkml"
# include: "/views/DATA_SCIENCE/test_residual_values_by_class.view.lkml"
# include: "/views/DATA_SCIENCE/all_equipment_rouse_estimates.view.lkml"

# explore: dim_assets_fleet_opt {
#   label: "Residual Value Forecasting"
#   case_sensitive: no
#   sql_always_where:
#   ${dim_assets_fleet_opt.asset_own_flag} = 'yes'
#   -- and ${today.equipment_class_id} = TRY_CAST(${dim_assets_fleet_opt.equipment_class_id} AS INTEGER)
#   -- and ${today.months_old} <= 120
#   # ;;

#   # Number of months calculated for forecasted depreciation is calculated from today's date
#   join: today {
#     from: test_residual_values_by_class
#     relationship: many_to_one
#     sql_on: ${today.equipment_class_id} = TRY_CAST(${dim_assets_fleet_opt.equipment_class_id} AS INTEGER)
#     and ${dim_assets_fleet_opt.asset_age_from_purchase_in_months} = ${today.months_old};;
#   }

#   join: all_equipment_rouse_estimates {
#     relationship: many_to_one
#     sql_on: ${all_equipment_rouse_estimates.asset_id} = ${dim_assets_fleet_opt.asset_id} ;;
#   }

#   # Might need to make a spine of all like
#   # day 15 or 16? of each month
#   join: forecast_months {
#     from: dim_dates_fleet_opt
#     relationship: one_to_many
#     sql_on:
#     ${forecast_months.dt_day} = 15 AND
#     -- TODO: need to make sure all date diff calculations are around the 15th
#     ${forecast_months.date_month_start_date} BETWEEN DATE_TRUNC('MONTH',% parameter period_date_start_range._parameter_value %) AND DATE_TRUNC('MONTH', {% parameter period_date_end_range._parameter_value %})
#   ;;
#   }

#   # This is where the actual predicted depreciation / values will come from
#   join: forecast_residual_by_class {
#     from: test_residual_values_by_class
#     relationship: many_to_one
#     sql_on:
#     ${forecast_residual_by_class.equipment_class_id} = ${dim_assets_fleet_opt.equipment_class_id}
#     AND ${forecast_residual_by_class.months_old}
#       = ${dim_assets_fleet_opt.asset_age_from_purchase_in_months} + ${today.forecast_month_offset}
#   ;;
#   }


# }
