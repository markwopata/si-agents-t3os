connection: "es_snowflake_c_analytics"


include: "/Dashboards/Deal_Rate_Activity/views/*.view.lkml"
# include: "/views/*.view.lkml"                # include all views in the views/ folder in this project
# include: "/**/*.view.lkml"                 # include all views in this project
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard

# # Select the views that should be a part of this model,
# # and define the joins that connect them together.
#
explore: district_oec {
    case_sensitive: no
    label: "Deal Rate Activity"
    description: "Use this explore for pulling deal rate activity by region and district"
    fields: [ALL_FIELDS*
    ]
}
