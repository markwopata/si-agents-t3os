connection: "es_snowflake_c_analytics"

 include: "/Dashboards/Rates/commission_below_floor/views/commissions_below_floor.view.lkml"                # include all views in the views/ folder in this project
 #include: "/**/*.view.lkml"                 # include all views in this project
 #include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard

explore: commissions_below_floor {
  from: commissions_below_floor
}
