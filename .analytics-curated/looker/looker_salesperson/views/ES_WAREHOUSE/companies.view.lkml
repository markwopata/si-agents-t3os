view: companies {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."COMPANIES"
    ;;
  drill_fields: [company_id]

  dimension: company_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_id_and_name {
    type: string
    sql: concat(${company_id},' - ',${name}) ;;
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
    label: "Company Name"
    type: string
    sql: TRIM(${TABLE}."NAME") ;;
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

  dimension: do_not_rent_string {
    type: string
    sql: case when ${do_not_rent} = 'Yes' then 'DO NOT RENT' ELSE ' ' END ;;
  }

  dimension: company_name_with_link_to_customer_dashboard {
    label: "Company - Customer Link"
    type: string
    sql: concat(${name},' - ',${company_id}) ;;
    link: {
      label: "View Customer Information Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/28?Company%20Name={{ name._filterable_value | url_encode }}&Company%20ID="
    }
  }

  dimension: company_name_with_links {
    label: "Company - T3/Customer Link"
    type: string
    sql: ${name};;
    ##drill_fields: [company_history_details*]
    link: {
      label: "View as Customer in T3 (Tip: Open in incognito mode)"
      url: "{{sales_track_logins.login_link._value }}"
    }
    link: {
      label: "View Customer Information Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/28?Company%20Name={{ name._filterable_value | url_encode }}&Company%20ID="
      }
  }

  dimension: company_name_with_T3_link {
    label: "Company - T3 Link"
    type: string
    html:<font color="blue "><u><a href="{{ sales_track_logins.fleet_login_link._value }}" target="_blank">{{companies.name._value}}</a></font></u> ;;
    sql: ${company_id}  ;;
    link: {
      label: "View Customer Information Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/28?Company%20Name={{ name._filterable_value | url_encode }}&Company%20ID="
    }
  }

  dimension: track_link {
    type: string
    html:<font color="blue "><u><a href="{{ dim_companies_bi.company_fleet_mimic_link._value }}" target="_blank">T3</a></font></u> ;;
    sql: ${company_id}  ;;
  }

  measure: number_of_companies {
    type: count
    drill_fields: [company_id, name]
  }

  measure: number_of_companies_distinct_count {
    type: count_distinct
    sql: ${company_id} ;;
    drill_fields: [name,company_id, equipment_assignments.count]
  }

  dimension: create_note {
    type: string
    html:
    <font color="blue "><u><a href = "https://staging-ba.equipmentshare.com/crm/existing_customer_note?Company%20ID={{ company_id._value | url_encode }}&Company%20Name={{ name._value | url_encode }}" target="_blank">Create Note</a></font></u>;;
    sql: ${TABLE}.COMPANY_ID  ;;}

  dimension: quote_templates {
    type: string
    html:
    <font color="blue "><u><a href = "https://staging-ba.equipmentshare.com/crm/existing_customer_quote_templates?Company%20ID={{ company_id._value | url_encode }}&Company%20Name={{ name._value | url_encode }}" target="_blank">Create Quote</a></font></u>;;
    sql: ${TABLE}.COMPANY_ID  ;;}

  dimension:view_notes {
    type: string
    html:
    <font color="blue "><u><a href = "https://equipmentshare.looker.com/dashboards/235?Company%20ID={{ company_id._value | url_encode }}&Company%20Name={{ name._value | url_encode }}" target="_blank">View Notes</a></font></u>;;
    sql: ${TABLE}.COMPANY_ID  ;;}

  dimension: add_to_homepage {
    type: string
    html:
        <font color="blue "><u><a href = "https://staging-ba.equipmentshare.com/crm/existing_customer_homepage?Company%20ID={{ company_id._value | url_encode }}&Company%20Name={{ name._value  }}&email={{  _user_attributes['email'] }}" target="_blank">Add to Homepage</a></font></u>
        ;;
    sql: ${TABLE}.COMPANY_ID ;;
  }

  set: company_history_details {
    fields: [salesperson.company_activity_feed.company_name,
      salesperson.company_activity_feed.asset_id,
      salesperson.company_activity_feed.status,
      salesperson.company_activity_feed.timestamp_for_activity_date]
  }

}
