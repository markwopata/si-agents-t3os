connection: "es_snowflake_analytics"

include: "/views/ES_WAREHOUSE/invoices.view.lkml"
include: "/views/ES_WAREHOUSE/billing_company_preferences.view.lkml"
include: "/views/ES_WAREHOUSE/purchase_orders.view.lkml"
include: "/views/ES_WAREHOUSE/line_items.view.lkml"
include: "/views/ES_WAREHOUSE/assets_aggregate.view.lkml"
include: "/views/ES_WAREHOUSE/orders.view.lkml"
include: "/views/ES_WAREHOUSE/rentals.view.lkml"
include: "/views/ES_WAREHOUSE/companies.view.lkml"


explore: invoices  {
sql_always_where: ${billing_company_preferences.gsa} = 'true' ;;

  join: billing_company_preferences {
    relationship: one_to_one
    sql_on: ${invoices.company_id} = ${billing_company_preferences.company_id}
      ;;
  }

  join: purchase_orders {
    relationship: many_to_one
    sql_on: ${invoices.purchase_order_id} = ${purchase_orders.purchase_order_id} ;;
  }

  join: line_items {
    relationship: many_to_one
    sql_on: ${invoices.invoice_id} = ${line_items.invoice_id} ;;
  }

  join: assets_aggregate {
    relationship: many_to_one
    sql_on: ${line_items.asset_id} = ${assets_aggregate.asset_id} ;;
  }

  join: orders {
    relationship: many_to_one
    sql_on: ${invoices.order_id} = ${orders.order_id} ;;
  }

  join: rentals {
    relationship: many_to_one
    sql_on: ${invoices.order_id} = ${rentals.order_id}
          and ${assets_aggregate.asset_id} = ${rentals.asset_id} ;;
  }

  join: companies {
    relationship: many_to_one
    sql_on: ${invoices.company_id} = ${companies.company_id} ;;
  }

} #end invoices
