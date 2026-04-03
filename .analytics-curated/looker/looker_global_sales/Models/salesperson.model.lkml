connection: "es_warehouse_global"

include: "/views/salesperson/*.view.lkml"

explore: current_assets_oec_on_rent {
  group_label: "RentOps Salesperson"
  label: "Current Assets/OEC On Rent"
  case_sensitive: no
  persist_for: "30 minutes"

  join: current_assets_oec_on_rent_drill {
    type: left_outer
    relationship: many_to_one
    sql_on: ${current_assets_oec_on_rent.sales_rep} = ${current_assets_oec_on_rent_drill.sales_rep} ;;
  }
}

explore: current_last_mtd_revenue {
  group_label: "RentOps Salesperson"
  label: "Current MTD Last MTD Revenue"
  case_sensitive: no
  persist_for: "30 minutes"
}

explore: historical_revenue {
  group_label: "RentOps Salesperson"
  label: "Historical Rental Revenue"
  case_sensitive: no
  persist_for: "30 minutes"

  join: historical_revenue_drill {
    type: left_outer
    relationship: many_to_one
    sql_on: ${historical_revenue.created_month_month} = ${historical_revenue_drill.created_month_month} AND ${historical_revenue.sales_rep} = ${historical_revenue_drill.sales_rep} AND ${historical_revenue.branch} = ${historical_revenue_drill.branch};;
  }
}

explore: rolling_units_oec_on_rent {
  group_label: "RentOps Salesperson"
  label: "Rolling Units/OEC On Rent"
  case_sensitive: no
  persist_for: "30 minutes"
}

explore: actively_renting_companies_and_assets {
  group_label: "RentOps Salesperson"
  label: "Actively Renting Companies/Assets"
  case_sensitive: no
  persist_for: "30 minutes"
}

explore: dormant_accounts {
  group_label: "RentOps Salesperson"
  label: "Dormant Accounts"
  case_sensitive: no
  persist_for: "30 minutes"
}
