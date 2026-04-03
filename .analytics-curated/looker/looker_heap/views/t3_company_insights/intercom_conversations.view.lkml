view: intercom_conversations {
  derived_table: {
    sql:
    SELECT
      c.id AS conversation_id,
      c.custom_type AS general_topic,
      ch.email,
      ch.name AS contact_name,
      COALESCE(ch.custom_company_id, u.company_id) AS company_id,
      iff(property_t_3_subscriber_status LIKE '%VIP%', 'Yes', 'No') as vip_customer,
      t.name AS tag_name
    FROM
      ANALYTICS.INTERCOM.CONVERSATION_HISTORY c
    LEFT JOIN (
      SELECT id, name, email, custom_company_id
      FROM ANALYTICS.INTERCOM.CONTACT_HISTORY
      QUALIFY ROW_NUMBER() OVER (PARTITION BY id ORDER BY updated_at DESC) = 1
    ) ch ON ch.id = c.source_author_id
    LEFT JOIN ANALYTICS.INTERCOM.CONVERSATION_TAG_HISTORY cth
      ON cth.conversation_id = c.id
      AND cth._fivetran_active = TRUE
      AND cth.tag_id NOT IN (9116447, 9116594, 9141622)
    LEFT JOIN ANALYTICS.INTERCOM.TAG t ON t.id = cth.tag_id
    LEFT JOIN es_warehouse.public.users u ON u.email_address = ch.email
    LEFT JOIN analytics.hubspot_customer_success.company hsc on u.company_id = try_cast(property_es_admin_id as int)
    WHERE
      convert_timezone('America/Chicago', c.created_at)::date
      BETWEEN DATEADD(days, -30, CURRENT_DATE()) AND CURRENT_DATE()
      AND c.source_type = 'conversation'
      AND t.id NOT IN (9116447, 9116594, 9141622)
      AND UPPER(t.name) NOT LIKE '%BRE -%'
      AND company_id IS NOT NULL
      AND company_id <> '1854'  ;;
  }

  # Dimensions
  dimension: conversation_id {
    type: string
    primary_key: yes
    sql: ${TABLE}.conversation_id ;;
  }

  dimension: general_topic {
    type: string
    sql: ${TABLE}.general_topic ;;
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}.company_id ;;
  }

  dimension: tag_name {
    type: string
    sql: ${TABLE}.tag_name ;;
  }

  dimension: contact_name {
    type: string
    sql: ${TABLE}.contact_name ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}.email ;;
  }

  dimension: vip_customer {
    type: string
    sql: ${TABLE}.vip_customer ;;
  }

  # Measures
  measure: total_conversations {
    type: count_distinct
    sql: ${conversation_id} ;;
  }

  measure: unique_companies {
    type: count_distinct
    sql: ${TABLE}.company_id ;;
  }
}
