connection: "es_snowflake_analytics"

label: "Commissions"

# include the view first
include: "/dashboards/commission_investigation/branch_rental_rates_historical.view.lkml"

# include the explore
include: "/dashboards/commission_investigation/branch_rental_rates_historical.explore.lkml"
