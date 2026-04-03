view: dim_companies_bi {
  sql_table_name: "BUSINESS_INTELLIGENCE"."GOLD"."DIM_COMPANIES_BI" ;;

  dimension_group: _created_recordtimestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."_CREATED_RECORDTIMESTAMP" ;;
  }
  dimension_group: _updated_recordtimestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."_UPDATED_RECORDTIMESTAMP" ;;
  }
  dimension: company_activity_status {
    type: string
    sql: ${TABLE}."COMPANY_ACTIVITY_STATUS" ;;
  }
  dimension: company_analytics_mimic_link {
    type: string
    sql: ${TABLE}."COMPANY_ANALYTICS_MIMIC_LINK" ;;
  }

  dimension: company_conversion_status {
    type: string
    sql: ${TABLE}."COMPANY_CONVERSION_STATUS" ;;
  }

  dimension: company_conversion_status_formatted {
    group_label: "Company Conversion Status"
    label: "Conversion Status"
    type: string
    sql: ${TABLE}."COMPANY_CONVERSION_STATUS" ;;
    html:    {% if value == 'Converted' %}
              <span style="background-color:#c1ecd4; padding:2px 4px; border-radius:3px;">
              {{ rendered_value}} </span>
              {% elsif value == 'Pending' %}
               <span style="background-color:#FAEAB5; padding:2px 4px; border-radius:3px;">
              {{ rendered_value}} </span>
              {% elsif value == 'Not Converted' %}
               <span style="background-color:#ffd6d5; padding:2px 4px; border-radius:3px;">
              {{ rendered_value}} </span>
              {% else %}
              <font color="#808080">
              <strong>{{rendered_value}}</strong></font>
              {% endif %}
     ;;
  }

  measure: total_converted_cm {
    group_label: "Company Conversion Status"
    label: "Total Converted Companies"
    type: count_distinct
    sql: CASE WHEN ${company_conversion_status} ilike 'Converted' THEN ${company_id} END ;;
    drill_fields: [conversion_status_detail*]
  }

  measure: total_converted_cm_filter {
    group_label: "Company Conversion Status"
    label: "Total Converted"
    type: count_distinct
    sql: CASE WHEN ${company_conversion_status} ilike 'Converted' THEN ${company_id} END ;;
    filters: [company_conversion_status: "Converted"]
    drill_fields: [conversion_status_detail*]
  }

  measure: total_pending_cm {
    group_label: "Company Conversion Status"
    label: "Total Pending Companies"
    type: count_distinct
    sql: CASE WHEN ${company_conversion_status} ilike 'Pending' THEN ${company_id} END ;;
    drill_fields: [conversion_status_detail*]

  }

  measure: total_pending_cm_filter {
    group_label: "Company Conversion Status"
    label: "Total Pending"
    type: count_distinct
    sql: CASE WHEN ${company_conversion_status} ilike 'Pending' THEN ${company_id} END ;;
    filters: [company_conversion_status: "Pending"]

    drill_fields: [conversion_status_detail*]

  }

  measure: total_not_converted_cm {
    group_label: "Company Conversion Status"
    label: "Total Not Converted Companies"
    type: count_distinct
    sql: CASE WHEN ${company_conversion_status} ilike 'Not Converted' THEN ${company_id} END ;;
    drill_fields: [conversion_status_detail*]

  }


  measure: total_not_converted_cm_filter {
    group_label: "Company Conversion Status"
    label: "Total Not Converted"
    type: count_distinct
    sql: CASE WHEN ${company_conversion_status} ilike 'Not Converted' THEN ${company_id} END ;;
    filters: [company_conversion_status: "Not Converted"]

    drill_fields: [conversion_status_detail*]

  }

  dimension: company_lifetime_rental_status {
    type: string
    sql: ${TABLE}."COMPANY_LIFETIME_RENTAL_STATUS" ;;
  }

  dimension: company_lifetime_rental_status_formatted {
    group_label: "Company Lifetime Rental Status"
    label: "Lifetime Rental Status Status"
    type: string
    sql: ${company_lifetime_rental_status} ;;
    html:    {% if value == 'Has Rented' %}
              <span style="background-color:#c1ecd4; padding:2px 4px; border-radius:3px;">
              {{ rendered_value}} </span>
              {% elsif value == 'Has Reservation' %}
               <span style="background-color:#FAEAB5; padding:2px 4px; border-radius:3px;">
              {{ rendered_value}} </span>
              {% elsif value == 'Never Rented' %}
               <span style="background-color:#ffd6d5; padding:2px 4px; border-radius:3px;">
              {{ rendered_value}} </span>
              {% else %}
              <font color="#808080">
              <strong>{{rendered_value}}</strong></font>
              {% endif %}
     ;;
  }

  measure: total_rented {
    group_label: "Company Lifetime Rental Status"
    label: "Total Rented Companies"
    type: count_distinct
    sql: CASE WHEN ${company_lifetime_rental_status} ilike 'Has Rented' THEN ${company_id} END ;;
    drill_fields: [lifetime_rental_status_detail*]
  }

  measure: total_rented_filter {
    group_label: "Company Lifetime Rental Status"
    label: "Total Rented"
    type: count_distinct
    sql: ${company_id} ;;
    filters: [company_lifetime_rental_status: "Has Rented"]
    drill_fields: [lifetime_rental_status_detail*]
  }

  measure: total_reservation {
    group_label: "Company Lifetime Rental Status"
    label: "Total Reservation Companies"
    type: count_distinct
    sql: CASE WHEN ${company_lifetime_rental_status} ilike 'Has Reservation' THEN ${company_id} END ;;
    drill_fields: [lifetime_rental_status_detail*]

  }

  measure: total_reservation_filter {
    group_label: "Company Lifetime Rental Status"
    label:  "Total Reservation"
    type: count_distinct
    sql: ${company_id} ;;
    filters: [company_lifetime_rental_status: "Has Reservation"]
    drill_fields: [lifetime_rental_status_detail*]

  }

  measure: total_never_rented {
    group_label: "Company Lifetime Rental Status"
    label: "Total Never Rented Companies"
    type: count_distinct
    sql: CASE WHEN ${company_lifetime_rental_status} ilike 'Never Rented' THEN ${company_id} END ;;
    drill_fields: [lifetime_rental_status_detail*]

  }


  measure: total_never_rented_filter {
    group_label: "Company Lifetime Rental Status"
    label: "Total Never Rented"
    type: count_distinct
    sql: ${company_id} ;;
    filters: [company_lifetime_rental_status: "Never Rented"]
    drill_fields: [lifetime_rental_status_detail*]

  }

  dimension: company_credit_limit {
    type: number
    sql: ${TABLE}."COMPANY_CREDIT_LIMIT" ;;
  }
  dimension: company_credit_status {
    type: string
    sql: ${TABLE}."COMPANY_CREDIT_STATUS" ;;
  }
  dimension: company_do_not_rent {
    type: yesno
    sql: ${TABLE}."COMPANY_DO_NOT_RENT" ;;
  }
  dimension: company_fleet_mimic_link {
    type: string
    sql: ${TABLE}."COMPANY_FLEET_MIMIC_LINK" ;;
  }
  dimension: company_has_fleet {
    type: yesno
    sql: ${TABLE}."COMPANY_HAS_FLEET" ;;
  }
  dimension: company_has_fleet_cam {
    type: yesno
    sql: ${TABLE}."COMPANY_HAS_FLEET_CAM" ;;
  }
  dimension: company_has_msa {
    type: yesno
    sql: ${TABLE}."COMPANY_HAS_MSA" ;;
  }
  dimension: company_has_orders {
    type: yesno
    sql: ${TABLE}."COMPANY_HAS_ORDERS" ;;
  }
  dimension: company_has_rentals {
    type: yesno
    sql: ${TABLE}."COMPANY_HAS_RENTALS" ;;
  }
  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
    value_format_name: id
  }
  dimension: company_is_current_vip {
    type: yesno
    sql: ${TABLE}."COMPANY_IS_CURRENT_VIP" ;;
  }
  dimension: company_is_do_not_use {
    type: yesno
    sql: ${TABLE}."COMPANY_IS_DO_NOT_USE" ;;
  }
  dimension: company_is_duplicate {
    type: yesno
    sql: ${TABLE}."COMPANY_IS_DUPLICATE" ;;
  }
  dimension: company_is_eligible_for_payouts {
    type: yesno
    sql: ${TABLE}."COMPANY_IS_ELIGIBLE_FOR_PAYOUTS" ;;
  }
  dimension: company_is_employee {
    type: yesno
    sql: ${TABLE}."COMPANY_IS_EMPLOYEE" ;;
  }
  dimension: company_is_es_internal {
    type: yesno
    sql: ${TABLE}."COMPANY_IS_ES_INTERNAL" ;;
  }
  dimension: company_is_misc {
    type: yesno
    sql: ${TABLE}."COMPANY_IS_MISC" ;;
  }
  dimension: company_is_national_account {
    type: yesno
    sql: ${TABLE}."COMPANY_IS_NATIONAL_ACCOUNT" ;;
  }

  dimension: company_name_and_id_with_na_icon_and_link {
    label: "Company - Link"
    type: string
    sql: ${company_name} ;;
    html:
    {% if company_is_national_account._value == 'No' %}
    <font color="0063f3 "><a href="https://equipmentshare.looker.com/dashboards/28?Company+Name={{ filterable_value | url_encode }}" target="_blank">{{rendered_value}} ➔ </a></font>
          <td>
            <span style="color: #8C8C8C;"> ID: {{company_id._value}} </span>
            </td>
    {% else %}
    <img src="https://cdn-icons-png.flaticon.com/512/63/63811.png" title="National Account" height="15" width="15"> <font color="0063f3 "><a href="https://equipmentshare.looker.com/dashboards/28?Company+Name={{ filterable_value | url_encode }}" target="_blank">{{rendered_value}} ➔ </a></font>
          <td>
            <span style="color: #8C8C8C;"> ID: {{company_id._value}} </span>
            </td>
    {% endif %}
     ;;
  }

  dimension: hidden_companies_name {
    hidden: yes
    type: string
    sql: COALESCE(${company_name}, 'Company Name Unknown') ;;
  }

  dimension: company_and_id_with_na_icon_and_link_int_credit_app {
    label: "Company Link"
    type: string
    sql:  COALESCE(${company_name}, 'Company Name Unknown');;
    html:
    {% if hidden_companies_name._value == 'Company Name Unknown' %}
    <span style="color:#8C8C8C;">
    Company Name Unknown — Company ID: {{ int_credit_app_first_intake_resolved.company_id._value }}
    </span>

    {% elsif company_is_national_account._value == 'No' %}
    <a style="color:#0063f3;" href="https://equipmentshare.looker.com/dashboards/28?Company+Name={{ filterable_value | url_encode }}" target="_blank" rel="noopener">
    {{ rendered_value }} ➔
    </a>
    <br />
    <span style="color:#8C8C8C;">ID: {{ company_id._value }}</span>

    {% else %}
    <img src="https://cdn-icons-png.flaticon.com/512/63/63811.png"
    title="National Account" height="15" width="15" style="vertical-align:middle; margin-right:4px;" />
    <a style="color:#0063f3;" href="https://equipmentshare.looker.com/dashboards/28?Company+Name={{ filterable_value | url_encode }}" target="_blank" rel="noopener">
    {{ rendered_value }} ➔
    </a>
    <br />
    <span style="color:#8C8C8C;">ID: {{ company_id._value }}</span>
    {% endif %}
    ;;
  }


  dimension: company_is_new_account {
    type: yesno
    sql: ${TABLE}."COMPANY_IS_NEW_ACCOUNT" ;;
  }
  dimension: company_is_prospect {
    type: yesno
    sql: ${TABLE}."COMPANY_IS_PROSPECT" ;;
  }
  dimension: company_is_rsp_partner {
    type: yesno
    sql: ${TABLE}."COMPANY_IS_RSP_PARTNER" ;;
  }
  dimension: company_is_soft_deleted {
    type: yesno
    sql: ${TABLE}."COMPANY_IS_SOFT_DELETED" ;;
  }
  dimension: company_is_spam {
    type: yesno
    sql: ${TABLE}."COMPANY_IS_SPAM" ;;
  }
  dimension: company_is_sub_renter_only {
    type: yesno
    sql: ${TABLE}."COMPANY_IS_SUB_RENTER_ONLY" ;;
  }
  dimension: company_is_telematics_service_provider {
    type: yesno
    sql: ${TABLE}."COMPANY_IS_TELEMATICS_SERVICE_PROVIDER" ;;
  }
  dimension: company_is_test {
    type: yesno
    sql: ${TABLE}."COMPANY_IS_TEST" ;;
  }
  dimension: company_is_vip {
    type: yesno
    sql: ${TABLE}."COMPANY_IS_VIP" ;;
  }
  dimension: company_key {
    hidden:  yes
    type: string
    sql: ${TABLE}."COMPANY_KEY" ;;
  }
  dimension: company_merged_to_company_id {
    type: number
    sql: ${TABLE}."COMPANY_MERGED_TO_COMPANY_ID" ;;
  }
  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: company_name_id {
    label: "Company"
    type: string
    sql: concat(${company_name}, ' - ', ${company_id}) ;;
    link: {
      label: "View Customer Information Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/28?Company%20Name={{ company_name._filterable_value | url_encode }}&Company%20ID="
    }

  }

  dimension: company_net_terms {
    type: string
    sql: ${TABLE}."COMPANY_NET_TERMS" ;;
  }
  dimension: company_preferences_bad_debt {
    type: yesno
    sql: ${TABLE}."COMPANY_PREFERENCES_BAD_DEBT" ;;
  }
  dimension: company_preferences_cycle_billing_only {
    type: yesno
    sql: ${TABLE}."COMPANY_PREFERENCES_CYCLE_BILLING_ONLY" ;;
  }
  dimension: company_preferences_disable_monthly_statements {
    type: yesno
    sql: ${TABLE}."COMPANY_PREFERENCES_DISABLE_MONTHLY_STATEMENTS" ;;
  }
  dimension: company_preferences_general_services_administration {
    type: yesno
    sql: ${TABLE}."COMPANY_PREFERENCES_GENERAL_SERVICES_ADMINISTRATION" ;;
  }
  dimension: company_preferences_in_bankruptcy {
    type: yesno
    sql: ${TABLE}."COMPANY_PREFERENCES_IN_BANKRUPTCY" ;;
  }
  dimension: company_preferences_internal_company {
    type: yesno
    sql: ${TABLE}."COMPANY_PREFERENCES_INTERNAL_COMPANY" ;;
  }
  dimension: company_preferences_is_national_account {
    type: yesno
    sql: ${TABLE}."COMPANY_PREFERENCES_IS_NATIONAL_ACCOUNT" ;;
  }
  dimension: company_preferences_is_paperless_billing {
    type: yesno
    sql: ${TABLE}."COMPANY_PREFERENCES_IS_PAPERLESS_BILLING" ;;
  }
  dimension: company_preferences_legal_audit {
    type: yesno
    sql: ${TABLE}."COMPANY_PREFERENCES_LEGAL_AUDIT" ;;
  }
  dimension: company_preferences_managed_billing {
    type: yesno
    sql: ${TABLE}."COMPANY_PREFERENCES_MANAGED_BILLING" ;;
  }
  dimension: company_preferences_primary_billing_contact_user_id {
    type: number
    sql: ${TABLE}."COMPANY_PREFERENCES_PRIMARY_BILLING_CONTACT_USER_ID" ;;
  }
  dimension: company_preferences_rental_billing_cycle_strategy {
    type: string
    sql: ${TABLE}."COMPANY_PREFERENCES_RENTAL_BILLING_CYCLE_STRATEGY" ;;
  }
  dimension: company_rental_billing_cycle_strategy {
    type: string
    sql: ${TABLE}."COMPANY_RENTAL_BILLING_CYCLE_STRATEGY" ;;
  }
  dimension: company_source {
    type: string
    sql: ${TABLE}."COMPANY_SOURCE" ;;
  }
  dimension: company_timezone {
    type: string
    sql: ${TABLE}."COMPANY_TIMEZONE" ;;
  }
  measure: count {
    type: count
    drill_fields: [company_name]
  }

  set: conversion_status_detail {
    fields: [company_and_id_with_na_icon_and_link_int_credit_app,

        salesperson_permissions.rep_home_market_fmt,
        company_conversion_status_formatted,
        company_has_orders ,
        company_has_rentals]
  }

  set: lifetime_rental_status_detail {
    fields: [
      company_and_id_with_na_icon_and_link_int_credit_app,
      salesperson_permissions.rep_home_market_fmt,
      company_lifetime_rental_status_formatted
      ]
  }

}
