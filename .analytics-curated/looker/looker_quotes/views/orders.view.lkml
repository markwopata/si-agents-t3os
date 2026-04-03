view: orders {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."ORDERS" ;;
  drill_fields: [order_id]

  dimension: order_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."ORDER_ID" ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: accepted_by {
    type: string
    sql: ${TABLE}."ACCEPTED_BY" ;;
  }
  dimension_group: accepted {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."ACCEPTED_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: application_source_id {
    type: number
    sql: ${TABLE}."APPLICATION_SOURCE_ID" ;;
  }
  dimension: application_source_ref {
    type: string
    sql: ${TABLE}."APPLICATION_SOURCE_REF" ;;
  }
  dimension: application_source_ref_id {
    type: string
    sql: ${TABLE}."APPLICATION_SOURCE_REF_ID" ;;
  }
  dimension: approver_user_id {
    type: number
    sql: ${TABLE}."APPROVER_USER_ID" ;;
  }
  dimension: billing_provider_id {
    type: number
    sql: ${TABLE}."BILLING_PROVIDER_ID" ;;
  }
  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }
  dimension: crm_enabled {
    type: yesno
    sql: ${TABLE}."CRM_ENABLED" ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
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
  dimension: job_id {
    type: number
    sql: ${TABLE}."JOB_ID" ;;
  }
  dimension: location_id {
    type: number
    sql: ${TABLE}."LOCATION_ID" ;;
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: order_invoice_memo {
    type: string
    sql: ${TABLE}."ORDER_INVOICE_MEMO" ;;
  }
  dimension: order_status_id {
    type: number
    sql: ${TABLE}."ORDER_STATUS_ID" ;;
  }
  dimension: project_type {
    type: string
    sql: ${TABLE}."PROJECT_TYPE" ;;
  }
  dimension: purchase_order_id {
    type: number
    sql: ${TABLE}."PURCHASE_ORDER_ID" ;;
  }
  dimension: reference {
    type: string
    sql: ${TABLE}."REFERENCE" ;;
  }
  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }
  dimension: sub_renter_id {
    type: number
    sql: ${TABLE}."SUB_RENTER_ID" ;;
  }
  dimension: supplier_company_id {
    type: number
    sql: ${TABLE}."SUPPLIER_COMPANY_ID" ;;
  }
  dimension: universal_contact_id {
    type: number
    sql: ${TABLE}."UNIVERSAL_CONTACT_ID" ;;
  }
  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }


  dimension: timeframe {
    type: string
    sql:
    CASE
      WHEN ${quote_created_date.date_raw} >= {% date_start fact_quotes.user_date_range %}
       AND ${quote_created_date.date_raw} <= {% date_end fact_quotes.user_date_range %}
      THEN 'Current'

      WHEN ${quote_created_date.date_raw} >=
      DATEADD(
      day,
      -DATEDIFF(
      day,
      {% date_start fact_quotes.user_date_range %},
      {% date_end fact_quotes.user_date_range %}
      ),
      {% date_start fact_quotes.user_date_range %}
      )
      AND ${quote_created_date.date_raw} < {% date_start fact_quotes.user_date_range %}
      THEN 'Previous'
      END ;;
  }


  measure: total_count_of_current_orders {
    type: count_distinct
    sql: ${order_id} ;;
    filters: [timeframe: "Current", order_id: "-NULL"]
    html:
    <a href="#drillmenu" style = "color:#000000;" target="_self">
    {{ rendered_value }} {% if difference_in_orders._value > 0 %}

      {% assign indicator = "green,▲" | split: ',' %}

      {% elsif difference_in_orders._value < 0 %}

      {% assign indicator = "red,▼" | split: ',' %}

      {% else %}

      {% endif %}

      <font color="{{indicator[0]}}">

      {% if value == 99999.12345 %} &infin

      {% else %}({{ difference_in_orders._rendered_value }})

      {% endif %} {{indicator[1]}}

      </font>
      </a>;;
    # drill_fields: [quote_info*]
  }


  measure: difference_in_orders {
    type: number
    sql: ${total_count_of_current_orders} - ${total_count_of_previous_orders} ;;
  }

  measure: total_count_of_previous_orders {
    type: count_distinct
    sql: ${order_id};;
    filters: [timeframe: "Previous", order_id: "-NULL"]
    # drill_fields: [order_info*]
  }


  measure: count {
    type: count
    drill_fields: [order_id]
  }
}
