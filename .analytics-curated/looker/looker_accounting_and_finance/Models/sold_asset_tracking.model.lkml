connection: "es_snowflake"

include: "/views/line_items.view.lkml"
include: "/views/ES_WAREHOUSE/assets.view.lkml"
include: "/views/equipment_models.view.lkml"
include: "/views/equipment_makes.view.lkml"
include: "/views/equipment_classes_models_xref.view.lkml"
include: "/views/equipment_classes.view.lkml"
include: "/views/asset_purchase_history.view.lkml"
include: "/views/company_purchase_order_line_items.view.lkml"
include: "/views/company_purchase_orders.view.lkml"
include: "/views/company_purchase_order_types.view.lkml"
include: "/views/financial_schedules.view.lkml"
include: "/views/financial_lenders.view.lkml"
include: "/views/asset_nbv_all_owners_view.view.lkml"
include: "/views/categories.view.lkml"
include: "/views/invoices.view.lkml"
include: "/views/orders.view.lkml"
include: "/views/users.view.lkml"
include: "/views/order_salespersons.view.lkml"
include: "/views/companies.view.lkml"
include: "/views/locations.view.lkml"
include: "/views/line_item_types.view.lkml"
include: "/views/net_terms.view.lkml"
include: "/views/markets.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/credit_note_line_items.view.lkml"
include: "/views/custom_sql/sold_asset_tracker_1A.view.lkml"
include: "/views/custom_sql/sold_asset_tracker_1b.view.lkml"
include: "/views/custom_sql/sold_asset_tracker_2a.view.lkml"
include: "/views/custom_sql/sold_asset_tracker_2b.view.lkml"

explore:  sold_asset_tracker_1a {case_sensitive: no}
explore:  sold_asset_tracker_1b {case_sensitive: no}
explore:  sold_asset_tracker_2a {case_sensitive: no}
explore:  sold_asset_tracker_2b {case_sensitive: no}

explore: line_items {
  join: assets {
    type:  left_outer
    relationship:  one_to_one
    sql_on:  ${line_items.derived_asset_id} = ${assets.asset_id} ;;
  }
  join: asset_owner {
    from:  companies
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets.company_id} = ${asset_owner.company_id} ;;
  }
  join: equipment_models {
    type:  left_outer
    relationship: one_to_one
    sql_on: ${assets.equipment_model_id} = ${equipment_models.equipment_model_id} ;;
  }
  join: equipment_makes {
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets.equipment_make_id} = ${equipment_makes.equipment_make_id} ;;
  }
  join: equipment_classes_models_xref {
    type: left_outer
    relationship: one_to_one
    sql_on: ${equipment_models.equipment_model_id} = ${equipment_classes_models_xref.equipment_model_id} ;;
  }
  join: equipment_classes {
    type: left_outer
    relationship: one_to_one
    sql_on: ${equipment_classes_models_xref.equipment_class_id} = ${equipment_classes.equipment_class_id} ;;
  }
  join: asset_purchase_history {
    type:  left_outer
    relationship:  one_to_one
    sql_on:  ${assets.asset_id} = ${asset_purchase_history.asset_id} ;;
  }
  join: company_purchase_order_line_items {
    type:  left_outer
    relationship:  one_to_one
    sql_on:  ${asset_purchase_history.asset_id} = ${company_purchase_order_line_items.asset_id} ;;
  }
  join: company_purchase_orders {
    type:  left_outer
    relationship:  one_to_one
    sql_on:  ${company_purchase_order_line_items.company_purchase_order_id} = ${company_purchase_orders.company_purchase_order_id} ;;
  }
  join: company_purchase_order_types {
    type: left_outer
    relationship: one_to_one
    sql_on: ${company_purchase_orders.company_purchase_order_type_id} = ${company_purchase_order_types.company_purchase_order_type_id} ;;
  }
  join: asset_vendors {
    from: companies
    type:  left_outer
    relationship:  many_to_many
    sql_on:  ${company_purchase_orders.vendor_id} = ${asset_vendors.company_id} ;;
  }
  join: financial_schedules {
    type:  left_outer
    relationship:  one_to_one
    sql_on:  ${asset_purchase_history.financial_schedule_id} = ${financial_schedules.financial_schedule_id} ;;
  }
  join: financial_lenders {
    type:  left_outer
    relationship:  one_to_one
    sql_on:  ${financial_schedules.originating_lender_id} = ${financial_lenders.financial_lender_id} ;;
  }
  join: asset_nbv_all_owners_view {
    type: left_outer
    relationship:  one_to_one
    sql_on: ${assets.asset_id} = ${asset_nbv_all_owners_view.asset_id};;
  }
  join: categories {
    type:  left_outer
    relationship:  one_to_one
    sql_on:  ${assets.category_id} = ${categories.category_id};;
  }
  join: invoices {
    type:  left_outer
    relationship:  one_to_one
    sql_on:  ${line_items.invoice_id} = ${invoices.invoice_id};;
  }
  join: orders {
    type:  left_outer
    relationship:  one_to_one
    sql_on:  ${invoices.order_id} = ${orders.order_id};;
  }
  join: users {
    type:  left_outer
    relationship:  one_to_one
    sql_on:  ${orders.user_id} = ${users.user_id};;
  }
  join: order_salespersons {
    type:  left_outer
    relationship:  one_to_many
    sql_on:  ${orders.order_id} = ${order_salespersons.order_id};;
  }
  join: sales_persons {
    from: users
    type:  left_outer
    relationship: one_to_one
    sql_on: ${order_salespersons.user_id} = ${sales_persons.user_id} ;;
  }
  join: companies {
    type:  left_outer
    relationship:  one_to_one
    sql_on:  ${users.company_id} = ${companies.company_id};;
  }
  join: company_contact_location {
    from:  locations
    type: left_outer
    relationship: one_to_one
    sql_on: ${companies.billing_location_id} = ${company_contact_location.location_id} ;;
  }
  join: company_billing_contact {
    from:  users
    type:  left_outer
    relationship: one_to_one
    sql_on: ${company_contact_location.user_id} =${company_billing_contact.user_id};;
  }
  join: line_item_types {
    type:  left_outer
    relationship: one_to_one
    sql_on: ${line_items.line_item_type_id} = ${line_item_types.line_item_type_id} ;;
  }
  join: net_terms {
    type:  left_outer
    relationship:  one_to_one
    sql_on:  ${companies.net_terms_id} = ${net_terms.net_terms_id} ;;
  }
  join: markets {
    type:  left_outer
    relationship:  one_to_one
    sql_on:  ${assets.market_id} = ${markets.market_id};;
  }
  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.market_id} = ${market_region_xwalk.market_id} ;;
  }
  join: credit_note_line_items {
    type:  left_outer
    relationship: one_to_one
    sql_on: ${line_items.line_item_id} = ${credit_note_line_items.line_item_id} ;;
  }
  sql_always_where:  ${line_item_type_id} in (24, 80, 81) and ${credit_note_line_items.credit_note_line_item_id} is null ;;
  }
