connection: "es_warehouse_global"

include: "/views/ES_WAREHOUSE/*.view.lkml"
include: "/views/ES_WAREHOUSE_GLOBAL/*.view.lkml"
include: "/views/custom_sql/*.view.lkml"

explore: line_items {
  label: "RentOps Billing Line Items Report"
  group_label: "Global Billing Information"
  case_sensitive: no

  join: invoices {
    type: left_outer
    relationship: many_to_one
    sql_on: ${line_items.invoice_id} = ${invoices.id} ;;
  }

  join: charges {
    type: left_outer
    relationship: many_to_one
    sql_on: ${line_items.charge_id} = ${charges.id}  ;;
  }

  # join: events {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${line_items.event_id} = ${events.id}  ;;
  # }

  join: rental_details {
    type: left_outer
    relationship: many_to_many
    sql_on:  ${line_items.rental_id} = ${rental_details.rental_id};;
  }

  join: assets_aggregate {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rental_details.asset_id} = ${assets_aggregate.asset_id}  ;;
  }

  join: equipmentclass_category_parentcategory {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rental_details.equipment_class_id} = ${equipmentclass_category_parentcategory.equipment_class_id} ;;
  }

  join: asset_fleet_start_end_date {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rental_details.asset_id} = ${asset_fleet_start_end_date.asset_id} ;;
  }
}

# NEED TO REFACTOR MODEL SINCE RENAMING LINE_ITEMS OR RENTAL_DETAILS TABLES DOES NOT ALLOW CURRENT FILTERS IN OTHER MODELS TO FUNCTION
# explore: billed_vs_run_rate {
#   from: line_items
#   label: "Billed vs Run Rates"
#   group_label: "Global Billing Information"
#   case_sensitive: no

#   join: invoices {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${billed_vs_run_rate.invoice_id} = ${invoices.id} ;;
#   }

#   join: rental_details {
#     type: left_outer
#     relationship: many_to_many
#     sql_on:  ${billed_vs_run_rate.rental_id} = ${rental_details.rental_id};;
#   }

#   join: rental_run_rate_by_day {
#     type: left_outer
#     relationship: many_to_many
#     sql_on: ${rental_details.rental_id} = ${rental_run_rate_by_day.rental_id} ;;
#   }

#   join: equipmentclass_category_parentcategory {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${rental_details.equipment_class_id} = ${equipmentclass_category_parentcategory.equipment_class_id} ;;
#   }
#   }


explore: asset_financial_history_tab {
  label: "RentOps Financial Purchase Report"
  group_label: "Global Billing Information"
  case_sensitive: no
}
