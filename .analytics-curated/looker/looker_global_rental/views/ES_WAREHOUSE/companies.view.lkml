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

  dimension: delivery_vendor {
    type: yesno
    sql: ${TABLE}."DELIVERY_VENDOR" ;;
  }

  dimension: do_not_rent {
    type: yesno
    sql: ${TABLE}."DO_NOT_RENT" ;;
  }

  dimension: is_eligible_for_payouts {
    type: yesno
    sql: ${TABLE}."IS_ELIGIBLE_FOR_PAYOUTS" ;;
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
    label: "Company"
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: net_terms_id {
    type: number
    sql: ${TABLE}."NET_TERMS_ID" ;;
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

  dimension: xero_id {
    type: string
    sql: ${TABLE}."XERO_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [company_id, name]
  }
}
