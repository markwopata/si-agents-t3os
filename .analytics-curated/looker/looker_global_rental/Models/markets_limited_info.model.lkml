connection: "es_warehouse_global"

#include: "/markets_dashboard.dashboard"
include: "/views/ES_WAREHOUSE/*.view.lkml"
include: "/views/ES_WAREHOUSE_GLOBAL/*.view.lkml"
include: "/views/custom_sql/*.view.lkml"

  explore: Markets_Overview_by_Approved_Date {
    from: orders
    label: "Global Market Information by Invoice Approved Date"
    group_label: "Global Markets Overview"
    case_sensitive: no

    join: invoices {
      type: inner
      relationship: one_to_many
      sql_on: ${Markets_Overview_by_Approved_Date.external_id} = ${invoices.order_external_id} and ${invoices.status} = 'approved'
              AND ${invoices.issue_date} >= '2021-05-01' ;;
    }

    join: line_items {
      type: inner
      relationship: one_to_many
      sql_on: ${invoices.id} = ${line_items.invoice_id};;
    }

##  This table is asset-level details for OEC and Rental Revenue (to link with Asset Class: need to be able to link OEC to asset.asset_class and Revenue to rentals.equipment_class_id)
    join: market_financial_utilization {
      type: left_outer
      relationship: many_to_one
      sql_on: ${Markets_Overview_by_Approved_Date.branch_id} = ${market_financial_utilization.marketid} ;;
    }

    join: rental_details {
      type: left_outer
      relationship: one_to_many
      sql_on: ${rental_details.rental_id} = ${line_items.rental_id}  ;;
    }

    join: equipmentclass_category_parentcategory {
      type: left_outer
      relationship: many_to_one
      sql_on: ${rental_details.equipment_class_id} = ${equipmentclass_category_parentcategory.equipment_class_id} ;;
    }

    join: asset_class_customer_branch {
      type: left_outer
      relationship: many_to_one
      sql_on: ${market_financial_utilization.asset_id} = ${asset_class_customer_branch.asset_id} ;;
    }
    }

# Markets Overview - Market Rental Revenue History
  explore: market_rental_revenue_history {
    group_label: "Global Markets Overview"
    label: "Global Market Rental Revenue History"
    case_sensitive: no

    join: rental_details {
      type: left_outer
      relationship: one_to_one
      sql_on: ${market_rental_revenue_history.rental_id} = ${rental_details.rental_id}  ;;
    }

    join: equipmentclass_category_parentcategory {
      type: left_outer
      relationship: many_to_one
      sql_on: ${rental_details.equipment_class_id} = ${equipmentclass_category_parentcategory.equipment_class_id} ;;
    }
  }

  explore: rental_run_rate_by_day {
    group_label: "Global Markets Overview"
    label: "Global Market Rental Run Rate"
    case_sensitive: no

    join: rental_details {
      type: left_outer
      relationship: many_to_one
      sql_on: ${rental_run_rate_by_day.rental_id} = ${rental_details.rental_id};;
    }

  join: equipmentclass_category_parentcategory {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rental_details.equipment_class_id} = ${equipmentclass_category_parentcategory.equipment_class_id} ;;
  }
  }

  #Rental Information
  explore: rental_details {
    group_label: "Global Rental Information"
    label: "RentOps Rentals Search Table"
    case_sensitive: no

    join: effective_day_rate_by_rental_id {
      type: left_outer
      relationship: one_to_one
      sql_on: ${rental_details.rental_id} = ${effective_day_rate_by_rental_id.rental_id} ;;
    }

    join: deliveries {
      type: left_outer
      relationship: one_to_one
      sql_on: ${rental_details.drop_off_delivery_id} = ${deliveries.delivery_id} ;;
    }

    join: line_items {
      type: left_outer
      relationship: one_to_many
      sql_on: ${rental_details.rental_id} = ${line_items.rental_id} ;;
    }

    join: invoices {
      type: left_outer
      relationship: many_to_one
      sql_on: ${line_items.invoice_id} = ${invoices.id} and ${invoices.status} = 'approved' ;;
    }

    join: asset_class_rate_averages {
      type: left_outer
      relationship: one_to_many
      sql_on: ${rental_details.equipment_class_id} = ${asset_class_rate_averages.equipment_class_id} ;;
    }

    join: equipmentclass_category_parentcategory {
      type: left_outer
      relationship: many_to_one
      sql_on: ${rental_details.equipment_class_id} = ${equipmentclass_category_parentcategory.equipment_class_id} ;;
    }
  }

  #Rental Details
  explore: basic_rental_details {
    from: rental_details
    group_label: "Global Rental Information"
    label: "Basic Rental Details"
    case_sensitive: no
    sql_always_where: ${basic_rental_details.renter_company_id} = {{ _user_attributes['company_id'] }};;

    join: equipmentclass_category_parentcategory {
      type: left_outer
      relationship: many_to_one
      sql_on: ${basic_rental_details.equipment_class_id} = ${equipmentclass_category_parentcategory.equipment_class_id} ;;
    }
  }
