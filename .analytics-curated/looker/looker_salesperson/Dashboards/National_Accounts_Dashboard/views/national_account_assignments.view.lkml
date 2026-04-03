view: national_account_assignments {
  sql_table_name: business_intelligence.triage.stg_t3__national_account_assignments ;;



  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
    value_format: "0"
  }

  dimension: company {
    type: string
    sql: ${TABLE}."COMPANY";;
  }

  dimension: region {
    type: number
    sql: ${TABLE}."REGION";;
  }

  dimension: director_user_id {
    type: number
    sql: ${TABLE}."SALES_DIRECTOR_USER_ID";;
  }

  dimension: sales_director {
    type: string
    sql: ${TABLE}."SALES_DIRECTOR";;
  }

  dimension: nam_user_id {
    type: number
    sql: ${TABLE}."EFFECTIVE_NAM_USER_ID";;
  }

  dimension: national_account_manager {
    type: string
    sql: ${TABLE}."EFFECTIVE_NAM";;
  }

  dimension: nam_email {
  type: string
  sql:  ${TABLE}."EFFECTIVE_NAM_EMAIL";;
  }


  dimension: coordinator_user_id {
    type: number
    sql: ${TABLE}."COORDINATOR_USER_ID";;
  }

  dimension: national_account_coordinator {
    type: string
    sql: ${TABLE}."NATIONAL_ACCOUNT_COORDINATOR";;
  }

  dimension: NAC_2 {
    type: string
    label: "NAC-2"
    sql: ${TABLE}."NAC_2" ;;
  }

  dimension: NAC_3 {
    type: string
    label: "NAC-3"
    sql: ${TABLE}."NAC_3" ;;
  }

  dimension: net_term {
    type: string
    sql: ${net_terms.name};;
  }

  dimension: admin_link {
    type: string
    sql: CONCAT('https://admin.equipmentshare.com/#/home/companies/', ${company_id}::varchar);;
    html: "<a href='https://admin.equipmentshare.com/#/home/companies/{{ company_id._value }}' target='_blank'>
    <font color='#DA344D'>Open in Admin</font>
    </a>";;

  }

  dimension: parent_company_id {
    type: number
    sql: ${TABLE}."PARENT_COMPANY_ID";;
  }

  dimension: parent_company {
    type: string
    sql: ${TABLE}."PARENT_COMPANY_NAME";;
  }

  dimension: general_services_administration {
    type: yesno
    sql:  CASE WHEN concat(${TABLE}."GSA") = 'true' then TRUE ELSE FALSE END;;
  }

  measure: gsa_avg {
    type: average
    sql: CASE WHEN concat(${TABLE}."GSA") = 'true' then 1 ELSE 0 END ;;
  }

  dimension: managed_billing {
    type: yesno
    sql: CASE WHEN concat(${TABLE}."MANAGED_BILLING") = 'true' then TRUE ELSE FALSE END;;
  }

  measure: managed_billing_avg {
    type: average
    sql: CASE WHEN concat(${TABLE}."MANAGED_BILLING") = 'true' then 1 ELSE 0 END  ;;
  }

  dimension: account_folder_url {
    type: string
    sql: ${TABLE}."ACCOUNT_FOLDER_URL" ;;
  }

  dimension: notes {
    type: string
    sql: ${TABLE}."NOTES" ;;
  }

  measure: company_count {
    type: count_distinct
    sql: ${company} ;;
  }

  measure: all_nams {
    type: string
    sql: LISTAGG(DISTINCT ${national_account_manager}, ', ')
      WITHIN GROUP (ORDER BY ${national_account_manager}) ;;
  }

  measure: company_card {
    type: string
    sql: 'this is filler text';;
    html:
    {% if company._is_filtered %}
    <div style="font-size: 1.75rem; line-height: 1; text-align: left">
      <strong>{{company._value}}</strong>
    </div>
    <div style="font-size: 1.25rem; line-height: 1; text-align: left">
      {{net_term._value}}{% if gsa_avg._value == 1 %}, GSA{% endif %}{% if managed_billing_avg._value == 1 %}, Managed Billing{% endif %}<br/><br/>
      <strong>Sales Director: </strong>{{sales_director._value}}&emsp;&emsp;<strong>Region: </strong>{{region._value}}<br/><br/>
      <strong>National Account Manager: </strong>{{national_account_manager._value}}<br/><br/>
      <strong>National Account Coordinator: </strong>{{national_account_coordinator._value}}<br/><br/>
      <strong>Links:</strong>
      <a href="{{admin_link._value}}" target="_blank">Admin </a>&emsp;<a href="{{account_folder_url}}" target="_blank">Google Drive</a>
    </div>
    {% elsif parent_company._is_filtered %}
    <div style="font-size: 1.75rem; line-height: 1; text-align: left">
      <strong>{{parent_company._value}}</strong><br/><br/>
    </div>
    <div style="font-size: 1.25rem; line-height: 1; text-align: left">
      <strong>Total Accounts in Group: </strong>{{company_count._value}}<br/><br/>
      <strong>National Account Manager: </strong>{{all_nams._value}}<br/><br/>
    </div>
    {% else %}
    No Company Selected
    {% endif %}
    ;;
  }

  measure: managed_billing_sum {
    type: sum
    sql: CASE WHEN concat(${TABLE}."MANAGED_BILLING") = 'true' then 1 ELSE 0 END ;;
    value_format_name: "decimal_0"
  }
  measure: gsa_sum {
    type: sum
    sql: CASE WHEN concat(${TABLE}."GSA") = 'true' then 1 ELSE 0 END ;;
    value_format_name: "decimal_0"
  }

  measure: nam_card {
    type: string
    sql: ${national_account_manager};;
    html:
    {% if national_account_manager._is_filtered %}
    <div style="font-size: 1.75rem; line-height: 1; text-align: left">
      <strong>{{national_account_manager._value}}</strong><br/><br/>
    </div>
    <div style="font-size: 1.25rem; line-height: 1; text-align: left">
      <strong>National Accounts Assigned: </strong>{{company_count._value}}<br/><br/>
      <strong>Managed Billing Accounts: </strong>{{managed_billing_sum._rendered_value}}<br/><br/>
      <strong>GSA Accounts: </strong>{{gsa_sum._rendered_value}}
    </div>
    {% else %}
    No NAM Selected
    {% endif %}
    ;;
  }
}
