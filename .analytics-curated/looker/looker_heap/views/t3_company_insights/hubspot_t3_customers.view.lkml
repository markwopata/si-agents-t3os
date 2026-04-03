view: hubspot_t3_customers {
  derived_table: {
    sql:
    SELECT
      hsc.property_es_admin_id AS company_id,
      c.name AS company_name,
      hsc.property_track_rep AS account_executive,
      hsc.property_t_3_customer_success_agent AS enablement_specialist,
      hsc.property_sales_engineer AS sales_engineer,
      hsc.property_technology_region AS region,
      IFF(hsc.property_t_3_subscriber_status LIKE '%VIP%', TRUE, FALSE) AS vip_customer,
      IFF(hsc.property_t_3_subscriber_status LIKE '%Camera%', TRUE, FALSE) AS camera_customer,
      IFF(hsc.property_t_3_subscriber_status LIKE '%T3aaS%', TRUE, FALSE) AS t3aas_customer
    FROM
      ANALYTICS.HUBSPOT_CUSTOMER_SUCCESS.COMPANY hsc
    JOIN es_warehouse.public.companies c
      ON hsc.property_es_admin_id::TEXT = c.company_id::TEXT
    WHERE
      (hsc.property_es_admin_id IS NOT NULL OR hsc.property_es_admin_id <> '')
      AND hsc.is_deleted = FALSE
      AND hsc.property_t_3_subscriber_status LIKE '%Current T3 Customer%' ;;
  }

  # Dimensions
  dimension: company_id {
    type: string
    primary_key: yes
    sql: ${TABLE}.company_id ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}.company_name ;;
    label: "Company"
  }

  dimension: account_executive {
    type: string
    sql: ${TABLE}.account_executive ;;
  }

  dimension: enablement_specialist {
    type: string
    sql: ${TABLE}.enablement_specialist ;;
  }

  dimension: sales_engineer {
    type: string
    sql: ${TABLE}.sales_engineer ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}.region ;;
  }

  dimension: vip_customer {
    type: yesno
    sql: ${TABLE}.vip_customer ;;
  }

  dimension: camera_customer {
    type: yesno
    sql: ${TABLE}.camera_customer ;;
  }

  dimension: t3aas_customer {
    type: yesno
    sql: ${TABLE}.t3aas_customer ;;
  }

  # Measures

  measure: count {
    type: count
    description: "Count of T3 customers returned by the query."
  }

  measure: total_vip_customers {
    type: count
    filters: [vip_customer: "yes"]
    description: "Count of VIP customers."
  }

  measure: distinct_companies {
    type: count_distinct
    sql: ${company_id} ;;
    description: "Number of distinct companies."
  }

  set: detail {
    fields: [
      company_id,
      company_name,
      account_executive,
      enablement_specialist,
      sales_engineer,
      region,
      vip_customer,
      camera_customer,
      t3aas_customer
    ]
  }
}
