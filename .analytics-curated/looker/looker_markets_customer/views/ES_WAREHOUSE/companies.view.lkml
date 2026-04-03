view: companies {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."COMPANIES"
    ;;
  drill_fields: [company_id]

  dimension: company_id {
    primary_key: yes
    type: number
    value_format: "0"
    sql: CASE WHEN TRIM(${TABLE}."COMPANY_ID") = '' OR ${TABLE}."COMPANY_ID" IS NULL THEN 0 ELSE ${TABLE}."COMPANY_ID"::INT END;;
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

  dimension: authorized_signer_id {
    type: number
    sql: ${TABLE}."AUTHORIZED_SIGNER_ID" ;;
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
    sql: TRIM(REPLACE(${TABLE}."NAME",CHAR(9), '')) ;;
    suggest_persist_for: "2 hours"
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

  dimension: company_name_with_link_to_customer_dashboard {
    type: string
    sql: ${name} ;;
    link: {
      label: "View Customer Information Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/28?Company%20Name={{ name._filterable_value | url_encode }}&Company%20ID={{ company_id._filterable_value | url_encode }}"
    }
  }

# Commented out due to missing variable/dimension last_day_of_month
  # dimension: admin_link {
  #   type: string
  #   html: <font color="blue "><u><a href="https://admin.equipmentshare.com/#/home/companies/{{ companies.company_id._value }}/transactions/invoices?status=all&start={{ companies.last_day_of_month.value }}" target="_blank">Admin</a></font></u> ;;
  #   sql: ${company_id}  ;;
  # }

  dimension: track_link {
    type: string
    label: "T3 Link"
    # html:<font color="blue "><u><a href="{{ sales_track_logins.fleet_login_link._value }}" target="_blank">T3</a></font></u>;;
    html: <a href="{{ sales_track_logins.fleet_login_link._value }}" target="_blank" style="color: #0063f3; text-decoration: underline;">T3</a> ;;
    sql: ${company_id}  ;;
  }

  dimension: analytics_and_track_link {
    type: string
    label: "Analytics and T3 Link"
    html:<p><font color="blue "><u><a href="{{ dim_companies_bi.company_fleet_mimic_link._value }}" target="_blank">T3 Fleet</a></font></u></p>
         <p><font color="blue "><u><a href="{{ dim_companies_bi.company_analytics_mimic_link._value }}" target="_blank">T3 Analytics</a></font></u></p>
         <p><font color="blue "><u><a href="https://quotes.estrack.com/new" target="_blank">Create New <br> Quote</a></font></u></p>;;
    sql: ${company_id}  ;;
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

  dimension: company_name_and_id_with_link_to_customer_dashboard {
    type: string
    sql: concat(${name},' - ',${company_id}) ;;
    link: {
      label: "View Customer Information Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/28?Company%20Name={{ name._filterable_value | url_encode }}&Company%20ID="
    }
  }

  measure: number_of_companies {
    type: count
    drill_fields: [company_id, name]
  }
}
