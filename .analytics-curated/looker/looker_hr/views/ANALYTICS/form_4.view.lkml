view: form_4 {
  sql_table_name: "INSURANCE_FORMS"."FORM_4"
    ;;

  dimension_group: _fivetran_synced {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
  }

  dimension: asset_ {
    type: number
    sql: ${TABLE}."ASSET_" ;;
  }

  dimension: branch_location_name {
    type: string
    sql: ${TABLE}."BRANCH_LOCATION_NAME" ;;
  }

  dimension: customer_s_account_ {
    type: number
    sql: ${TABLE}."CUSTOMER_S_ACCOUNT_" ;;
  }

  dimension: customer_s_name {
    type: string
    sql: ${TABLE}."CUSTOMER_S_NAME" ;;
  }

  dimension: customer_s_rental_contract_ {
    type: number
    sql: ${TABLE}."CUSTOMER_S_RENTAL_CONTRACT_" ;;
  }

  dimension: date_of_customer_s_rental_contract_ {
    type: string
    sql: ${TABLE}."DATE_OF_CUSTOMER_S_RENTAL_CONTRACT_" ;;
  }

  dimension: date_of_incident_ {
    type: string
    sql: ${TABLE}."DATE_OF_INCIDENT_" ;;
  }

  dimension: did_the_accident_involve_a_third_party_other_than_the_customer_for_example_an_external_hauler_or_sub_contractor_caused_damage_to_an_es_asset_ {
    type: string
    sql: ${TABLE}."DID_THE_ACCIDENT_INVOLVE_A_THIRD_PARTY_OTHER_THAN_THE_CUSTOMER_FOR_EXAMPLE_AN_EXTERNAL_HAULER_OR_SUB_CONTRACTOR_CAUSED_DAMAGE_TO_AN_ES_ASSET_" ;;
  }

  dimension: did_the_authorized_person_have_prior_training_on_this_type_of_equipment_ {
    type: string
    sql: ${TABLE}."DID_THE_AUTHORIZED_PERSON_HAVE_PRIOR_TRAINING_ON_THIS_TYPE_OF_EQUIPMENT_" ;;
  }

  dimension: email_address {
    type: string
    sql: ${TABLE}."EMAIL_ADDRESS" ;;
  }

  dimension: estimated_loss_amount {
    type: string
    sql: ${TABLE}."ESTIMATED_LOSS_AMOUNT" ;;
  }

  dimension: is_the_customer_asserting_rpp_coverage_ {
    type: string
    sql: ${TABLE}."IS_THE_CUSTOMER_ASSERTING_RPP_COVERAGE_" ;;
  }

  dimension: is_the_customer_paying_for_the_damage_ {
    type: string
    sql: ${TABLE}."IS_THE_CUSTOMER_PAYING_FOR_THE_DAMAGE_" ;;
  }

  dimension: is_there_a_valid_rental_floater_on_file_for_the_customer_ {
    type: string
    sql: ${TABLE}."IS_THERE_A_VALID_RENTAL_FLOATER_ON_FILE_FOR_THE_CUSTOMER_" ;;
  }

  dimension: name_of_customer_s_insurance_company {
    type: string
    sql: ${TABLE}."NAME_OF_CUSTOMER_S_INSURANCE_COMPANY" ;;
  }

  dimension: policy_of_customer_s_insurance_company {
    type: string
    sql: ${TABLE}."POLICY_OF_CUSTOMER_S_INSURANCE_COMPANY" ;;
  }

  dimension: product_make_and_model {
    type: string
    sql: ${TABLE}."PRODUCT_MAKE_AND_MODEL" ;;
  }

  dimension: provide_a_detailed_description_of_the_incident_ {
    type: string
    sql: ${TABLE}."PROVIDE_A_DETAILED_DESCRIPTION_OF_THE_INCIDENT_" ;;
  }

  dimension: select_the_correct_type_of_loss {
    type: string
    sql: ${TABLE}."SELECT_THE_CORRECT_TYPE_OF_LOSS" ;;
  }

  dimension: time_of_incident_ {
    type: string
    sql: ${TABLE}."TIME_OF_INCIDENT_" ;;
  }

  dimension: timestamp {
    type: string
    sql: ${TABLE}."TIMESTAMP" ;;
  }

  dimension: upload_any_supporting_photos_or_document {
    type: string
    sql: ${TABLE}."UPLOAD_ANY_SUPPORTING_PHOTOS_OR_DOCUMENT" ;;
  }

  dimension: upload_photos_of_the_damaged_or_stolen_asset_police_report_if_available_and_or_a_diagram_of_the_accident_if_possible_ {
    type: string
    sql: ${TABLE}."UPLOAD_PHOTOS_OF_THE_DAMAGED_OR_STOLEN_ASSET_POLICE_REPORT_IF_AVAILABLE_AND_OR_A_DIAGRAM_OF_THE_ACCIDENT_IF_POSSIBLE_" ;;
  }

  dimension: was_a_hazardous_material_spill_associated_with_the_incident_ {
    type: string
    sql: ${TABLE}."WAS_A_HAZARDOUS_MATERIAL_SPILL_ASSOCIATED_WITH_THE_INCIDENT_" ;;
  }

  dimension: was_anyone_injured_ {
    type: string
    sql: ${TABLE}."WAS_ANYONE_INJURED_" ;;
  }

  dimension: was_anyone_issued_a_citation_ {
    type: string
    sql: ${TABLE}."WAS_ANYONE_ISSUED_A_CITATION_" ;;
  }

  dimension: was_rpp_placed_on_the_invoice_at_the_time_of_rental_ {
    type: string
    sql: ${TABLE}."WAS_RPP_PLACED_ON_THE_INVOICE_AT_THE_TIME_OF_RENTAL_" ;;
  }

  dimension: was_the_person_authorized_by_the_company_to_operate_the_equipment_ {
    type: string
    sql: ${TABLE}."WAS_THE_PERSON_AUTHORIZED_BY_THE_COMPANY_TO_OPERATE_THE_EQUIPMENT_" ;;
  }

  dimension: were_the_police_called_ {
    type: string
    sql: ${TABLE}."WERE_THE_POLICE_CALLED_" ;;
  }

  dimension: were_there_any_witnesses_to_the_incident_if_so_who_ {
    type: string
    sql: ${TABLE}."WERE_THERE_ANY_WITNESSES_TO_THE_INCIDENT_IF_SO_WHO_" ;;
  }

  dimension: what_is_the_address_where_the_incident_occurred_ {
    type: string
    sql: ${TABLE}."WHAT_IS_THE_ADDRESS_WHERE_THE_INCIDENT_OCCURRED_" ;;
  }

  dimension: what_is_the_address_where_the_incident_occurred_include_the_city_state_street_and_zip_code_ {
    type: string
    sql: ${TABLE}."WHAT_IS_THE_ADDRESS_WHERE_THE_INCIDENT_OCCURRED_INCLUDE_THE_CITY_STATE_STREET_AND_ZIP_CODE_" ;;
  }

  dimension: what_is_the_name_and_phone_of_the_police_department_ {
    type: string
    sql: ${TABLE}."WHAT_IS_THE_NAME_AND_PHONE_OF_THE_POLICE_DEPARTMENT_" ;;
  }

  dimension: what_is_the_name_of_the_person_operating_the_equipment_at_the_time_of_incident_ {
    type: string
    sql: ${TABLE}."WHAT_IS_THE_NAME_OF_THE_PERSON_OPERATING_THE_EQUIPMENT_AT_THE_TIME_OF_INCIDENT_" ;;
  }

  dimension: what_is_the_police_officer_s_name_ {
    type: string
    sql: ${TABLE}."WHAT_IS_THE_POLICE_OFFICER_S_NAME_" ;;
  }

  dimension: what_is_the_police_report_ {
    type: string
    sql: ${TABLE}."WHAT_IS_THE_POLICE_REPORT_" ;;
  }

  dimension: what_is_your_opinion_of_the_applicability_of_rpp_coverage_ {
    type: string
    sql: ${TABLE}."WHAT_IS_YOUR_OPINION_OF_THE_APPLICABILITY_OF_RPP_COVERAGE_" ;;
  }

  dimension: where_is_the_equipment_now_ {
    type: string
    sql: ${TABLE}."WHERE_IS_THE_EQUIPMENT_NOW_" ;;
  }

  dimension: work_order_if_applicable_ {
    type: number
    sql: ${TABLE}."WORK_ORDER_IF_APPLICABLE_" ;;
  }

  measure: count {
    type: count
    drill_fields: [branch_location_name, customer_s_name]
  }
}
