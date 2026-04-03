
view: national_account_companies {
  sql_table_name: business_intelligence.triage.stg_t3__national_account_assignments ;;



  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: customer_name {
    type: string
    sql: ${TABLE}."COMPANY" ;;
  }

  dimension: parent_company_id {
    type: number
    sql: ${TABLE}."PARENT_COMPANY_ID" ;;
  }

  dimension: parent_company_name {
    type: string
    sql: ${TABLE}."PARENT_COMPANY_NAME" ;;
  }

  dimension: sales_manager_name {
    type: string
    sql: ${TABLE}."EFFECTIVE_NAM" ;;
  }

  dimension: customer_and_company_id {
    type: string
    sql: concat(${customer_name}, ' - ', ${company_id}) ;;
  }

  dimension: customer_name_with_na_icon {
    label: "Customer"
    type: string
    sql: coalesce(${customer_name},${companies.name}) ;;
  }

  dimension: customer_name_and_id_with_na_icon {
    label: "Customer Name - ID"
    type: string
    sql: coalesce(${customer_and_company_id},${companies.company_name_and_id_with_link_to_customer_dashboard}) ;;
    html:
    {% if customer_name._value == null %}
    {{ companies.company_name_with_link_to_customer_dashboard._rendered_value }}
    {% else %}
    <img src="https://cdn-icons-png.flaticon.com/512/63/63811.png" title="National Account" height="15" width="15"> {{ customer_and_company_id._rendered_value }}
    {% endif %}
     ;; #shield with star icon
  }

  dimension: customer_dashboard_customer_name_and_id_with_na_icon {
    group_label: "Customer Dashboard"
    label: "Customer Name - ID"
    type: string
    sql: coalesce(${customer_and_company_id},${companies.company_name_and_id_with_link_to_customer_dashboard}) ;;
    html:
    {% if customer_name._value == null %}
    {{ companies.company_name_and_id_with_link_to_customer_dashboard._rendered_value }}
    {% else %}
    <img src="https://cdn-icons-png.flaticon.com/512/63/63811.png" title="National Account" height="30" width="30"> {{ customer_and_company_id._rendered_value }}
    {% endif %}
     ;; #shield with star icon
  }


  set: detail {
    fields: [
        company_id,
  customer_name
    ]
  }
}
