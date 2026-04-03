view: v_dim_offer {
  sql_table_name: "PEOPLE_ANALYTICS"."GREENHOUSE"."V_DIM_OFFER" ;;

  dimension: offer_custom_benefits_type {
    type: string
    sql: ${TABLE}."OFFER_CUSTOM_BENEFITS_TYPE" ;;
  }
  dimension: offer_custom_commission_eligible {
    type: string
    sql: ${TABLE}."OFFER_CUSTOM_COMMISSION_ELIGIBLE" ;;
  }
  dimension: offer_custom_employment_type {
    type: string
    sql: ${TABLE}."OFFER_CUSTOM_EMPLOYMENT_TYPE" ;;
  }
  dimension: offer_custom_internal_external_applicant {
    type: string
    sql: ${TABLE}."OFFER_CUSTOM_INTERNAL_EXTERNAL_APPLICANT" ;;
  }
  dimension: offer_custom_change_type {
    type: string
    sql: ${TABLE}."OFFER_CUSTOM_CHANGE_TYPE" ;;
  }
  dimension: offer_custom_job_classification {
    type: string
    sql: ${TABLE}."OFFER_CUSTOM_JOB_CLASSIFICATION" ;;
  }
  dimension: offer_custom_non_compete {
    type: string
    sql: ${TABLE}."OFFER_CUSTOM_NON_COMPETE" ;;
  }
  dimension: offer_custom_pto_plan {
    type: string
    sql: ${TABLE}."OFFER_CUSTOM_PTO_PLAN" ;;
  }
  dimension: offer_custom_relocation_bonus_offered {
    type: string
    sql: ${TABLE}."OFFER_CUSTOM_RELOCATION_BONUS_OFFERED" ;;
  }
  dimension: offer_custom_vehicle_allowance {
    type: string
    sql: ${TABLE}."OFFER_CUSTOM_VEHICLE_ALLOWANCE" ;;
  }
  dimension: offer_id {
    type: number
    sql: ${TABLE}."OFFER_ID" ;;
  }
  dimension: offer_key {
    type: number
    sql: ${TABLE}."OFFER_KEY" ;;
  }
  dimension: offer_recruiter_full_name {
    type: string
    sql: ${TABLE}."OFFER_RECRUITER_FULL_NAME" ;;
  }
  dimension: offer_status {
    type: string
    sql: ${TABLE}."OFFER_STATUS" ;;
  }
  measure: count {
    type: count
    drill_fields: [offer_recruiter_full_name]
  }
}
