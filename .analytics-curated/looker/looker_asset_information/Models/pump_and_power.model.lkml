connection: "es_snowflake_analytics"

#MB commented out 5/23/24 explore returned unused or tied to old dashboard
# include: "/views/ES_WAREHOUSE/assets.view.lkml"
# include: "/views/ES_WAREHOUSE/asset_purchase_history.view.lkml"
# include: "/views/ES_WAREHOUSE/asset_statuses.view.lkml"
# include: "/views/ES_WAREHOUSE/categories.view.lkml"
# include: "/views/ES_WAREHOUSE/equipment_classes.view.lkml"
# include: "/views/ES_WAREHOUSE/equipment_classes_models_xref.view.lkml"
# include: "/views/ES_WAREHOUSE/equipment_models.view.lkml"
# include: "/views/ES_WAREHOUSE/invoices.view.lkml"
# include: "/views/ES_WAREHOUSE/line_items.view.lkml"
# include: "/views/ES_WAREHOUSE/markets.view.lkml"
# include: "/views/ES_WAREHOUSE/orders.view.lkml"
# include: "/views/ES_WAREHOUSE/rentals.view.lkml"
# include: "/views/ES_WAREHOUSE/users.view.lkml"
# include: "/views/ES_WAREHOUSE/companies.view.lkml"
# include: "/views/ES_WAREHOUSE/asset_status_key_values.view.lkml"
# include: "/views/ES_WAREHOUSE/order_salespersons.view.lkml"
# include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
# include: "/views/custom_sql/asset_purchase_history_facts.view.lkml"
# include: "/views/custom_sql/pump_and_power_assets_past_90_rentals.view.lkml"

# # datagroup: 6AM_update {
# #   sql_trigger: SELECT FLOOR((DATE_PART('EPOCH_SECOND', CURRENT_TIMESTAMP) - 60*60*12)/(60*60*24)) ;;
# #   max_cache_age: "24 hours"
# # }

# # datagroup: Every_Hour_Update {
# #   sql_trigger: SELECT HOUR(CURRENT_TIME()) ;;
# #   max_cache_age: "1 hour"
# # }

# # datagroup: Every_Two_Hours_Update {
# #   sql_trigger: SELECT FLOOR(DATE_PART('EPOCH_SECOND', CURRENT_TIMESTAMP) / (2*60*60)) ;;
# #   max_cache_age: "2 hours"
# # }

# # datagroup: Every_5_Min_Update {
# #   sql_trigger: SELECT DATE_PART('minute', CURRENT_TIMESTAMP) ;;
# #   max_cache_age: "5 minutes"
# # }

# #Showing assets rented last 90 days for pump and power rentals
# explore: pump_and_power_assets_past_90_rentals {
#   group_label: "Pump & Power Information"
# }

# #Showing just the pump and power equipment classes
# explore: pump_and_power_equipment_classes {
#   from: equipment_classes
#   group_label: "Pump & Power Information"
#   label: "Pump & Power Equipment Class List"
#   sql_always_where: ${company_division_id} = 2 ;;
# }

# # 2022-01-06 Removed company_division_id restrictions for orders as no longer relevent at request of Advanced Solutions as
# # intemediary until revenue dashboard by market type is complete - Britt Shanklin
# # https://app.shortcut.com/businessanalytics/story/213907/update-to-p-p-dashboard-frank-borges

# #Pump and Power classes only information
# explore: orders_pump_and_power_equipment_classes {
#   from: orders
#   group_label: "Pump & Power Information"
#   label: "Pump & Power Assets"
#   case_sensitive: no
#   #sql_always_where: ${equipment_classes.company_division_id} = 2 ;;

#   join: order_salespersons {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${orders_pump_and_power_equipment_classes.order_id} = ${order_salespersons.order_id} ;;
#   }

#   join: rentals {
#     type:  inner
#     relationship:  many_to_one
#     sql_on: ${orders_pump_and_power_equipment_classes.order_id} = ${rentals.order_id} ;;
#   }

#   join: invoices {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${orders_pump_and_power_equipment_classes.order_id} = ${invoices.order_id} ;;
#   }

#   join: line_items {
#     type: left_outer
#     relationship: one_to_many
#     sql_on: ${invoices.invoice_id} = ${line_items.invoice_id} ;;
#   }

#   join: assets {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${rentals.asset_id} = ${assets.asset_id} and ${line_items.asset_id} = ${assets.asset_id} ;;
#   }

#   # join: asset_statuses {
#   #   sql_table_name: ES_WAREHOUSE.PUBLIC.asset_statuses ;;
#   #   type:  left_outer
#   #   relationship: one_to_one
#   #   sql_on: ${assets.asset_id} = ${asset_statuses.asset_id} ;;
#   # }

#   join: asset_status_key_values {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${asset_status_key_values.asset_id} = ${assets.asset_id} ;;
#   }

#   join: asset_purchase_history_facts_final {
#     type:  left_outer
#     relationship:  one_to_one
#     sql_on: ${assets.asset_id} = ${asset_purchase_history_facts_final.asset_id} ;;
#   }

#   join: markets {
#     type: left_outer
#     relationship: one_to_many
#     sql_on: ${markets.market_id} = ${orders_pump_and_power_equipment_classes.market_id};;
#   }

#   join: users {
#     view_label: "Salesperson"
#     type: left_outer
#     relationship: many_to_one
#     sql_on: coalesce(${order_salespersons.user_id},${orders_pump_and_power_equipment_classes.salesperson_user_id}) = ${users.user_id} ;;
#   }

#   join: customer {
#     from: users
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${orders_pump_and_power_equipment_classes.user_id} = ${customer.user_id} ;;
#   }

#   join: companies {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${customer.company_id} = ${companies.company_id} ;;
#   }

#   join: market_region_xwalk {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${markets.market_id} = ${market_region_xwalk.market_id} ;;
#   }

#   join: equipment_models {
#     type: left_outer
#     relationship: many_to_many
#     sql_on: ${equipment_models.equipment_model_id} = ${assets.equipment_model_id} ;;
#   }

#   join: equipment_classes_models_xref {
#     type: left_outer
#     relationship: many_to_many
#     sql_on: ${equipment_models.equipment_model_id} = ${equipment_classes_models_xref.equipment_model_id} ;;
#   }

#   join: equipment_classes {
#     type: inner
#     relationship: many_to_one
#     sql_on: ${equipment_classes.equipment_class_id} = ${equipment_classes_models_xref.equipment_class_id} ;;
#   }

#   join: categories {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${assets.category_id} = ${categories.category_id} ;;
#   }

#   join: sub_category {
#     sql_where: ${sub_category.parent_category_id} is null ;;
#     from: categories
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${categories.parent_category_id} = ${sub_category.category_id} and ${categories.category_id} = ${assets.category_id} ;;
#   }

#   join: asset_purchase_history {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${asset_purchase_history.asset_id} = ${assets.asset_id} ;;
#   }
# }

# #Fuel Info for Pump and Power
# explore: orders_fuel_pump_and_power_equipment_classes {
#   from: orders
#   group_label: "Pump & Power Information"
#   label: "Fuel Information"
#   case_sensitive: no
#   sql_always_where: ((${line_items.line_item_type_id} in (2,7,16)) OR (${line_items.line_item_type_id} = 5 AND ${line_items.description} like '%Fuel Delivery%')) ;;

#   join: order_salespersons {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${orders_fuel_pump_and_power_equipment_classes.order_id} = ${order_salespersons.order_id} ;;
#   }

#   join: rentals {
#     type:  inner
#     relationship:  many_to_one
#     sql_on: ${orders_fuel_pump_and_power_equipment_classes.order_id} = ${rentals.order_id} ;;
#   }

#   join: invoices {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${orders_fuel_pump_and_power_equipment_classes.order_id} = ${invoices.order_id} ;;
#   }

#   join: line_items {
#     type: left_outer
#     relationship: one_to_many
#     sql_on: ${invoices.invoice_id} = ${line_items.invoice_id} ;;
#   }

#   join: assets {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${rentals.asset_id} = ${assets.asset_id} ;;
#   }

#   # join: asset_statuses {
#   #   sql_table_name: ES_WAREHOUSE.PUBLIC.asset_statuses ;;
#   #   type:  left_outer
#   #   relationship: one_to_one
#   #   sql_on: ${assets.asset_id} = ${asset_statuses.asset_id} ;;
#   # }

#   join: asset_status_key_values {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${asset_status_key_values.asset_id} = ${assets.asset_id} ;;
#   }

#   join: asset_purchase_history {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${asset_purchase_history.asset_id} = ${assets.asset_id} ;;
#   }

#   join: asset_purchase_history_facts_final {
#     type:  left_outer
#     relationship:  one_to_one
#     sql_on: ${assets.asset_id} = ${asset_purchase_history_facts_final.asset_id} ;;
#   }

#   join: markets {
#     type: left_outer
#     relationship: one_to_many
#     sql_on: ${markets.market_id} = ${orders_fuel_pump_and_power_equipment_classes.market_id};;
#   }

#   join: users {
#     view_label: "Salesperson"
#     type: left_outer
#     relationship: many_to_one
#     sql_on: coalesce(${order_salespersons.user_id},${orders_fuel_pump_and_power_equipment_classes.salesperson_user_id}) = ${users.user_id} ;;
#   }

#   join: customer {
#     from: users
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${orders_fuel_pump_and_power_equipment_classes.user_id} = ${customer.user_id} ;;
#   }

#   join: companies {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${customer.company_id} = ${companies.company_id} ;;
#   }

#   join: market_region_xwalk {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${markets.market_id} = ${market_region_xwalk.market_id} ;;
#   }

#   join: equipment_models {
#     type: left_outer
#     relationship: many_to_many
#     sql_on: ${equipment_models.equipment_model_id} = ${assets.equipment_model_id} ;;
#   }

#   join: equipment_classes_models_xref {
#     type: left_outer
#     relationship: many_to_many
#     sql_on: ${equipment_models.equipment_model_id} = ${equipment_classes_models_xref.equipment_model_id} ;;
#   }

#   join: equipment_classes {
#     type: inner
#     relationship: many_to_one
#     sql_on: ${equipment_classes.equipment_class_id} = ${equipment_classes_models_xref.equipment_class_id} ;;
#   }

#   join: categories {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${assets.category_id} = ${categories.category_id} ;;
#   }

#   join: sub_category {
#     sql_where: ${sub_category.parent_category_id} is null ;;
#     from: categories
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${categories.parent_category_id} = ${sub_category.category_id} and ${categories.category_id} = ${assets.category_id} ;;
#   }
# }

# explore: orders_pump_and_power_reservations {
#   from: orders
#   group_label: "Pump & Power Information"
#   label: "Pump & Power Reservation Board"
#   case_sensitive: no

#   join: order_salespersons {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${orders_pump_and_power_reservations.order_id} = ${order_salespersons.order_id} ;;
#   }

#   join: rentals {
#     type:  inner
#     relationship:  many_to_one
#     sql_on: ${orders_pump_and_power_reservations.order_id} = ${rentals.order_id} ;;
#   }

#   join: assets {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${rentals.asset_id} = ${assets.asset_id} ;;
#   }

#   # join: asset_statuses {
#   #   sql_table_name: ES_WAREHOUSE.PUBLIC.asset_statuses ;;
#   #   type:  left_outer
#   #   relationship: one_to_one
#   #   sql_on: ${assets.asset_id} = ${asset_statuses.asset_id} ;;
#   # }

#   join: asset_status_key_values {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${asset_status_key_values.asset_id} = ${assets.asset_id} ;;
#   }

#   join: asset_purchase_history_facts_final {
#     type:  left_outer
#     relationship:  one_to_one
#     sql_on: ${assets.asset_id} = ${asset_purchase_history_facts_final.asset_id} ;;
#   }

#   join: markets {
#     type: left_outer
#     relationship: one_to_many
#     sql_on: ${markets.market_id} = ${orders_pump_and_power_reservations.market_id} ;;
#   }

#   join: users {
#     view_label: "Salesperson"
#     type: left_outer
#     relationship: many_to_one
#     sql_on: coalesce(${order_salespersons.user_id},${orders_pump_and_power_reservations.salesperson_user_id}) = ${users.user_id} ;;
#   }

#   join: customer {
#     from: users
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${orders_pump_and_power_reservations.user_id} = ${customer.user_id} ;;
#   }

#   join: companies {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${customer.company_id} = ${companies.company_id} ;;
#   }

#   join: market_region_xwalk {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${markets.market_id} = ${market_region_xwalk.market_id} ;;
#   }

#   join: equipment_classes {
#     type: inner
#     relationship: many_to_one
#     sql_on: ${rentals.equipment_class_id} = ${equipment_classes.equipment_class_id} ;;
#   }

#   join: asset_purchase_history {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${asset_purchase_history.asset_id} = ${assets.asset_id} ;;
#   }

# }
