connection: "es_snowflake_analytics"

# include: "/Dashboards/salesperson/*.view.lkml"
# include: "/Dashboards/salesperson/views/*.view.lkml"
# include: "/views/ES_WAREHOUSE/users.view.lkml"


# explore: salesperson {
#   group_label: "Salesperson Dashboard"
#   from: salesperson_info
# }


# explore: salesperson_on_rent {
# group_label: "Salesperson Dashboard"
# label: "On Rent Information by Salesperson - Testing"
# extends: [salesperson]

#   join: on_rent {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${salesperson_on_rent.salesperson_user_id} = ${on_rent.salesperson_user_id};;
#   }
# }

# explore: salesperson_customers {
#   group_label: "Salesperson Dashboard"
#   label: "Customer Information by Salesperson - Testing"
#   extends: [salesperson]

#   join: new_customers {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${salesperson_customers.salesperson_user_id} = ${new_customers.salesperson_user_id} ;;
#   }
# }

# explore: salesperson_revenue {
#   group_label: "Salesperson Dashboard"
#   label: "Revenue Information by Salesperson - Testing"
#   extends: [salesperson]

#   join: revenue {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${salesperson_revenue.salesperson_user_id} = ${revenue.salesperson_user_id} ;;
#   }
# }

# explore: salesperson_rateachievement {
#   group_label: "Salesperson Dashboard"
#   label: "Rate Achievement Information by Salesperson - Testing"
#   extends: [salesperson]

#   join: rateachievement {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${salesperson_rateachievement.salesperson_user_id} = ${rateachievement.salesperson_user_id} ;;
#   }
# }

# TODO
# explore: salesperson_ar {
#   group_label: "Salesperson Dashboard"
#   label: "AR Information by Salesperson - Testing"
#   extends: [salesperson]

# }
