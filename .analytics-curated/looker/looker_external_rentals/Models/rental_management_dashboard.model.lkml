connection: "reportingc_warehouse"

include: "/views/rental_management_dashboard/*.view.lkml"
include: "/views/*.view.lkml"

explore: rental_status_info {
  group_label: "Rental Management Dashboard"
  label: "Current Rental Information"
  case_sensitive: no
  persist_for: "20 minutes"

  join: rentals {
    type: left_outer
    relationship: one_to_many
    sql_on: ${rental_status_info.rental_id} = ${rentals.rental_id};;
  }

  join: orders {
    type: left_outer
    relationship: one_to_many
    sql_on: ${rentals.order_id} = ${orders.order_id};;
  }

  join: sub_renters {
    type: left_outer
    relationship: one_to_one
    sql_on: ${orders.sub_renter_id} = ${sub_renters.sub_renter_id} ;;
  }

  join: purchase_orders {
    type: left_outer
    relationship: one_to_many
    sql_on: ${orders.purchase_order_id} = ${purchase_orders.purchase_order_id};;
  }

  join: equipment_assignments {
    type: left_outer
    relationship: one_to_many
    sql_on: ${rentals.rental_id} = ${equipment_assignments.rental_id};;
  }

  join: assets {
    type: left_outer
    relationship: one_to_many
    sql_on: ${rental_status_info.asset_id} = ${assets.asset_id};;
  }

  join: asset_info {
    type: left_outer
    relationship: one_to_many
    sql_on: ${rental_status_info.asset_id} = ${asset_info.asset_id};;
  }

  join: rental_location_assignments {
    type: left_outer
    relationship: one_to_many
    sql_on: ${rentals.rental_id} = ${rental_location_assignments.rental_id};;
  }

  join: locations {
    type: left_outer
    relationship: one_to_many
    sql_on: ${rental_location_assignments.location_id} = ${locations.location_id};;
  }

  join: states {
    type: left_outer
    relationship: one_to_many
    sql_on: ${locations.state_id} = ${states.state_id};;
  }

  join: markets {
    type: left_outer
    relationship: one_to_many
    sql_on: ${orders.market_id} = ${markets.market_id};;
  }

  join: companies {
    type: left_outer
    relationship: many_to_one
    sql_on: ${markets.company_id} = ${companies.company_id};;
  }
}

explore: rental_asset_class_spend {
  group_label: "Rental Management Dashboard"
  label: "Asset Class Spend"
  case_sensitive: no
  persist_for: "30 minutes"

  join: orders {
    type: left_outer
    relationship: one_to_one
    sql_on: ${rental_asset_class_spend.order_id} = ${orders.order_id} ;;
  }

  join: sub_renters {
    type: left_outer
    relationship: one_to_one
    sql_on: ${orders.sub_renter_id} = ${sub_renters.sub_renter_id} ;;
  }
}

explore: rental_jobsite_spend {
  group_label: "Rental Management Dashboard"
  label: "Jobsite Spend"
  case_sensitive: no
  persist_for: "30 minutes"

  join: orders {
    type: left_outer
    relationship: one_to_one
    sql_on: ${rental_jobsite_spend.order_id} = ${orders.order_id} ;;
  }

  join: sub_renters {
    type: left_outer
    relationship: one_to_one
    sql_on: ${orders.sub_renter_id} = ${sub_renters.sub_renter_id} ;;
  }
}

explore: po_budget_information {
  group_label: "Rental Management Dashboard"
  label: "PO Budget and Spend Summary"
  case_sensitive: no
  persist_for: "30 minutes"

  join: po_drill_details {
    type: full_outer
    relationship: many_to_one
    sql_on: ${po_drill_details.purchase_order_id} = ${po_budget_information.purchase_order_id};;
  }
}

explore: po_budget_timeline {
  group_label: "Rental Management Dashboard"
  label: "PO Budget and Spend Timeline"
  case_sensitive: no
  persist_for: "30 minutes"
}

explore: asset_info {
  group_label: "Rental Management Dashboard"
  label: "Asset Info"
  case_sensitive: no
  persist_for: "180 minutes"


}
