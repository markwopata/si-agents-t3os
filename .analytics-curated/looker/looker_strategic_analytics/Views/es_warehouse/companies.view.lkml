
view: companies {
  sql_table_name: es_warehouse.public.companies ;;

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension_group: _es_update_timestamp {
    type: time
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    label: "Company Name"
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: company_name_id {
    label: "Company - Popup Link"
    type: string
    sql: concat(${company_name}, ' - ', ${company_id}) ;;
    link: {
      label: "View Customer Information Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/28?Company%20Name={{ company_name._filterable_value | url_encode }}&Company%20ID="
    }

  }

  dimension: company_name_id_html {
    label: "Company - Embedded Link"
    type: string
    sql: concat(${company_name}, ' - ', ${company_id}) ;;
    html:
    <font color="0063f3 "><a href="https://equipmentshare.looker.com/dashboards/28?Company+Name={{ company_name._filterable_value | url_encode }}" target="_blank">{{company_name._value}} ➔ </a></font>
    <td>
    <span style="color: #8C8C8C;"> ID: {{company_id._value}} </span>
    </td>;;
  }


  dimension: owner_user_id {
    type: string
    sql: ${TABLE}."OWNER_USER_ID" ;;
  }

  dimension: timezone {
    type: string
    sql: ${TABLE}."TIMEZONE" ;;
  }

  dimension: billing_location_id {
    type: string
    sql: ${TABLE}."BILLING_LOCATION_ID" ;;
  }

  dimension: logo_photo_id {
    type: string
    sql: ${TABLE}."LOGO_PHOTO_ID" ;;
  }

  dimension: delivery_vendor {
    type: yesno
    sql: ${TABLE}."DELIVERY_VENDOR" ;;
  }

  dimension: service_vendor {
    type: yesno
    sql: ${TABLE}."SERVICE_VENDOR" ;;
  }

  dimension: supply_vendor {
    type: yesno
    sql: ${TABLE}."SUPPLY_VENDOR" ;;
  }

  dimension: do_not_rent {
    type: yesno
    sql: ${TABLE}."DO_NOT_RENT" ;;
  }

  dimension: billing_provider_id {
    type: string
    sql: ${TABLE}."BILLING_PROVIDER_ID" ;;
  }

  dimension: net_terms_id {
    type: string
    sql: ${TABLE}."NET_TERMS_ID" ;;
  }

  dimension: is_telematics_service_provider {
    type: yesno
    sql: ${TABLE}."IS_TELEMATICS_SERVICE_PROVIDER" ;;
  }

  dimension: is_eligible_for_payouts {
    type: yesno
    sql: ${TABLE}."IS_ELIGIBLE_FOR_PAYOUTS" ;;
  }

  dimension: xero_id {
    type: string
    sql: ${TABLE}."XERO_ID" ;;
  }

  dimension: credit_limit {
    type: number
    sql: ${TABLE}."CREDIT_LIMIT" ;;
    value_format_name: usd
  }

  dimension: elogs_id {
    type: string
    sql: ${TABLE}."ELOGS_ID" ;;
  }

  dimension: white_label_application_id {
    type: string
    sql: ${TABLE}."WHITE_LABEL_APPLICATION_ID" ;;
  }

  dimension: home_office_location_id {
    type: string
    sql: ${TABLE}."HOME_OFFICE_LOCATION_ID" ;;
  }

  dimension: dot_number {
    type: string
    sql: ${TABLE}."DOT_NUMBER" ;;
  }

  dimension: hours_of_service_type_id {
    type: string
    sql: ${TABLE}."HOURS_OF_SERVICE_TYPE_ID" ;;
  }

  dimension: has_fleet {
    type: yesno
    sql: ${TABLE}."HAS_FLEET" ;;
  }

  dimension: has_rentals {
    type: yesno
    sql: ${TABLE}."HAS_RENTALS" ;;
  }

  dimension: i18_n_locale {
    type: string
    sql: ${TABLE}."I18N_LOCALE" ;;
  }

  dimension: i18_n_unit {
    type: string
    sql: ${TABLE}."I18N_UNIT" ;;
  }

  dimension: i18_n_temperature {
    type: string
    sql: ${TABLE}."I18N_TEMPERATURE" ;;
  }

  dimension: ou_id {
    type: string
    sql: ${TABLE}."OU_ID" ;;
  }

  dimension: crm_entity_id {
    type: string
    sql: ${TABLE}."CRM_ENTITY_ID" ;;
  }

  dimension: external_billing_provider_id {
    type: string
    sql: ${TABLE}."EXTERNAL_BILLING_PROVIDER_ID" ;;
  }

  dimension: employer_identification_number {
    type: string
    sql: ${TABLE}."EMPLOYER_IDENTIFICATION_NUMBER" ;;
  }

  dimension: is_rsp_partner {
    type: yesno
    sql: ${TABLE}."IS_RSP_PARTNER" ;;
  }

  dimension: has_fleet_cam {
    type: yesno
    sql: ${TABLE}."HAS_FLEET_CAM" ;;
  }

  dimension: universal_entity_id {
    type: string
    sql: ${TABLE}."UNIVERSAL_ENTITY_ID" ;;
  }

  dimension: authorized_signer_id {
    type: string
    sql: ${TABLE}."AUTHORIZED_SIGNER_ID" ;;
  }

  dimension: has_msa {
    type: yesno
    sql: ${TABLE}."HAS_MSA" ;;
  }

  dimension: doing_business_as {
    type: string
    sql: ${TABLE}."DOING_BUSINESS_AS" ;;
  }

  dimension: business_nature {
    type: string
    sql: ${TABLE}."BUSINESS_NATURE" ;;
  }

  dimension: org_state {
    type: string
    sql: ${TABLE}."ORG_STATE" ;;
  }

  dimension: years_in_business {
    type: string
    sql: ${TABLE}."YEARS_IN_BUSINESS" ;;
  }

  dimension: hide_company_rates_on_dot_com {
    type: yesno
    sql: ${TABLE}."HIDE_COMPANY_RATES_ON_DOT_COM" ;;
  }

  set: detail {
    fields: [
        _es_update_timestamp_time,
  company_id,
  company_name,
  owner_user_id,
  timezone,
  billing_location_id,
  logo_photo_id,
  delivery_vendor,
  service_vendor,
  supply_vendor,
  do_not_rent,
  billing_provider_id,
  net_terms_id,
  is_telematics_service_provider,
  is_eligible_for_payouts,
  xero_id,
  credit_limit,
  elogs_id,
  white_label_application_id,
  home_office_location_id,
  dot_number,
  hours_of_service_type_id,
  has_fleet,
  has_rentals,
  i18_n_locale,
  i18_n_unit,
  i18_n_temperature,
  ou_id,
  crm_entity_id,
  external_billing_provider_id,
  employer_identification_number,
  is_rsp_partner,
  has_fleet_cam,
  universal_entity_id,
  authorized_signer_id,
  has_msa,
  doing_business_as,
  business_nature,
  org_state,
  years_in_business,
  hide_company_rates_on_dot_com
    ]
  }
}
