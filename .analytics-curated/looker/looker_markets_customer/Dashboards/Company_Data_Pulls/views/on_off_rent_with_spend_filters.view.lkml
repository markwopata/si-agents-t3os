view: on_off_rent_with_spend_filters {
  derived_table: {
    sql: SELECT
            c.company_id,
            CONCAT(c.company_id, ' - ', c.name) as company
         FROM es_warehouse.public.companies c
         WHERE
          {% if company_filter_list._parameter_value == "'Parent Companies'" %}
          c.company_id IN (SELECT parent_company_id FROM analytics.bi_ops.v_parent_company_relationships)
          {% elsif company_filter_list._parameter_value == "'Managed Billing Companies'" %}
          c.company_id IN
            (SELECT company_id FROM es_warehouse.public.billing_company_preferences
             WHERE PREFS:managed_billing = TRUE)
          {% elsif company_filter_list._parameter_value == "'GSA Companies'" %}
          c.company_id IN
            (SELECT company_id FROM es_warehouse.public.billing_company_preferences
             WHERE PREFS:general_services_administration = TRUE)
          {% else %}
          1 = 1
          {% endif %}
         GROUP BY
          c.company_id,
          c.name
      ;;
  }

  dimension: company_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company {
    type: string
    sql: ${TABLE}."COMPANY" ;;
  }

  parameter: company_filter_list {
    allowed_value: {value: "Parent Companies"}
    allowed_value: {value: "Managed Billing Companies"}
    allowed_value: {value: "GSA Companies"}
    allowed_value: {value: "All Companies"}
  }
}
