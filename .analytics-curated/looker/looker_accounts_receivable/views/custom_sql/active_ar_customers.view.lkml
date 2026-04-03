view: active_ar_customers {
  derived_table: {
    # datagroup_trigger: Every_Two_Hours_Update
    sql: select
        c.company_id,
        c.name as company_name,
        cca.final_collector,
        'Active AR Customer' as active_ar_flag
      FROM
        ES_WAREHOUSE.public.orders  o
        LEFT JOIN ES_WAREHOUSE.public.invoices i ON o.order_id = i.order_id
        LEFT JOIN ES_WAREHOUSE.public.users u ON o.user_id = u.user_id
        LEFT JOIN ES_WAREHOUSE.public.companies c ON u.company_id = c.company_id
        left join gs.collector_customer_assignments cca on cca.company_id = c.company_id::TEXT
      where
        i.paid = false
        and billing_approved = true
      group by
        c.company_id,
        c.name,
        cca.final_collector
 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: active_count {
    type: count
    drill_fields: [final_collector, count]
  }

  dimension: company_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: final_collector {
    type: string
    sql: ${TABLE}."FINAL_COLLECTOR" ;;
  }

  dimension: active_ar_flag {
    type: string
    sql: ${TABLE}."ACTIVE_AR_FLAG" ;;
  }

  set: detail {
    fields: [company_id, company_name, final_collector]
  }
}
