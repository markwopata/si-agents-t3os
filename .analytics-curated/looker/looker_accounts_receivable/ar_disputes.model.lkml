connection: "es_snowflake_c_analytics"

include: "/**/**.view.lkml"                # include all views in the views/ folder in this project
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

explore: obt_disputes {
  label: "obt_disputes"
  sql_always_where: ${market_region_xwalk.District_Region_Market_Access}
  or 'developer' = {{ _user_attributes['department'] }}
  or 'admin' = {{ _user_attributes['department'] }}
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'jabbok@equipmentshare.com';;

  join: market_region_xwalk {
  type: left_outer
  relationship: many_to_one
  sql_on: ${obt_disputes.branch_id} = ${market_region_xwalk.market_id}::varchar ;;
}
}


explore: obt_credit_invoices_memos {
  label: "obt_credit_invoices_memos"

  sql_always_where: ${market_region_xwalk.District_Region_Market_Access}
  or 'developer' = {{ _user_attributes['department'] }}
  or 'admin' = {{ _user_attributes['department'] }}
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'jabbok@equipmentshare.com';;

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${obt_credit_invoices_memos.market_id} = ${market_region_xwalk.market_id}::varchar ;;

}
}


explore: obt_customer_invoices_credit_memos {
  label: "obt_customer_invoices_credit_memos"
  sql_always_where: ${market_region_xwalk.District_Region_Market_Access}
  or 'developer' = {{ _user_attributes['department'] }}
  or 'admin' = {{ _user_attributes['department'] }}
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'jabbok@equipmentshare.com';;

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${obt_customer_invoices_credit_memos.market_id} = ${market_region_xwalk.market_id}::varchar ;;

  }
}
