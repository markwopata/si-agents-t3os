connection: "es_snowflake_analytics"

include: "/Dashboards/contract_scoring/views/*.view.lkml"               # include all views in the views/ folder in this project
include: "/views/ES_WAREHOUSE/*.view.lkml"

view: gross_profit_pct_payout_parent_company {
  extends: ["gross_profit_pct_payout"]
}


# view: gross_profit_pct_payout_sales_director {
#   extends: ["gross_profit_pct_payout"]
# }


# view: ancillary_pct_payout_parent_company {
#   extends: ["ancillary_pct_payout"]
# }

# view: ancillary_pct_payout_sales_director {
#   extends: ["ancillary_pct_payout"]
# }


explore: national_account_list {
  case_sensitive: no
  label: "Contract Scoring"
  description: "Use this explore for pulling breakeven rates for contract scoring purposes."
  fields: [ALL_FIELDS*
  ]



  # join: contract_scoring {
  #   type: left_outer
  #   relationship: one_to_many
  #   sql_on: ${national_account_list.parent_company_name}=${contract_scoring.parent_company_name} ;;
  # }

  join: contract_scoring_quarterly_view {
    type: left_outer
    relationship: one_to_many
    sql_on: ${contract_scoring_quarterly_view.parent_company_name} = ${national_account_list.parent_company_name};;
  }

  join: gross_profit_pct_payout_parent_company {
    type: left_outer
    relationship: many_to_one
    sql_on: COALESCE(${gross_profit_pct_payout_parent_company.min_profit},-9999) <= ${contract_scoring_quarterly_view.gross_profit_margin_pct}
    and COALESCE(${gross_profit_pct_payout_parent_company.max_profit},9999) > ${contract_scoring_quarterly_view.gross_profit_margin_pct} ;;
  }

  # join: contract_scoring_quarterly_view_sales_director {
  #   type: left_outer
  #   relationship: one_to_many
  #   sql_on: ${contract_scoring_quarterly_view_sales_director.parent_company_name} = ${national_account_list.parent_company_name};;
  # }

  # join: gross_profit_pct_payout_sales_director {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: COALESCE(${gross_profit_pct_payout_sales_director.min_profit},-9999) <= ${contract_scoring_quarterly_view_sales_director.gross_profit_margin_pct}
  #   and COALESCE(${gross_profit_pct_payout_sales_director.max_profit},9999) > ${contract_scoring_quarterly_view_sales_director.gross_profit_margin_pct} ;;
  # }

  join: ancillary_pct_payout_parent_company {
    type: left_outer
    relationship: many_to_one
    sql_on: COALESCE(${ancillary_pct_payout_parent_company.min_ancillary},-9999) <= ${contract_scoring_quarterly_view.ancillary_pct_of_rental_revenue}
      and COALESCE(${ancillary_pct_payout_parent_company.max_ancillary},9999) > ${contract_scoring_quarterly_view.ancillary_pct_of_rental_revenue}
      and ${ancillary_pct_payout_parent_company.invoice_date_quarter} = ${contract_scoring_quarterly_view.invoice_date_quarter} ;;
  }

  join: national_account_coordinators {

    type: left_outer
    relationship: many_to_many
    sql_on: ${national_account_coordinators.company_name} = ${contract_scoring_quarterly_view.parent_company_name} and ${national_account_coordinators.invoice_date} = ${contract_scoring_quarterly_view.invoice_date_raw} ;;

  }

  join: national_account_managers {

    type: left_outer
    relationship: one_to_many
    sql_on: ${national_account_managers.company_name} = ${contract_scoring_quarterly_view.parent_company_name} ;;


  }

  }

  explore: national_account_coordinators_agg {
    case_sensitive: no
    label: "National Account Coordinator Bonus"
    description: "Use this explore for finding quarterly bonuses for National Account Coordinators and their managers"
    fields: [ALL_FIELDS*
    ]

  # join: ancillary_pct_payout_sales_director {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: COALESCE(${ancillary_pct_payout_sales_director.min_ancillary},-9999) <= ${contract_scoring_quarterly_view_sales_director.ancillary_pct_of_rental_revenue}
  #     and COALESCE(${ancillary_pct_payout_sales_director.max_ancillary},9999) > ${contract_scoring_quarterly_view_sales_director.ancillary_pct_of_rental_revenue}
  #     and ${ancillary_pct_payout_sales_director.invoice_date_quarter} = ${contract_scoring_quarterly_view_sales_director.invoice_date_quarter} ;;
  # }


}




explore: contract_scoring_invoice_level {
  case_sensitive: no
  fields: [ALL_FIELDS*]
  # label: "Contract Scoring with Gross Profit Margins"
  # description: "Use this explore for pulling breakeven rates for contract scoring purposes."


#equipment_classes
  join: equipment_classes {
    type: left_outer
    relationship: many_to_one
    sql_on: ${equipment_classes.equipment_class_id}=${contract_scoring_invoice_level.equipment_class_id} ;;
  }

#categories
  join: categories {
    type: left_outer
    relationship: many_to_one
    sql_on: ${equipment_classes.category_id}=${categories.category_id} ;;
  }


# #business_segments
#   join: business_segments {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${business_segments.business_segment_id}=${equipment_classes.business_segment_id} ;;
#   }




  # join: contract_scoring {
  #   type: left_outer
  #   relationship: one_to_many
  #   sql_on: ${national_account_list.parent_company_name}=${contract_scoring.parent_company_name} ;;
  # }

  # join: contract_scoring_invoice_level {
  #   type: left_outer
  #   relationship: one_to_many
  #   sql_on: ${contract_scoring_quarterly_view.parent_company_name} = ${national_account_list.parent_company_name};;
  }
