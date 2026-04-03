view: orders {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."ORDERS"
    ;;
  drill_fields: [purchase_order_id]

  dimension: purchase_order_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."PURCHASE_ORDER_ID" ;;
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

  dimension: accepted_by {
    type: string
    sql: ${TABLE}."ACCEPTED_BY" ;;
  }

  dimension_group: accepted {
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
    sql: CAST(${TABLE}."ACCEPTED_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: date_created {
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
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: deleted {
    type: yesno
    sql: ${TABLE}."DELETED" ;;
  }

  dimension: delivery_instructions {
    type: string
    sql: ${TABLE}."DELIVERY_INSTRUCTIONS" ;;
  }

  dimension: delivery_required {
    type: yesno
    sql: ${TABLE}."DELIVERY_REQUIRED" ;;
  }

  dimension: external_id {
    type: string
    sql: ${TABLE}."EXTERNAL_ID" ;;
  }

  dimension: insurance_covers_rental {
    type: yesno
    sql: ${TABLE}."INSURANCE_COVERS_RENTAL" ;;
  }

  dimension: insurance_policy_id {
    type: number
    sql: ${TABLE}."INSURANCE_POLICY_ID" ;;
  }

  dimension: location_id {
    type: number
    sql: ${TABLE}."LOCATION_ID" ;;
  }

  dimension: market_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: order_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension: order_status_id {
    type: number
    sql: ${TABLE}."ORDER_STATUS_ID" ;;
  }

  dimension: reference {
    type: string
    sql: ${TABLE}."REFERENCE" ;;
  }

  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: supplier_company_id {
    type: number
    sql: ${TABLE}."SUPPLIER_COMPANY_ID" ;;
  }

  dimension: user_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: view_rates_button {
    type: string
    sql: 'View Rates'  ;;

    link: {
      label: "View Rates"
      url: "https://equipmentshare.looker.com/dashboards/183"
    }
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # dimension: create_note {
  #   type: string
  #   html:
  #   <font color="blue "><u><a href = "https://staging-ba.equipmentshare.com/crm/existing_customer_note?Company%20ID={{ company_id._value | url_encode }}&Company%20Name={{ name._value | url_encode }}" target="_blank">Create Note</a></font></u>;;
  #   sql: ${TABLE}.company_id  ;;}

  # dimension: quote_templates {
  #   type: string
  #   html:
  #   <font color="blue "><u><a href = "https://staging-ba.equipmentshare.com/crm/existing_customer_quote_templates?Company%20ID={{ company_id._value | url_encode }}&Company%20Name={{ name._value | url_encode }}" target="_blank">Create Quote</a></font></u>;;
  #   sql: ${TABLE}.company_id  ;;}

  # dimension:view_notes {
  #   type: string
  #   html:
  #   <font color="blue "><u><a href = "https://equipmentshare.looker.com/dashboards/235?Company%20ID={{ company_id._value | url_encode }}&Company%20Name={{ name._value | url_encode }}" target="_blank">View Notes</a></font></u>;;
  #   sql: ${TABLE}.company_id  ;;}




  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      purchase_order_id,
      users.middle_name,
      users.last_name,
      users.user_id,
      users.first_name,
      users.company_name,
      users.username,
      markets.canonical_name,
      markets.market_id,
      markets.name,
      orders.purchase_order_id,
      invoices.count,
      orders.count,
      rentals.count
    ]
  }
}
