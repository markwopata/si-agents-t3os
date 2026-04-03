connection: "es_snowflake"

include: "/views/Analytics/contract_complete_rpo_board.view.lkml"
include: "/views/Analytics/credit_review_rpo_board.view.lkml"
include: "/views/Analytics/fleet_ops_lsd_board.view.lkml"
include: "/views/Analytics/fleet_ops_rpo_board.view.lkml"
include: "/views/Analytics/in_service_rpo_board.view.lkml"
include: "/views/Analytics/insurance_lsd_board.view.lkml"
include: "/views/Analytics/retail_to_rental_board.view.lkml"
include: "/views/Business_Intelligence/v_dim_salesperson_enhanced.view.lkml"
include: "/views/Business_Intelligence/v_dim_dates_bi.view.lkml"
include: "/views/Platform/*"
include: "/views/ES_Warehouse/v_payout_programs.view.lkml"


explore: contract_complete_rpo_board {
  label: "Contract Complete RPO Board"
}

explore: credit_review_rpo_board {
  label: "Credit Review RPO Board"
}

explore: fleet_ops_lsd_board {
  label: "Fleet Ops LSD Board"

  join: dim_invoices {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fleet_ops_lsd_board.sales_invoice_number} = ${dim_invoices.invoice_no} ;;
  }

  join: fact_invoice_line_details {
    type: left_outer
    relationship: one_to_many
    sql_on: ${dim_invoices.invoice_key} = ${fact_invoice_line_details.invoice_line_details_invoice_key} ;;
  }

  join: v_dim_dates_bi {
    view_label: "Billing Approved Date"
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_invoice_line_details.invoice_line_details_gl_billing_approved_date_key} = ${v_dim_dates_bi.date_key} ;;
  }

  join: dim_companies {
    view_label: "Invoice Company"
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_invoice_line_details.invoice_line_details_company_key} = ${dim_companies.company_key} ;;
  }

  join: dim_users {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_invoice_line_details.invoice_line_details_salesperson_key} = ${dim_users.user_key} ;;
  }

  join: dim_markets {
    type: left_outer
    relationship: one_to_one
    sql_on: ${fact_invoice_line_details.invoice_line_details_market_key} = ${dim_markets.market_key} ;;
  }

  join: v_dim_salesperson_enhanced {
    type: left_outer
    relationship: many_to_one
    sql_on: ${dim_users.user_id} = ${v_dim_salesperson_enhanced.user_id}
      AND ${v_dim_salesperson_enhanced._is_current} = TRUE ;;
  }

  join: dim_assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_invoice_line_details.invoice_line_details_asset_key} = ${dim_assets.asset_key} ;;
  }

  join: insurance_lsd_board {
    type: left_outer
    relationship: one_to_one
    sql_on: ${fleet_ops_lsd_board.lsd_insurance} = ${insurance_lsd_board.link_to_lsd_fleet_ops} ;;
  }

  join: v_payout_programs {
    type: left_outer
    relationship: many_to_one
    sql_on: try_to_number(${fleet_ops_lsd_board.lsd_insurance}) = ${v_payout_programs.asset_id} ;;
  }
  }

explore: fleet_ops_rpo_board {
  label: "Fleet Ops RPO Board"
}

explore: in_service_rpo_board {
  label: "In Service RPO Board"
}

explore: insurance_lsd_board {
  label: "Insurance LSD Board"
}

explore: retail_to_rental_board {
  label: "Retail to Rental Board"
}
