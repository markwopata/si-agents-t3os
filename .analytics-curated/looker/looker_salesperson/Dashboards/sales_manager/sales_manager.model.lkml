connection: "es_snowflake_analytics"

# include: "/Models/salesperson_master.model.lkml"

include: "/Dashboards/sales_manager/views/manager_access_hierarchy.view.lkml"
include: "/views/ANALYTICS/credit_app_master_list.view.lkml"
include: "/views/ES_WAREHOUSE/users.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/custom_sql/line_items_dates_combined.view.lkml"

# Commented out due to low usage on 2026-03-26
# explore: credit_app_master_list {
#   label: "Credit App Information for Sales Manager"
#   group_label: "Sales Manager"
#   always_join: [manager_access_hierarchy]
#   case_sensitive: no
#   sql_always_where: 'developer' = {{ _user_attributes['department'] }}
#     OR array_contains (TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')::VARIANT, ${manager_access_hierarchy.manager_array});;
#
#   join: manager_access_hierarchy {
#     type: left_outer
#     relationship: one_to_many
#     sql_on: ${manager_access_hierarchy.user_id} =  ${credit_app_master_list.salesperson_user_id};;
#   }
#
#   join: users {
#     type: left_outer
#     relationship: one_to_many
#     sql_on: ${users.user_id} = ${credit_app_master_list.salesperson_user_id} ;;
#   }
#
#   join: market_region_xwalk {
#     type: left_outer
#     relationship: one_to_many
#     sql_on: ${market_region_xwalk.market_id} = ${credit_app_master_list.market_id} ;;
#   }
# }

# explore: +orders {
#   group_label: "Sales Manager Information"
#   label: "Salesperson Order Information"
#   description: "Use this explore to view information on each Manager's sales team"
#   always_join: [manager_access_hierarchy]
#   sql_always_where: ('developer' = {{ _user_attributes['department'] }}
#       OR 'god view' = {{ _user_attributes['department'] }})
#       OR array_contains (TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')::VARIANT, ${manager_access_hierarchy.manager_array}) ;;


#   join: manager_access_hierarchy {
#     relationship: many_to_one
#     sql_on: ${manager_access_hierarchy.user_id} = ${orders.user_id} ;;
#   }

# }

# explore:  {}
