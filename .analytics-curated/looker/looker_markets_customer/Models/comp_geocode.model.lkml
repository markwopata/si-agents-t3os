connection: "es_snowflake_analytics"

# include: "/views/custom_sql/comp_geocode_miles.view.lkml"
# include: "/views/custom_sql/comp_geocode_address.view.lkml"

#MB commented out 5/23/24 explore returned unused or tied to old dashboard
# explore: comp_geocode_miles {
#   case_sensitive: no
#   persist_for: "2 minutes"

#   }


# explore: comp_geocode_address { --MB comment out 10-10-23 due to inactivity
#   case_sensitive: no
#   persist_for: "2 minutes"

# }
