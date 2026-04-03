connection: "es_snowflake_c_analytics"

include: "/suggestions.lkml"
include: "/Construction/views/construction_budget.view.lkml"
include: "/views/ANALYTICS/market.view.lkml"
include: "/Construction/views/cip_budget_amounts.view.lkml"
include: "/Construction/views/cip_expense_classifications.view.lkml"
include: "/Construction/views/master_markets_dump.view.lkml"
include: "/Construction/views/master_markets_cip_tracking.view.lkml"
include: "/Construction/views/construction_po_detail.view.lkml"

explore: construction_budget {
  label: "Construction Budget"

  join: market {
    type: left_outer
    relationship: many_to_one
    sql_on: ${construction_budget.market_id} = ${market.child_market_id} ;;
  }

  join: cip_expense_classifications {
    type: left_outer
    relationship: many_to_one
    sql_on: ${cip_expense_classifications.division_code} = ${construction_budget.division_code}
      and ${cip_expense_classifications.project_code} = ${construction_budget.project_code}
      and ${cip_expense_classifications.market_id} = ${construction_budget.market_id};;
  }

}

explore: cip_budget_amounts {
  label: "CIP Budget Amounts"
}

explore: master_markets_dump {
  label: "Master Markets Dump"
}

explore: master_markets_cip_tracking {
  label:  "Master Markets CIP Tracking"
}

explore: construction_po_detail {
  label:  "Construction PO Detail"
}
