connection: "es_snowflake_analytics"

include: "/Dashboards/product_specialists/views/product_specialist_historical_revenue.view.lkml"
include: "/Dashboards/product_specialists/views/product_specialist_line_items.view.lkml"
include: "/Dashboards/product_specialists/views/product_specialist_list.view.lkml"
include: "/Dashboards/product_specialists/views/product_specialist_on_rent_rolling_90.view.lkml"
include: "/Dashboards/product_specialists/views/product_specialist_orders.view.lkml"
include: "/Dashboards/product_specialists/views/active_branch_rental_rates_pivot.view.lkml"
include: "/Dashboards/product_specialists/views/product_specialist_credit_apps.view.lkml"

include: "/views/ANALYTICS/market_region_salesperson.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/ANALYTICS/rateachievement_points.view.lkml"

include: "/views/custom_sql/approved_invoice_salespersons_flat.view.lkml"
include: "/views/custom_sql/companies_revenue_last_30_days.view.lkml"
include: "/views/custom_sql/companies_revenue_last_90_days.view.lkml"
include: "/views/custom_sql/credit_amount_summarized.view.lkml"

include: "/views/ES_WAREHOUSE/assets.view.lkml"
include: "/views/ES_WAREHOUSE/assets_aggregate.view.lkml"
include: "/views/ES_WAREHOUSE/companies.view.lkml"
include: "/views/ES_WAREHOUSE/equipment_assignments.view.lkml"
include: "/views/ES_WAREHOUSE/invoices.view.lkml"
include: "/views/ES_WAREHOUSE/line_item_types.view.lkml"
include: "/views/ES_WAREHOUSE/markets.view.lkml"
include: "/views/ES_WAREHOUSE/net_terms.view.lkml"
include: "/views/ES_WAREHOUSE/orders.view.lkml"
include: "/views/ES_WAREHOUSE/order_salespersons.view.lkml"
include: "/views/ES_WAREHOUSE/purchase_orders.view.lkml"
include: "/views/ES_WAREHOUSE/rentals.view.lkml"
include: "/views/ES_WAREHOUSE/rental_statuses.view.lkml"
include: "/views/ES_WAREHOUSE/sales_track_logins.view.lkml"
include: "/views/ES_WAREHOUSE/users.view.lkml"




explore: product_specialist_list {
  group_label: "Product Specialist Information"
  label: "Product Specialist Revenue"
  description: "Use this explore to look at invoices where product specialist are listed as a rep."
  case_sensitive: no
  sql_always_where:
  (
  ('salesperson' = {{ _user_attributes['department'] }} AND ${users.deleted} = 'No' AND ${users.email_address} =  LOWER('{{ _user_attributes['email'] }}'))
  )
  OR
  (
  ${users.user_id} = ${product_specialist_list.user_id}
  AND
  ('salesperson' != {{ _user_attributes['department'] }}
  AND
  ('developer' = {{ _user_attributes['department'] }}
  OR 'god view' = {{ _user_attributes['department'] }}
  OR 'managers' = {{ _user_attributes['department'] }}
  OR 'collectors' = {{ _user_attributes['department'] }})
  )
  )
  ;;

  join: approved_invoice_salespersons_flat {
    type: inner
    relationship: one_to_many
    sql_on: ${product_specialist_list.user_id} = ${approved_invoice_salespersons_flat.salesperson_id} and ${approved_invoice_salespersons_flat.salesperson_type} = 2 ;;
  }

  join: product_specialist_orders {
    type: left_outer
    relationship: one_to_many
    sql_on: ${product_specialist_list.user_id} = ${product_specialist_orders.user_id} and ${invoices.order_id} = ${product_specialist_orders.order_id};;
  }

  join: invoices {
    type: left_outer
    relationship: one_to_many
    sql_on: ${approved_invoice_salespersons_flat.invoice_id} = ${invoices.invoice_id} ;;
  }

 join: purchase_orders {
   type: left_outer
   relationship: one_to_many
   sql_on: ${invoices.purchase_order_id} = ${purchase_orders.purchase_order_id} ;;
 }



 join: product_specialist_line_items {
   view_label: "Line Items"
   type: left_outer
   relationship: one_to_many
   sql_on: ${invoices.invoice_id} = ${product_specialist_line_items.invoice_id} ;;
 }

join: line_item_types {
  type: left_outer
  relationship: many_to_one
  sql_on: ${product_specialist_line_items.line_item_type_id} = ${line_item_types.line_item_type_id} ;;
}

 join: users {
   type: left_outer
   relationship: one_to_one
   sql_on: ${product_specialist_list.user_id} = ${users.user_id} ;;
 }

join: market_region_xwalk {
  type: left_outer
  relationship: many_to_one
  sql_on: ${product_specialist_orders.market_id} = ${market_region_xwalk.market_id} ;;
}

 join: companies {
   type: left_outer
   relationship: many_to_one
   sql_on: ${invoices.company_id} = ${companies.company_id} ;;
 }

  join: net_terms {
    type: left_outer
    relationship: one_to_one
    sql_on: ${companies.net_terms_id} = ${net_terms.net_terms_id} ;;
  }

  join: credit_amount_summarized {
    type: left_outer
    relationship: many_to_one
    sql_on: ${credit_amount_summarized.company_id} = ${companies.company_id} ;;
  }
}

explore: product_specialist_asset_info {
  from: product_specialist_list
  group_label: "Product Specialist Information"
  label: "Product Specialist Assets"
  view_label: "Product Specialist List"
  description: "Use this explore to look at asset and rental information where product specialist are listed as a rep."
  case_sensitive: no
  always_join: [active_branch_rental_rates_pivot]
  sql_always_where: --((SUBSTR(TRIM(${assets.serial_number}), 1, 3) != 'RR-' and SUBSTR(TRIM(${assets.serial_number}), 1, 2) != 'RR') or ${assets.serial_number} is null)
  --AND
  --(
  (('collectors' = {{ _user_attributes['department'] }} OR 'salesperson' = {{ _user_attributes['department'] }} AND ${users.deleted} = 'No' AND ${users.email_address} =  '{{ _user_attributes['email'] }}' )) OR ${market_region_xwalk.District_Region_Market_Access}--)
  ;;

 join: product_specialist_orders {
   type: left_outer
   relationship: one_to_many
   sql_on: ${product_specialist_asset_info.user_id} = ${product_specialist_orders.user_id} ;;
 }

 join: orders {
   type: inner
   relationship: many_to_one
   sql_on: ${product_specialist_orders.order_id} = ${orders.order_id} ;;
 }

 join: rentals {
   type: inner
   relationship: many_to_one
   sql_on: ${rentals.order_id} = ${orders.order_id} ;;
 }

 join: rental_statuses {
   type: left_outer
   relationship: many_to_one
   sql_on: ${rentals.rental_status_id} = ${rental_statuses.rental_status_id} ;;
 }

 join: equipment_assignments {
   type: inner
   relationship: many_to_one
   sql_on: ${equipment_assignments.rental_id} = ${rentals.rental_id} ;;
 }

 join: assets {
   type: inner
   relationship: many_to_one
   sql_on: ${assets.asset_id} = ${equipment_assignments.asset_id} ;;
 }

 join: assets_aggregate {
   type: inner
   relationship: one_to_one
   sql_on: ${assets.asset_id} = ${assets_aggregate.asset_id} ;;
 }

 join: users {
   type: left_outer
   relationship: many_to_one
   sql_on: ${product_specialist_asset_info.user_id} = ${users.user_id} ;;
 }

 join: active_branch_rental_rates_pivot {
   type: left_outer
   relationship: one_to_one
   sql_on: ${orders.market_id} = ${active_branch_rental_rates_pivot.branch_id} and ${assets_aggregate.equipment_class_id} = ${active_branch_rental_rates_pivot.equipment_class_id} ;;
 }

 join: markets {
   type: left_outer
   relationship: many_to_one
   sql_on: ${markets.market_id} = ${orders.market_id} ;;
 }

 join: market_region_xwalk {
   type: left_outer
   relationship: one_to_one
   sql_on: ${market_region_xwalk.market_id} = ${markets.market_id} ;;
 }

 join: customer {
   from: users
   type: left_outer
   relationship: many_to_one
   sql_on: ${orders.user_id} = ${customer.user_id} ;;
 }

 join: companies {
   type: left_outer
   relationship: many_to_one
   sql_on: ${customer.company_id} = ${companies.company_id} ;;
 }

  join: sales_track_logins {
    type: left_outer
    relationship: many_to_one
    sql_on: ${companies.company_id} = ${sales_track_logins.company_id} ;;
  }
}

explore: product_specialist_historical_revenue {
  group_label: "Product Specialist Information"
  label: "Date Created vs. Invoice Approved Date"
  description: "Only use this explore if you are comparing invoice_approved_date to date_created_date data strictly for Product Specialists"
  case_sensitive: no
  sql_always_where:
  (
  ('salesperson' = {{ _user_attributes['department'] }} AND ${users.deleted} = 'No' AND ${users.email_address} =  LOWER('{{ _user_attributes['email'] }}'))
  )
  OR
  (
  ${users.user_id} = ${product_specialist_historical_revenue.user_id}
  AND
  ('salesperson' != {{ _user_attributes['department'] }}
  AND
  ('developer' = {{ _user_attributes['department'] }}
  OR 'god view' = {{ _user_attributes['department'] }}
  OR 'managers' = {{ _user_attributes['department'] }}
  OR 'collectors' = {{ _user_attributes['department'] }})
  )
  )
  ;;

  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: ${product_specialist_historical_revenue.user_id} = ${users.user_id} ;;
  }

  # join: market_region_salesperson {
  #   type: left_outer
  #   relationship: one_to_many
  #   sql_on: ${users.user_id} = ${market_region_salesperson.salesperson_user_id} ;;
  # }

  join: companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${product_specialist_historical_revenue.company_id} = ${companies.company_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${product_specialist_historical_revenue.market_id} = ${market_region_xwalk.market_id} ;;
  }
}

explore: product_specialist_rate_achievement {
  from: product_specialist_list
  group_label: "Product Specialist Information"
  view_label: "Product Specialist List"
  case_sensitive: no
  sql_always_where:
  ('salesperson' = {{ _user_attributes['department'] }}
  AND ${users.email_address} =  LOWER('{{ _user_attributes['email'] }}'))
  OR TRIM(LOWER('{{ _user_attributes['email'] }}')) = 'joyce.edwards@equipmentshare.com'
  OR 'developer' = {{ _user_attributes['department'] }}
  OR 'collectors' = {{ _user_attributes['department'] }}
  OR 'god view'= {{ _user_attributes['department'] }}
  ;;


  join: product_specialist_orders {
    type: left_outer
    relationship: one_to_many
    sql_on: ${product_specialist_rate_achievement.user_id} = ${product_specialist_orders.user_id} ;;
  }

  join: invoices {
    type: left_outer
    relationship: one_to_many
    sql_on: ${product_specialist_orders.order_id} = ${invoices.order_id} ;;
  }

  join: approved_invoice_salespersons_flat {
    type: inner
    relationship: one_to_many
    sql_on: ${invoices.invoice_id} = ${approved_invoice_salespersons_flat.invoice_id} and ${product_specialist_rate_achievement.user_id} = ${approved_invoice_salespersons_flat.salesperson_id} ;;
  }

  join: rateachievement_points {
    type: inner
    relationship: one_to_many
    sql_on: ${rateachievement_points.invoice_id} = ${approved_invoice_salespersons_flat.invoice_id};;
  }

  join: users {
    type: left_outer
    relationship: one_to_one
    sql_on: ${product_specialist_rate_achievement.user_id} = ${users.user_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rateachievement_points.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: companies_revenue_last_90_days {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rateachievement_points.company_id}=${companies_revenue_last_90_days.company_id} ;;
  }

  join: companies_revenue_last_30_days {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rateachievement_points.company_id}=${companies_revenue_last_30_days.company_id} ;;
  }

  # join: company_directory {
  #   type: inner
  #   relationship: one_to_one
  #   sql_on: ${users.employee_id}::number = ${company_directory.employee_id} ;;
  # }

  # join: market_region_xwalk_home_market {
  #   from:  market_region_xwalk
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${company_directory.market_id} = ${market_region_xwalk_home_market.market_id} ;;
  # }
}

# Commented out due to low usage on 2026-03-26
# explore: product_specialist_on_rent_rolling_90 {
#   group_label: "Product Specialist Information"
#   label: "Product Specialist On Rent Rolling 90 Days"
#   description: "This explore counts rentals for the specialist regardless of whether they are a primary or secondary rep."
#   case_sensitive: no
#   sql_always_where:
#   (
#   ('salesperson' = {{ _user_attributes['department'] }} AND ${users.deleted} = 'No' AND ${users.email_address} =  LOWER('{{ _user_attributes['email'] }}'))
#   )
#   OR
#   (
#   ${users.user_id} = ${product_specialist_list.user_id}
#   AND
#   ('salesperson' != {{ _user_attributes['department'] }}
#   AND
#   ('developer' = {{ _user_attributes['department'] }}
#   OR 'god view' = {{ _user_attributes['department'] }}
#   OR 'managers' = {{ _user_attributes['department'] }}
#   OR 'collectors' = {{ _user_attributes['department'] }})
#   )
#   );;
#
#   join: users {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${product_specialist_on_rent_rolling_90.user_id} = ${users.user_id} ;;
#   }
#
#   join: product_specialist_list {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${users.user_id} = ${product_specialist_list.user_id} ;;
#   }
#
#   join: market_region_xwalk {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${product_specialist_list.market_id} = ${market_region_xwalk.market_id} ;;
#   }
# }

explore: product_specialist_credit_apps {
  group_label: "Product Specialist Information"
  label: "Product Specialist Credit Apps"
  description: "Use this explore to look at new credit apps where product specialist are listed as a rep."
  case_sensitive: no
  sql_always_where:
  (
  ('salesperson' = {{ _user_attributes['department'] }} AND ${users.deleted} = 'No' AND ${users.email_address} =  LOWER('{{ _user_attributes['email'] }}'))
  )
  OR
  (
  ${users.user_id} = ${product_specialist_credit_apps.salesperson_user_id}
  AND
  ('salesperson' != {{ _user_attributes['department'] }}
  AND
  ('developer' = {{ _user_attributes['department'] }}
  OR 'god view' = {{ _user_attributes['department'] }}
  OR 'managers' = {{ _user_attributes['department'] }}
  OR 'collectors' = {{ _user_attributes['department'] }})
  )
  )
  ;;

  join: users {
    type: left_outer
    relationship: one_to_one
    sql_on: ${product_specialist_credit_apps.salesperson_user_id} = ${users.user_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: one_to_one
    sql_on: ${product_specialist_credit_apps.market_id} = ${market_region_xwalk.market_id} ;;
  }
}
