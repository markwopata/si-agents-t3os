view: companies {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."COMPANIES"
    ;;
  drill_fields: [company_id]

  dimension: company_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension_group: _es_update_timestamp {
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
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: billing_location_id {
    type: number
    sql: ${TABLE}."BILLING_LOCATION_ID" ;;
  }

  dimension: billing_provider_id {
    type: number
    sql: ${TABLE}."BILLING_PROVIDER_ID" ;;
  }

  dimension: credit_limit {
    type: number
    sql: ${TABLE}."CREDIT_LIMIT" ;;
  }

  dimension: crm_entity_id {
    type: string
    sql: ${TABLE}."CRM_ENTITY_ID" ;;
  }

  dimension: delivery_vendor {
    type: yesno
    sql: ${TABLE}."DELIVERY_VENDOR" ;;
  }

  dimension: do_not_rent {
    type: yesno
    sql: ${TABLE}."DO_NOT_RENT" ;;
  }

  dimension: dot_number {
    type: string
    sql: ${TABLE}."DOT_NUMBER" ;;
  }

  dimension: elogs_id {
    type: number
    sql: ${TABLE}."ELOGS_ID" ;;
  }

  dimension: employer_identification_number {
    type: string
    sql: ${TABLE}."EMPLOYER_IDENTIFICATION_NUMBER" ;;
  }

  dimension: external_billing_provider_id {
    type: string
    sql: ${TABLE}."EXTERNAL_BILLING_PROVIDER_ID" ;;
  }

  dimension: has_fleet {
    type: yesno
    sql: ${TABLE}."HAS_FLEET" ;;
  }

  dimension: has_fleet_cam {
    type: yesno
    sql: ${TABLE}."HAS_FLEET_CAM" ;;
  }

  dimension: has_rentals {
    type: yesno
    sql: ${TABLE}."HAS_RENTALS" ;;
  }

  dimension: home_office_location_id {
    type: number
    sql: ${TABLE}."HOME_OFFICE_LOCATION_ID" ;;
  }

  dimension: hours_of_service_type_id {
    type: number
    sql: ${TABLE}."HOURS_OF_SERVICE_TYPE_ID" ;;
  }

  dimension: i18_n_locale {
    type: string
    sql: ${TABLE}."I18N_LOCALE" ;;
  }

  dimension: i18_n_temperature {
    type: string
    sql: ${TABLE}."I18N_TEMPERATURE" ;;
  }

  dimension: i18_n_unit {
    type: string
    sql: ${TABLE}."I18N_UNIT" ;;
  }

  dimension: is_eligible_for_payouts {
    type: yesno
    sql: ${TABLE}."IS_ELIGIBLE_FOR_PAYOUTS" ;;
  }

  dimension: is_rsp_partner {
    type: yesno
    sql: ${TABLE}."IS_RSP_PARTNER" ;;
  }

  dimension: is_telematics_service_provider {
    type: yesno
    sql: ${TABLE}."IS_TELEMATICS_SERVICE_PROVIDER" ;;
  }

  dimension: logo_photo_id {
    type: number
    sql: ${TABLE}."LOGO_PHOTO_ID" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: net_terms_id {
    type: number
    sql: ${TABLE}."NET_TERMS_ID" ;;
  }

  dimension: ou_id {
    type: string
    sql: ${TABLE}."OU_ID" ;;
  }

  dimension: owner_user_id {
    type: number
    sql: ${TABLE}."OWNER_USER_ID" ;;
  }

  dimension: service_vendor {
    type: yesno
    sql: ${TABLE}."SERVICE_VENDOR" ;;
  }

  dimension: supply_vendor {
    type: yesno
    sql: ${TABLE}."SUPPLY_VENDOR" ;;
  }

  dimension: timezone {
    type: string
    sql: ${TABLE}."TIMEZONE" ;;
  }

  dimension: universal_entity_id {
    type: number
    sql: ${TABLE}."UNIVERSAL_ENTITY_ID" ;;
  }

  dimension: white_label_application_id {
    type: number
    sql: ${TABLE}."WHITE_LABEL_APPLICATION_ID" ;;
  }

  dimension: xero_id {
    type: string
    sql: ${TABLE}."XERO_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [company_id, name]
  }
}
