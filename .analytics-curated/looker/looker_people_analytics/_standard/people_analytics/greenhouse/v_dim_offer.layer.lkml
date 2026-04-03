include: "/_base/people_analytics/greenhouse/v_dim_offer.view.lkml"


view: +v_dim_offer {
  label: "Dim Offer"

  ################ DIMENSIONS ################

  dimension: offer_key {
    value_format_name: id
    description: "Offer Key used to join to the Fact Application Requisition Offer"
  }

  dimension: offer_id {
    value_format_name: id
    description: "ID used to identify an offer"
  }

  ################ DATES ################

  measure: unique_offer_ids {
    type: count_distinct
    sql: ${offer_id} ;;
    drill_fields: [drill_fields*]
    description: "Total number of distinct offers"
  }

  measure: unique_internal_offers {
    type: count_distinct
    sql: ${offer_id} ;;
    filters: [offer_custom_internal_external_applicant: "Internal"]
    drill_fields: [drill_fields*]
    description: "Total number of distinct internal offers"
  }

  measure: unique_external_offers {
    type: count_distinct
    sql: ${offer_id} ;;
    filters: [offer_custom_internal_external_applicant: "External"]
    drill_fields: [drill_fields*]
    description: "Total number of distinct external offers"
  }

  set: drill_fields {
    fields: [offer_id,
      v_dim_application.application_id,
      v_dim_candidate.candidate_full_name,
      v_dim_requisition.requisition_name,
      offer_custom_change_type,
      v_fact_application_requisition_offer.application_requisition_offer_offer_created,
      v_fact_application_requisition_offer.application_requisition_offer_offer_sent,
      v_fact_application_requisition_offer.application_requisition_offer_offer_resolved,
      v_dim_candidate.candidate_custom_scorecard_score]
    }
}
