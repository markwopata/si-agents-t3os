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

  dimension: contractor_owned_ind {
    type: string
    sql: CASE WHEN ${is_eligible_for_payouts} = TRUE THEN 'Contractor Owned' ELSE 'Not Contractor Owned' END ;;
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

  dimension: xero_link {
    type: string
    sql: ${xero_id} ;;
    html: <font color="blue "><u><a href="https://go.xero.com/Contacts/View/{{ companies.xero_id._value }}" target="_blank">Xero</a></font></u> ;;
  }

  measure: number_of_companies {
    type: count
    drill_fields: [company_id, name]
  }

  measure: number_of_companies_distinct_count {
    type: count_distinct
    sql: ${company_id} ;;
    drill_fields: [name,company_id, equipment_assignments.count]
    #drill_fields: [company_id, name, equipment_assignments.asset_id, equipment_assignments.start_date, equipment_assignments.end_date]
  }

  dimension: company_name_with_net_terms {
    type: string
    sql: concat(${name},' : ', ${net_terms.name}) ;;

    link: {
      label: "View Customer Information Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/28?Company%20Name={{ name._filterable_value | url_encode }}&Company%20ID="
    }

    link: {
      label: "View Customer Collectors Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/13?%5Bcompanies.company_name_with_net_terms%5D=&Invoice+Number=&Invoice+Date=90+day&Company+Name+with+Net+Terms={{ companies.company_name_with_net_terms._filterable_value | url_encode }}"
    }
    description: "This links out to the AR customer dashboard"
  }

  dimension: last_day_of_month {
    hidden: yes
    type: string
    sql: to_char(date_trunc('month', now())::date - 1, 'MM-DD-YYYY') ;;
  }

  dimension: admin_link {
    type: string
    html: <font color="blue "><u><a href="https://admin.equipmentshare.com/#/home/companies/{{ companies.company_id._value }}/transactions/invoices?status=all&start={{ companies.last_day_of_month.value }}" target="_blank">Admin</a></font></u> ;;
    sql: ${company_id}  ;;
  }

  dimension: track_link {
    type: string
    html:<font color="blue "><u><a href="{{ sales_track_logins.login_link._value }}" target="_blank">Track</a></font></u> ;;
    # html: <font color="blue "><u><a href="#" onclick='window.open("{{ sales_track_logins.login_link._value }}","_blank");return false;'>Track</a></font></u> ;;
    sql: ${company_id}  ;;
  }

  dimension: company_id_link_to_customer_dashboard {
    type: number
    sql: ${company_id} ;;

    link: {
      label: "View Customer Collectors Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/13?%5Bcompanies.company_name_with_net_terms%5D=&Invoice+Number=&Invoice+Date=90+day&Company+Name+with+Net+Terms=&Company+ID={{ value | url_encode }}"
    }
    description: "This links out to the AR customer dashboard"
  }

  dimension: company_id_link_to_customer_info_dashboard {
    type: number
    sql: ${company_id} ;;

    link: {
      label: "View Customer Information Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/28?Company%20Name=&Company%20ID={{ value | url_encode }}"
    }
    description: "This links out to the Customer Info Dashboard"
  }

  dimension: do_not_rent_string {
    type: string
    sql: case when ${do_not_rent} = 'Yes' then 'DO NOT RENT' ELSE ' ' END ;;
  }

  dimension: company_name_with_link_to_customer_dashboard {
    type: string
    sql: ${name} ;;

    link: {
      label: "View Customer Information Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/28?Company%20Name={{ name._filterable_value | url_encode }}&Company%20ID="
    }

  }

  dimension: submit_note {
    type: string
    html: <font color="blue "><u><a href = "https://docs.google.com/forms/d/e/1FAIpQLSc9BH1zaMNFdfHcBWKVi6I3ib-6QHwcYjffYqd8zlhX1zYgvg/viewform?usp=pp_url&entry.503989311={{ companies.company_id._value }}&entry.1734875336={{ users.passing_user_id_from_logged_in_looker_user._value }}&entry.626077242=Accounts+Receivable" target="_blank">Submit Note</a></font></u> ;;
    sql: ${company_id} ;;
  }

  dimension: company_name_with_id {
    type: string
    sql: concat(${name}, ' - ',${company_id}) ;;
  }

  dimension: create_prospect {
    type: string
    html: <font color="blue "><u><a href = "https://docs.google.com/forms/d/e/1FAIpQLSeQ2ZbaOfmI2NoNhvWJWxtmVMT9ZfrMOGtpKOX-3BeZFKukDw/viewform?usp=pp_url&entry.1265378221={{  _user_attributes['email'] }}" target="_blank">Create Prospect</a></font></u> ;;
    sql: (select ${TABLE}.user_id from users where ${TABLE}.email_address = '{{ _user_attributes['email'] }}')  ;;
  }

  measure: count {
    type: count
    drill_fields: [company_id, name]
  }
}
