connection: "es_snowflake_c_analytics"

include: "/views/ES_WAREHOUSE/orders.view.lkml"
include: "/views/ES_WAREHOUSE/rentals.view.lkml"
include: "/views/ES_WAREHOUSE/users.view.lkml"
include: "/views/ES_WAREHOUSE/purchase_orders.view.lkml"
include: "/views/ES_WAREHOUSE/assets.view.lkml"
include: "/views/ES_WAREHOUSE/companies.view.lkml"
include: "/views/ES_WAREHOUSE/markets.view.lkml"
include: "/views/ES_WAREHOUSE/line_items.view.lkml"
include: "/views/ES_WAREHOUSE/line_item_types.view.lkml"
include: "/views/ES_WAREHOUSE/locations.view.lkml"
include: "/views/ES_WAREHOUSE/equipment_classes.view.lkml"
include: "/views/ES_WAREHOUSE/invoices.view.lkml"
include: "/views/ES_WAREHOUSE/deliveries.view.lkml"
include: "/views/ES_WAREHOUSE/states.view.lkml"

include: "/views/ES_WAREHOUSE/equipment_classes.view.lkml"

include: "/Dashboards/Projected_Billing/views/purchase_orders_totals.view.lkml"
include: "/Dashboards/Projected_Billing/views/admin_cycle.view.lkml"
include: "/Dashboards/Projected_Billing/views/rental_asset_descriptions.view.lkml"
include: "/Dashboards/Projected_Billing/views/po_line_item_totals.view.lkml"

# Original request https://app.shortcut.com/businessanalytics/story/161023/tesla-qualtek-weekly-reports-kari-evans-bill-newman
explore: companies {
  view_name: companies
  label: "Projected Billing On Rent"
  description: "Use this explore for pulling detailed projected billing on rent lists for a singular company"
  case_sensitive: no
  persist_for: "2 hours"
  sql_always_where: ${rentals.rental_status_id} = 5;;
  fields: [ALL_FIELDS*,
            -companies.company_name_with_net_terms]

  join: users {
    type: inner
    relationship: one_to_many
    sql_on: ${companies.company_id} = ${users.company_id} ;;
  }

  join: orders {
    type: inner
    relationship: one_to_many
    sql_on: ${users.user_id} = ${orders.user_id} ;;
  }

  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${orders.market_id} = ${markets.market_id} ;;
  }

  join: rentals {
    type: left_outer
    relationship: many_to_one
    sql_on: ${orders.order_id} = ${rentals.order_id} ;;
  }


  join: purchase_orders_totals {
    type: left_outer
    relationship: many_to_one
    sql_on: ${orders.purchase_order_id} = ${purchase_orders_totals.purchase_order_id};;
  }

  join: admin_cycle{
    type: left_outer
    relationship: one_to_one
    sql_on: ${rentals.rental_id} = ${admin_cycle.rental_id} and ${rentals.asset_id} = ${admin_cycle.asset_id}  ;;
  }

  join: rental_asset_descriptions {
    type: inner
    relationship: one_to_many
    sql_on: ${rentals.rental_id} = ${rental_asset_descriptions.rental_id} ;;
  }

  join: equipment_classes {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rentals.equipment_class_id} = ${equipment_classes.equipment_class_id} ;;
  }

  join: deliveries {
    type: left_outer
    relationship: one_to_many
    sql_on: ${rentals.rental_id} = ${deliveries.rental_id} and ${rentals.drop_off_delivery_id} = ${deliveries.delivery_id} ;;
  }

  join: locations {
    type:  left_outer
    relationship: many_to_one
    sql_on:  ${deliveries.location_id} = ${locations.location_id} ;;
  }

  join: states {
    type: left_outer
    relationship: many_to_one
    sql_on: ${states.state_id} = ${locations.state_id}  ;;
  }

}

explore: open_ar_details {
  view_name: companies
  label: "Projected Billing On Rent w Line Items"
  description: "Use this explore for pulling detailed projected billing on rent lists for a singular company with line items"
  case_sensitive: no
  persist_for: "2 hours"
  fields: [ALL_FIELDS*,
    -companies.company_name_with_net_terms,
    -locations.company_address,
    -invoices*]

  join: users {
    type: inner
    relationship: one_to_many
    sql_on: ${companies.company_id} = ${users.company_id} ;;
  }

  join: orders {
    type: left_outer
    relationship: one_to_many
    sql_on: ${users.user_id} = ${orders.user_id} ;;
  }

  join: invoices {
    type: left_outer
    relationship: one_to_many
    sql_on: ${orders.order_id} = ${invoices.order_id} ;;
  }

  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${orders.market_id} = ${markets.market_id} ;;
  }

  join: rentals {
    type: left_outer
    relationship: many_to_one
    sql_on: ${orders.order_id} = ${rentals.order_id} ;;
  }

  join: purchase_orders_totals {
    type: left_outer
    relationship: many_to_one
    sql_on: ${orders.purchase_order_id} = ${purchase_orders_totals.purchase_order_id};;
  }

  join: po_line_item_totals {
    type: inner
    relationship: one_to_many
    sql_on: ${invoices.invoice_id} = ${po_line_item_totals.invoice_id} ;;
  }

  join: assets {
    type: left_outer
    relationship: one_to_many
    sql_on: ${po_line_item_totals.asset_id} = ${assets.asset_id} ;;
  }

  join: locations {
    type: left_outer
    relationship: one_to_many
    sql_on: ${po_line_item_totals.location_id} = ${locations.location_id} ;;
  }

}
