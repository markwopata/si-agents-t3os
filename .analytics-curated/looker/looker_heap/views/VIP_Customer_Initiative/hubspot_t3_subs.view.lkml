view: hubspot_t3_subs {
  sql_table_name: (select
      hsc.property_es_admin_id as company_id,
      c.name as company_name,
      hsc.property_track_rep as account_executive,
      hsc.property_t_3_customer_success_agent as enablement_specialist,
      hsc.property_sales_engineer as sales_engineer,
      hsc.property_technology_region as region,
      IFF(hsc.property_t_3_subscriber_status like '%VIP%',TRUE,FALSE) as vip_customer,
      IFF(hsc.property_t_3_subscriber_status like '%Camera%',TRUE,FALSE) as camera_customer,
      IFF(hsc.property_t_3_subscriber_status like '%T3aaS%',TRUE,FALSE) as t3aas_customer
  from
      ANALYTICS.HUBSPOT_CUSTOMER_SUCCESS.COMPANY hsc
      join es_warehouse.public.companies c on hsc.property_es_admin_id::text = c.company_id::text
  where
      (hsc.property_es_admin_id is not null or hsc.property_es_admin_id <> '')
      AND hsc.is_deleted = FALSE
      AND hsc.property_t_3_subscriber_status like '%Current T3 Customer%') ;;


  dimension: company_id {
    sql: ${TABLE}.company_id ;;
    type: string
  }

  dimension: company_name {
    sql: ${TABLE}.company_name ;;
    type: string
  }

  dimension: account_executive {
    sql: ${TABLE}.account_executive ;;
    type: string
  }

  dimension: vip_customer {
    sql: ${TABLE}.vip_customer ;;
    type: yesno
  }

  dimension: camera_customer {
    sql: ${TABLE}.camera_customer ;;
    type: yesno
  }

  dimension: t3aas_customer {
    sql: ${TABLE}.t3aas_customer ;;
    type: yesno
  }

  measure: total_companies {
    type: count_distinct
    sql: ${company_id} ;;
    label: "Total Companies"
  }

  measure: total_vip_customers {
    type: count
    filters: [vip_customer: "yes"]
    sql: ${company_id} ;;
    label: "Total VIP Customers"
  }

  measure: total_camera_customers {
    type: count
    filters: [camera_customer: "yes"]
    sql: ${company_id} ;;
    label: "Total Camera Customers"
  }

  measure: total_t3aas_customers {
    type: count
    filters: [t3aas_customer: "yes"]
    sql: ${company_id} ;;
    label: "Total T3aaS Customers"
  }

}

#   }
#
#   dimension: lifetime_orders {
#     description: "The total number of orders for each user"
#     type: number
#     sql: ${TABLE}.lifetime_orders ;;
#   }
#
#   dimension_group: most_recent_purchase {
#     description: "The date when each user last ordered"
#     type: time
#     timeframes: [date, week, month, year]
#     sql: ${TABLE}.most_recent_purchase_at ;;
#   }
#
#   measure: total_lifetime_orders {
#     description: "Use this for counting lifetime orders across many users"
#     type: sum
#     sql: ${lifetime_orders} ;;
#   }
# }
