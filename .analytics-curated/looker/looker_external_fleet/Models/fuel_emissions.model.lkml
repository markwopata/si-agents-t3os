connection: "es_warehouse"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project
include: "/**/*.view.lkml"                 # include all views in this project

explore: fuel_emissions {
  label: "Fuel Emissions"
  description: "Emissions by date/rental/asset from BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__BY_DAY_UTILIZATION"
}

explore: fuel_emissions_aggregate {
  label: "Fuel Emissions Aggregate"
  description: "Emissions by asset from BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__BY_DAY_UTILIZATION"
}
