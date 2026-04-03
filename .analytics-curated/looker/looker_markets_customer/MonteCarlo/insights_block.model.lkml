connection: "es_snowflake"

include: "/MonteCarlo/*.view.lkml"                # include all views in the views/ folder in this project
# include: "/**/*.view.lkml"                 # include all views in this project
include: "*.dashboard.lookml"   # include a LookML dashboard called my_dashboard

explore: insight_events {
  group_label: "Monte Carlo"
}
