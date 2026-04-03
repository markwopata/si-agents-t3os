connection: "reportingc_warehouse"

include: "/views/*.view.lkml"
include: "/views/trip_log_report/*.view.lkml"

explore: trip_log_report {
  group_label: "Trip Log Report"
  label: "Trip Log and Detail"
  case_sensitive: no
  persist_for: "30 minutes"

  join: trip_log_report_detail {
    type: left_outer
    relationship: many_to_one
    sql_on: ${trip_log_report_detail.trip_id} = ${trip_log_report.trip_id} ;;
  }

  join: assets {
    type: inner
    relationship: many_to_one
    sql_on: ${trip_log_report.asset_id} = ${assets.asset_id} ;;
  }

  join: asset_types {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_type_id} = ${asset_types.asset_type_id} ;;
  }

  join: organization_asset_xref {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${organization_asset_xref.asset_id} ;;
  }

  join: organizations {
    type: left_outer
    relationship: one_to_many
    sql_on: ${organization_asset_xref.organization_id} = ${organizations.organization_id} ;;
  }

  join: categories {
    type: left_outer
    relationship: many_to_one
    sql_on: ${categories.category_id} = ${assets.category_id} ;;
  }

  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${markets.market_id} = ${assets.inventory_branch_id} ;;
  }

}
