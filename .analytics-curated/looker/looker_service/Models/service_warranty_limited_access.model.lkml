connection: "es_snowflake_analytics"

include: "/views/custom_sql/warranty_invoices.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/ES_WAREHOUSE/invoices.view.lkml"
include: "/views/ES_WAREHOUSE/assets.view.lkml"
include: "/views/ANALYTICS/warranty_invoices.view.lkml"
include: "/views/ANALYTICS/warranty.view.lkml"
include: "/views/ES_WAREHOUSE/users.view.lkml"
include: "/views/ANALYTICS/paycor_employees_managers_full_hierarchy.view.lkml"
include: "/views/ES_WAREHOUSE/companies.view.lkml"
include: "/views/custom_sql/warranty_admin_reviewed_work_orders.view.lkml"
include: "/views/WORK_ORDERS/work_orders.view.lkml"
include: "/views/ES_WAREHOUSE/assets_aggregate.view.lkml"

explore: warranty_admin_reviewed_work_orders {
  case_sensitive: no

join: work_orders {
  type: inner
  relationship: one_to_one
  sql_on: ${work_orders.work_order_id} = ${warranty_admin_reviewed_work_orders.work_order_id} ;;
}

join: assets_aggregate {
  type: left_outer
  relationship: many_to_one
  sql_on: ${assets_aggregate.asset_id} = ${work_orders.asset_id} ;;
}

join: market_region_xwalk {
  type: inner
  relationship: many_to_one
  sql_on: ${market_region_xwalk.market_id} = ${work_orders.branch_id} ;;
}
}

explore: invoices {
  group_label: "Invoice Information"
  label: "Pulling Warranty Info Service Project - Limited Access"
  case_sensitive: no
 # sql_always_where: (
 # --('{{ _user_attributes['email'] }}' = 'lacey.dorsett@equipmentshare.com'
 # --OR TRIM(LOWER(${users.email_address})) =  TRIM(LOWER('{{ _user_attributes['email'] }}'))
 # --OR 'developer' = {{ _user_attributes['department'] }}
 #  ${assets.asset_id} in ${warranty_invoice_asset_info.asset_id});;
 # MB commenting out 1/17/2023
 # sql_always_where: ${warranty_invoice_asset_info.formatted_invoice_no} in ${warranty_invoices.invoice_number} ;;

 # MB changing to inner join 1/17/2023
  join: warranty_invoice_asset_info {
    type: inner
    relationship: many_to_one
    sql_on: ${invoices.invoice_id} = ${warranty_invoice_asset_info.invoice_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: one_to_one
    sql_on: ${market_region_xwalk.market_id} = ${warranty_invoice_asset_info.branch_id}  ;;
  }

  join: assets {
    type:  left_outer
    relationship: many_to_one
    sql_on:  ${warranty_invoice_asset_info.asset_id} = ${assets.asset_id} ;;
  }

  join: warranty_invoices {
    type: full_outer
    relationship: one_to_one
    sql_on: ${warranty_invoice_asset_info.work_order_id} = ${warranty_invoices.work_order_number} ;;
  }

  join: warranty {
    type: left_outer
    relationship: one_to_one
    sql_on: ${warranty_invoice_asset_info.formatted_invoice_no} = ${warranty.invoice_number} ;;
  }

  join: users {
    type: inner
    relationship: one_to_one
    sql_on: ${invoices.created_by_user_id} = ${users.user_id} ;;
    # removed user list because user list is in the warranty asset info code now as a flag for "warranty team created" 03/19/23 -TA
    # sql_where: ${users.user_id} in (61693, 48103, 6659, 15921, 20708, 17054, 47242,
    # 49343, 62759, 20731, 20148, 125940, 126240, 27185, 24662, 187372, 190426, 15919, 28868, 28006, 206519, 210771, 210772, 108119) ;;
  }

  join: paycor_employees_managers_full_hierarchy {
    type: left_outer
    relationship: one_to_many
    sql_on: ${users.email_address} = ${paycor_employees_managers_full_hierarchy.employee_email} ;;
  }

  join: companies {
    type: left_outer
    relationship: one_to_many
    sql_on: ${invoices.company_id} = ${companies.company_id} ;;
  }
}
