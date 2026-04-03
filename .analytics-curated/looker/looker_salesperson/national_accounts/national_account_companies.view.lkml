
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

  dimension: customer_name_and_id {
    label: "Customer Name, ID - No Link"
    type: string
    sql: coalesce(${customer_name}, ${companies.name}) ;;
    html:
        {% if customer_name._value == null %}
          <div>
          <span>{{ rendered_value }}</span><br>
          <span style="color: #8C8C8C;">ID: {{ companies.company_id._value }}</span>
          </div>
          {% else %}
          <div>
          <img src="https://cdn-icons-png.flaticon.com/512/63/63811.png" title="National Account" height="15" width="15">
         <span>{{ rendered_value }}</span><br>
          <span style="color: #8C8C8C;">ID: {{ company_id._value }}</span>
          </div>
          {% endif %};;
  }

  dimension: customer_name_and_id_with_na_icon_and_link {
    label: "Customer Name, ID, NA Icon"
    type: string
    sql: coalesce(${customer_name},${companies.name}) ;;
    html:
    {% if customer_name._value == null %}
    <font color="0063f3 "><a href="https://equipmentshare.looker.com/dashboards/28?Company+Name={{ filterable_value | url_encode }}" target="_blank">{{rendered_value}} ➔ </a></font>
          <td>
            <span style="color: #8C8C8C;"> ID: {{companies.company_id._value}} </span>
            </td>
    {% else %}
    <img src="https://cdn-icons-png.flaticon.com/512/63/63811.png" title="National Account" height="15" width="15"> <font color="0063f3 "><a href="https://equipmentshare.looker.com/dashboards/28?Company+Name={{ filterable_value | url_encode }}" target="_blank">{{rendered_value}} ➔ </a></font>
          <td>
            <span style="color: #8C8C8C;"> ID: {{company_id._value}} </span>
            </td>
    {% endif %}
     ;;

    }


  dimension: customer_name_and_id_with_na_icon {
    label: "Customer Name - ID"
    type: string
    sql: coalesce(${customer_and_company_id},${companies.company_name_with_link_to_customer_dashboard}) ;;
    html:
    {% if customer_name._value == null %}
    {{ companies.company_name_with_link_to_customer_dashboard._rendered_value }}
    {% else %}
    <img src="https://cdn-icons-png.flaticon.com/512/63/63811.png" title="National Account" height="15" width="15"> {{ customer_and_company_id._rendered_value }}
    {% endif %}
     ;;
    link: {
      label: "View Customer Information Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/28?Company%20Name={{ customer_name_with_na_icon._filterable_value | url_encode }}&Company%20ID="
    }
  }

  dimension: customer_name_and_id_with_na_icon_for_rate_achievement {
    group_label: "Rate Achievement"
    label: "Customer Name - ID"
    type: string
    sql: coalesce(${customer_and_company_id},${companies.name}) ;;
    html:
    {% if customer_name._value == null %}
    {{ companies.company_name_with_link_to_customer_dashboard._rendered_value }}
    {% else %}
    <img src="https://cdn-icons-png.flaticon.com/512/63/63811.png" title="National Account" height="15" width="15"> {{ customer_and_company_id._rendered_value }}
    {% endif %}
     ;;
    link: {
      label: "View Customer Information Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/28?Company%20Name={{ customer_name_with_na_icon._filterable_value | url_encode }}&Company%20ID="
    }
  }


  set: detail {
    fields: [
      company_id,
      customer_name
    ]
  }
}
