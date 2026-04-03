connection: "es_snowflake"

# include: "/robotics_logs.view.lkml"
# include: "/test_rpm.view.lkml"


# # We don't use datagroups or PDTs (persistent derived tables) in Looker anymore now that Snowflake is able to handle it

# # datagroup: robotics_default_datagroup {
# #   # sql_trigger: SELECT MAX(id) FROM etl_log;;
# #   max_cache_age: "1 hour"
# # }

# # persist_with: robotics_default_datagroup

# explore: robotics_logs {
# }

# explore: test_rpm {
# }
