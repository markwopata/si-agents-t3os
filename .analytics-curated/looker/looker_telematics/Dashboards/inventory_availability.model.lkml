connection: "es_snowflake_analytics"

# include: "/Dashboards/Inventory_Availabliity/views/inventory_availability.view.lkml"              # include all views in the views/ folder in this project
# include: "/Dashboards/Inventory_Availabliity/views/product_category.view.lkml"
# include: "/Dashboards/Inventory_Availabliity/views/inventory_valuation.view.lkml"
# include: "/Dashboards/Inventory_Availabliity/views/vendors.view.lkml"

# MB commented out unused explore on 5/22/24
# explore: telematics_inventory_availability {
#   from: inventory_availability
#   case_sensitive: no

#   join: product_category {
#     type: left_outer
#     relationship: one_to_many
#     sql_on: ${telematics_inventory_availability.part} = ${product_category.part} ;;
#   }

#   join: inventory_valuation  {
#     type: left_outer
#     relationship: one_to_many
#     sql_on: ${telematics_inventory_availability.part} = ${inventory_valuation.part} ;;
#   }

#   join: vendors {
#     type: left_outer
#     relationship: many_to_many
#     sql_on: ${inventory_valuation.partid} = ${vendors.partid} ;;
#   }

# }
