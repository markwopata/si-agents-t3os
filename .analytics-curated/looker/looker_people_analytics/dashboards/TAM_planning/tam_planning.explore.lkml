include: "/_standard/analytics/monday/master_markets.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_bridge_dim_office.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_application.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_candidate.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_date.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_department.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_offer.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_office.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_requisition.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_stage.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_fact_application_history.layer.lkml"
include: "/_standard/analytics/asset_details/asset_physical.layer.lkml"
#include: "/_standard/custom_sql/market_oec.view.lkml"
include: "/_standard/analytics/public/asset_financing_snapshots.layer.lkml"

view: +asset_physical {

  measure: distinct_premium_trucks {
    type: count_distinct
    sql: ${asset_id} ;;
    filters: [model:"1500 Premium, Silverado 1500 Premium"]
  }
}

view: +v_dim_candidate {

  measure: candidates_in_hm_stage {
    type: count_distinct
    sql: ${candidate_id} ;;
    filters: [v_dim_stage.stage_name: "Hiring Manager Interview(s)"]
  }
}

view: +v_dim_offer {

  measure: unique_non_null_offers {
    type: count_distinct
    sql: ${offer_id} ;;
    filters: [offer_status: "-Default Record"]
    drill_fields: [offer_details*]
  }

  set: offer_details {
    fields: [offer_id,
      v_dim_application.application_id,
      v_dim_candidate.candidate_full_name,
      v_dim_requisition.requisition_name,
      v_fact_application_requisition_offer.application_requisition_offer_start]
  }
}

explore: master_markets {
  label: "TAM Planning"

  join: asset_financing_snapshots {
    type: left_outer
    relationship: one_to_one
    sql_on: ${master_markets.market_id} = ${asset_financing_snapshots.market_id} ;;
  }

  join: v_dim_office {
    type: left_outer
    relationship: one_to_one
    sql_on: ${master_markets.market_id} = try_to_number(${v_dim_office.office_external_id}) ;;
  }

  join: v_bridge_dim_office {
    type: left_outer
    relationship: one_to_one
    sql_on: ${v_dim_office.office_key} = ${v_bridge_dim_office.bridge_dim_office_key};;
  }

  join: v_fact_application_history {
    type: left_outer
    relationship: one_to_one
    sql_on: ${v_bridge_dim_office.bridge_dim_office_application_requisition_offer_key} = ${v_fact_application_history.application_history_application_key}::VARCHAR || '|' || COALESCE(${v_fact_application_history.application_history_requistion_key},-1)::VARCHAR || '|' || COALESCE(${v_fact_application_history.application_history_offer_key},-1)::VARCHAR ;;
  }

  join: v_dim_requisition {
    type: left_outer
    relationship: one_to_one
    sql_on: ${v_fact_application_history.application_history_requistion_key} = ${v_dim_requisition.requisition_key};;
  }

  join: v_dim_application {
    type: left_outer
    relationship: one_to_one
    sql_on: ${v_fact_application_history.application_history_application_key} = ${v_dim_application.application_key};;
  }

  join: v_dim_candidate {
    type: left_outer
    relationship: one_to_one
    sql_on: ${v_fact_application_history.application_history_candidate_key} = ${v_dim_candidate.candidate_key};;
  }

  join: v_dim_stage {
    type: left_outer
    relationship: one_to_one
    sql_on: ${v_fact_application_history.application_history_stage_key} = ${v_dim_stage.stage_key};;
  }

  join: v_dim_offer {
    type: left_outer
    relationship: one_to_one
    sql_on: ${v_fact_application_history.application_history_offer_key} = ${v_dim_offer.offer_key};;
  }
}
