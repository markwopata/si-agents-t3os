connection: "es_snowflake_analytics"

include: "/views/FLEET_OPTIMIZATION/dim_assets_fleet_opt.view.lkml"
include: "/views/DATA_SCIENCE/current_residual_values_by_class.view.lkml"
# include: "/views/DATA_SCIENCE/all_equipment_rouse_estimates.view.lkml"
include: "/views/DATA_SCIENCE/all_equipment_rouse_estimates_new.view.lkml"
# TODO -- check the dates. how often does rouse update. how often does dim assets update.
# and then do the persist for
# TODO -- switch residual to the current residual table!


explore: dim_assets_fleet_opt {
  label: "Residual Value Forecasting"
  case_sensitive: no
  # persist_for: "24 hours"

  join: today {
    from: current_residual_values_by_class
    relationship: many_to_one
    type: left_outer
    sql_on: ${today.months_old} = ${dim_assets_fleet_opt.asset_age_from_purchase_in_months}
    AND
    ${today.equipment_class_id} = TRY_CAST(${dim_assets_fleet_opt.equipment_class_id} AS INTEGER);;
  }

  join: end_period {
    from: current_residual_values_by_class
    relationship: many_to_one
    type: left_outer
    sql_on:
    -- ${end_period.equipment_class_id} = ${today.equipment_class_id} AND
    ${end_period.equipment_class_id} = TRY_CAST(${dim_assets_fleet_opt.equipment_class_id} AS INTEGER) AND
    ${end_period.months_old} =
      ${dim_assets_fleet_opt.asset_age_from_purchase_in_months}
      + DATEDIFF(
          MONTH,
          CURRENT_DATE(),
          {% parameter period_end_date._parameter_value %}
        )
    ;;
  }

  join: all_equipment_rouse_estimates_new {
    relationship: one_to_one
    type: left_outer
    sql_on: ${all_equipment_rouse_estimates_new.asset_id} = ${dim_assets_fleet_opt.asset_id} ;;
  }

  # join: all_equipment_rouse_estimates {
  #   relationship: one_to_one
  #   type: left_outer
  #   sql_on: ${all_equipment_rouse_estimates.asset_id} = ${dim_assets_fleet_opt.asset_id} ;;
  # }

}
