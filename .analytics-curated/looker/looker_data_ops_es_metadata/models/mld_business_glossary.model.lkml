connection: "snowflake_dataops"

#include: "/views/VW_BUSINESS_GLOSSARY.view.lkml"                # include all views in the views/ folder in this project


#explore: EXP_BUSINESS_GLOSSARY_TERM {
#  from: VW_BUSINESS_GLOSSARY_TERM
#  fields: [
#    ALL_FIELDS*
#  ]
#}

#explore: EXP_BUSINESS_GLOSSARY_TERM_REFERENCE {
#  from: VW_BUSINESS_GLOSSARY_TERM_REFERENCE
#  fields: [
#    ALL_FIELDS*
#  ]
#}







#   join: orders {
#     relationship: many_to_one
#     sql_on: ${orders.id} = ${order_items.order_id} ;;
#   }


# include: "/**/*.view.lkml"                 # include all views in this project
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard

# # Select the views that should be a part of this model,
# # and define the joins that connect them together.
#
# explore: order_items {
#   join: orders {
#     relationship: many_to_one
#     sql_on: ${orders.id} = ${order_items.order_id} ;;
#   }
#
#   join: users {
#     relationship: many_to_one
#     sql_on: ${users.id} = ${orders.user_id} ;;
#   }
# }
