view: form_3 {
  sql_table_name: "INSURANCE_FORMS"."FORM_3"
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

  dimension: attach_a_photo_of_the_other_vehicle_s_driver_s_license_ {
    type: string
    sql: ${TABLE}."ATTACH_A_PHOTO_OF_THE_OTHER_VEHICLE_S_DRIVER_S_LICENSE_" ;;
  }

  dimension: attach_photos_of_license_plate_vehicle_damage {
    type: string
    sql: ${TABLE}."ATTACH_PHOTOS_OF_LICENSE_PLATE_VEHICLE_DAMAGE" ;;
  }

  dimension: attach_photos_of_the_insurance_card_ {
    type: string
    sql: ${TABLE}."ATTACH_PHOTOS_OF_THE_INSURANCE_CARD_" ;;
  }

  dimension: branch_location_name {
    type: string
    sql: ${TABLE}."BRANCH_LOCATION_NAME" ;;
  }

  dimension: describe_any_non_vehicular_damage_i_e_fence_building_etc_ {
    type: string
    sql: ${TABLE}."DESCRIBE_ANY_NON_VEHICULAR_DAMAGE_I_E_FENCE_BUILDING_ETC_" ;;
  }

  dimension: describe_the_damage_to_the_trailer_ {
    type: string
    sql: ${TABLE}."DESCRIBE_THE_DAMAGE_TO_THE_TRAILER_" ;;
  }

  dimension: describe_the_damage_to_the_vehicle_ {
    type: string
    sql: ${TABLE}."DESCRIBE_THE_DAMAGE_TO_THE_VEHICLE_" ;;
  }

  dimension: did_the_incident_involve_a_ {
    type: string
    sql: ${TABLE}."DID_THE_INCIDENT_INVOLVE_A_" ;;
  }

  dimension: did_the_incident_involve_another_vehicle_and_or_damage_to_property_ {
    type: string
    sql: ${TABLE}."DID_THE_INCIDENT_INVOLVE_ANOTHER_VEHICLE_AND_OR_DAMAGE_TO_PROPERTY_" ;;
  }

  dimension: email_address {
    type: string
    sql: ${TABLE}."EMAIL_ADDRESS" ;;
  }

  dimension: es_driver_name {
    type: string
    sql: ${TABLE}."ES_DRIVER_NAME" ;;
  }

  dimension: es_passenger_name_if_applicable_ {
    type: string
    sql: ${TABLE}."ES_PASSENGER_NAME_IF_APPLICABLE_" ;;
  }

  dimension: location_of_accident_city_state_street_and_zip_code_ {
    type: string
    sql: ${TABLE}."LOCATION_OF_ACCIDENT_CITY_STATE_STREET_AND_ZIP_CODE_" ;;
  }

  dimension: name_of_the_insurance_company_of_the_other_vehicle_ {
    type: string
    sql: ${TABLE}."NAME_OF_THE_INSURANCE_COMPANY_OF_THE_OTHER_VEHICLE_" ;;
  }

  dimension: name_of_the_other_vehicle_s_driver_ {
    type: string
    sql: ${TABLE}."NAME_OF_THE_OTHER_VEHICLE_S_DRIVER_" ;;
  }

  dimension: please_upload_a_diagram_of_the_accident_ {
    type: string
    sql: ${TABLE}."PLEASE_UPLOAD_A_DIAGRAM_OF_THE_ACCIDENT_" ;;
  }

  dimension: police_officer_s_name {
    type: string
    sql: ${TABLE}."POLICE_OFFICER_S_NAME" ;;
  }

  dimension: police_report_ {
    type: string
    sql: ${TABLE}."POLICE_REPORT_" ;;
  }

  dimension: timestamp {
    type: string
    sql: ${TABLE}."TIMESTAMP" ;;
  }

  dimension: upload_photos_of_the_damaged_vehicle_if_available_ {
    type: string
    sql: ${TABLE}."UPLOAD_PHOTOS_OF_THE_DAMAGED_VEHICLE_IF_AVAILABLE_" ;;
  }

  dimension: was_a_citation_issued_ {
    type: string
    sql: ${TABLE}."WAS_A_CITATION_ISSUED_" ;;
  }

  dimension: was_anyone_in_the_es_vehicle_ {
    type: string
    sql: ${TABLE}."WAS_ANYONE_IN_THE_ES_VEHICLE_" ;;
  }

  dimension: was_anyone_in_the_other_vehicle_injured_ {
    type: string
    sql: ${TABLE}."WAS_ANYONE_IN_THE_OTHER_VEHICLE_INJURED_" ;;
  }

  dimension: was_the_es_vehicle_towed_away_from_the_accident_ {
    type: string
    sql: ${TABLE}."WAS_THE_ES_VEHICLE_TOWED_AWAY_FROM_THE_ACCIDENT_" ;;
  }

  dimension: was_the_other_vehicle_towed_away_from_the_accident_ {
    type: string
    sql: ${TABLE}."WAS_THE_OTHER_VEHICLE_TOWED_AWAY_FROM_THE_ACCIDENT_" ;;
  }

  dimension: were_the_police_called_ {
    type: string
    sql: ${TABLE}."WERE_THE_POLICE_CALLED_" ;;
  }

  dimension: what_is_the_name_and_phone_of_the_police_department_ {
    type: string
    sql: ${TABLE}."WHAT_IS_THE_NAME_AND_PHONE_OF_THE_POLICE_DEPARTMENT_" ;;
  }

  dimension: what_is_the_year_make_model_of_other_vehicle_ {
    type: string
    sql: ${TABLE}."WHAT_IS_THE_YEAR_MAKE_MODEL_OF_OTHER_VEHICLE_" ;;
  }

  dimension: where_is_the_es_vehicle_currently_located_ {
    type: string
    sql: ${TABLE}."WHERE_IS_THE_ES_VEHICLE_CURRENTLY_LOCATED_" ;;
  }

  dimension: who_was_the_citation_issued_to_ {
    type: string
    sql: ${TABLE}."WHO_WAS_THE_CITATION_ISSUED_TO_" ;;
  }

  measure: count {
    type: count
    drill_fields: [branch_location_name, police_officer_s_name, es_driver_name]
  }
}
