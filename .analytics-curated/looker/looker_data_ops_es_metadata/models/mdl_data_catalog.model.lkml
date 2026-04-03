connection: "snowflake_dataops"

#include: "/views/VW_SNOWFLAKE_DATABASE.view.lkml"                # include all views in the views/ folder in this project
# include: "/**/*.view.lkml"                 # include all views in this project
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard

# # Select the views that should be a part of this model,
# # and define the joins that connect them together.

#explore: EXP_SNOWFLAKE_DATABASE {
#  from: VW_SNOWFLAKE_DATABASE
#  fields: [
#    ALL_FIELDS*
#  ]
#  always_filter: {
#    filters: [VW_DATABASE.DELETED : "-NULL"]
#  }
#}
