connection: "es_warehouse_global"

include: "/views/ES_WAREHOUSE/*.view.lkml"
include: "/views/ES_WAREHOUSE_GLOBAL/*.view.lkml"
include: "/views/custom_sql/*.view.lkml"

  explore: rental_details {
  label: "RentOps Customer and Billing Data"
  group_label: "Global Customer and Sales Information"
  case_sensitive: no

  join: line_items {
  type: left_outer
  relationship: many_to_many
  sql_on: ${rental_details.rental_id} = ${line_items.rental_id}  ;;
  }

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

  join: asset_class_customer_branch {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rental_details.asset_id} = ${asset_class_customer_branch.asset_id} ;;
  }
  }

  explore: rental_details2 {
    from: rental_details
    label: "RentOps Customer Rental Details"
    group_label: "Global Customer and Sales Information"
    case_sensitive: no

  join: customer_first_rental {
    type: inner
    relationship: one_to_one
    sql_on: ${rental_details2.rental_id} = ${customer_first_rental.first_rental_id} ;;
  }

    join: asset_class_customer_branch {
      type: left_outer
      relationship: many_to_one
      sql_on: ${rental_details2.asset_id} = ${asset_class_customer_branch.asset_id} ;;
    }

  }

  explore: rental_run_rate {
    from: rental_details
    label: "RentOps Customer Run Rate Details"
    group_label: "Global Customer and Sales Information"
    case_sensitive: no

  join: rental_run_rate_by_day {
      type: left_outer
      relationship: one_to_many
      sql_on: ${rental_run_rate.rental_id} = ${rental_run_rate_by_day.rental_id}  ;;
  }

    join: asset_class_customer_branch {
      type: left_outer
      relationship: many_to_one
      sql_on: ${rental_run_rate.asset_id} = ${asset_class_customer_branch.asset_id} ;;
    }
  }

  explore: company_class_pricing {
    label: "RentOps Company Class Pricing"
    group_label: "Global Customer and Sales Information"
    case_sensitive: no
    }

  explore: branch_class_pricing {
    label: "RentOps Branch Class Pricing"
    group_label: "Global Customer and Sales Information"
    case_sensitive: no
  }

  explore: jobsite_class_pricing {
    label: "RentOps Jobsite Class Pricing"
    group_label: "Global Customer and Sales Information"
    case_sensitive: no
  }
