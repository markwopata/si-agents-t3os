connection: "es_snowflake_pa_c_analytics"

include: "*.view.lkml"

explore: commission_plan_wd_alignment {
  label: "Commission Plan WD Alignment"
  description: "Compare Workday commission plan dates against ECI salesperson dates."
}

explore: commission_plan_wd_data_load {
  label: "Commission Plan WD Data Load"
  description: "Workday compensation plan event detail."
}
