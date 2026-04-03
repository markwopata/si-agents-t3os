connection: "es_snowflake_analytics"

#MB commented out 5/23/24 explore returned unused or tied to old dashboard
# include: "/Dashboards/Negotiated_Rates_by_Customer/Views/company_rental_rates.view.lkml"
# # include: "/Dashboards/Negotiated_Rates_by_Customer/Views/company_rental_rates_extends.view.lkml"

# include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
# # include: "/views/ES_WAREHOUSE/markets.view.lkml"
# include: "/views/ES_WAREHOUSE/companies.view.lkml"
# include: "/views/ES_WAREHOUSE/branch_rental_rates.view.lkml"
# include: "/views/ES_WAREHOUSE/equipment_classes.view.lkml"

# # to incorporate rental rates from orders
# include: "/views/ES_WAREHOUSE/line_items.view.lkml"
# include: "/views/ES_WAREHOUSE/rentals.view.lkml"
# include: "/views/ES_WAREHOUSE/orders.view.lkml"
# include: "/views/ES_WAREHOUSE/deliveries.view.lkml"
# include: "/views/ES_WAREHOUSE/locations.view.lkml"
# include: "/views/ES_WAREHOUSE/invoices.view.lkml"

# include: "/views/ANALYTICS/rateachievement_points.view.lkml"
# include: "/views/ES_WAREHOUSE/users.view.lkml"


# explore: company_rental_rates {
#   view_name: company_rental_rates
#   label: "Negotiated Rates by Customer"
#   case_sensitive: no
#   sql_always_where: NOT(${voided}) and ${branch_rental_rates.active} and ${branch_rental_rates.rate_type_name} = 'Benchmark'
#                     and NOT(${equipment_classes.deleted});;

#   join: branch_rental_rates {
#     relationship: many_to_many
#     type: left_outer
#     sql_on: ${company_rental_rates.equipment_class_id} = ${branch_rental_rates.equipment_class_id} ;;
#   }

#   join: market_region_xwalk {
#     relationship: many_to_one
#     sql_on: ${branch_rental_rates.branch_id} = ${market_region_xwalk.market_id} ;;
#   }

#   join: equipment_classes {
#     relationship: many_to_one
#     type: left_outer
#     sql_on: ${company_rental_rates.equipment_class_id} = ${equipment_classes.equipment_class_id} ;;
#   }

#   join: companies {
#     relationship: one_to_many
#     sql_on: ${company_rental_rates.company_id} = ${companies.company_id} ;;
#   }
# }

# explore: company_rental_rates_w_orders {
#   extends: [company_rental_rates]
#   label: "Negotiated Rates by Customer - w Orders"
#   sql_always_where: NOT(${voided}) and ${branch_rental_rates.active}
#                     and NOT(${equipment_classes.deleted}) ;;

#   join: rateachievement_points {
#     relationship: many_to_many
#     type: full_outer
#     sql_on: ${company_rental_rates.company_id} = ${rateachievement_points.company_id} and ${branch_rental_rates.branch_id} = ${rateachievement_points.market_id}
#             and ${equipment_classes.equipment_class_id} = ${rateachievement_points.new_class_id};;
#   }

#   join: users {
#     relationship: many_to_one
#     sql_on: ${rateachievement_points.salesperson_user_id} = ${users.user_id} ;;
#   }

# }
