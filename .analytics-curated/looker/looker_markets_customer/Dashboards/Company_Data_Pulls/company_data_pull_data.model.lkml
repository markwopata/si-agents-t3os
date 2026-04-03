connection: "es_snowflake"

include: "/Dashboards/Company_Data_Pulls/views/company_on_off_rent_with_spend.view.lkml"
include: "/Dashboards/Company_Data_Pulls/views/lyondell_on_off_rent_with_spend.view.lkml"
include: "/Dashboards/Company_Data_Pulls/views/on_off_rent_with_spend.view.lkml"
include: "/Dashboards/Company_Data_Pulls/views/on_off_rent_with_spend_filters.view.lkml"

# explore: company_on_off_rent_with_spend {
#   view_name: company_on_off_rent_with_spend
#   group_label: "Rentals"
#   label: "Generic Company Spend By Rental"
#   hidden: yes
#   case_sensitive: no
#   description: "Used to pull data for industrial tools team to put together data for a given company"
# }

# creating extended explores for each view for better control
# explore: deer_park_on_off_rent_with_spend {
#   extends: [company_on_off_rent_with_spend]
#   group_label: "Rentals"
#   label: "Deer Park Spend By Rental"
#   case_sensitive: no
#   description: "Used to pull data for industrial tools team to put together data for Deer Park Refining"
#   sql_always_where: ${company_on_off_rent_with_spend.company_id} = 79314 ;;
# }

# explore: brown_root_on_off_rent_with_spend {
#   extends: [company_on_off_rent_with_spend]
#   group_label: "Rentals"
#   label: "Brown & Root Spend By Rental"
#   case_sensitive: no
#   description: "Used to pull data for industrial tools team to put together data for Brown & Root Industrial"
#   sql_always_where: ${company_on_off_rent_with_spend.company_id} = 9285 ;;
# }

# explore: lyondell_on_off_rent_with_spend {
#   view_name: lyondell_on_off_rent_with_spend
#   label: "Lyondell Chemical Spend By Rental"
#   case_sensitive: no
#   description: "Used to pull data for industrial tools team to put together data for Lyondell Chemical Company"
# }

explore: on_off_rent_with_spend {
  view_name: on_off_rent_with_spend
  label: "Generalized Company Spend By Rental"
  case_sensitive: no
  description: "Rental-level data for company-specific data pulls. Newest version as of 10-31-2024."
}

explore: on_off_rent_with_spend_filters {
  view_name: on_off_rent_with_spend_filters
  label: "On Off Rent With Spend Filters"
  case_sensitive: no
  persist_for: "10 hour"
  description: "Concatenated 'company_id - name' for every company. Cached for 10 hours."
}
