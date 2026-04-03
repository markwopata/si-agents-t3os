connection: "es_snowflake_analytics"

include: "/Dashboards/Rates/Dozr_Commissions/views/*.view.lkml"               # include all views in the views/ folder in this project

explore: adjusted_rate_calculations {
  from: adjusted_rate_calculations
}
