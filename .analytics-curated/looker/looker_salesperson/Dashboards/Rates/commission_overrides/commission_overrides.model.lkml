connection: "es_snowflake_analytics"


include: "/Dashboards/Rates/commission_overrides/views/*.lkml"
include: "/views/ES_WAREHOUSE/equipment_classes.view.lkml"
include: "/views/ES_WAREHOUSE/users.view.lkml"
include: "/views/custom_sql/floor_rates_by_district.view.lkml"
# include: "/views/*.view.lkml"                # include all views in the views/ folder in this project
# include: "/**/*.view.lkml"                 # include all views in this project
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard

# # Select the views that should be a part of this model,
# # and define the joins that connect them together.
#
explore: commission_overrides {
  sql_always_where: ${commission_overrides.District_Region_Market_Access}
  or 'developer' = {{ _user_attributes['department'] }}
  or 'admin' = {{ _user_attributes['department'] }}
  or 'god view'= {{ _user_attributes['department'] }}
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'jabbok@equipmentshare.com';;
  # join: orders {
  #   relationship: many_to_one
  #   sql_on: ${orders.id} = ${order_items.order_id} ;;


#equipment_classes
  join: equipment_classes {
    type: left_outer
    relationship: many_to_one
    sql_on: ${equipment_classes.equipment_class_id}=${commission_overrides.equipment_class_id} ;;
  }

  join: floor_rates_by_district {
    type: left_outer
    relationship: many_to_one
    sql_on: ${commission_overrides.equipment_class_id} = ${floor_rates_by_district.equipment_class_id}
      and ${commission_overrides.district} = ${floor_rates_by_district.district};;
  }

  join: users {
    type: left_outer
    relationship: one_to_one
    sql_on: ${commission_overrides.deal_rate_created_by} = ${users.email_address} ;;
  }
  }
#
#   join: users {
#     relationship: many_to_one
#     sql_on: ${users.id} = ${orders.user_id} ;;
#   }
# }
