view: orders {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."ORDERS" ;;

  dimension: order_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension: salesperson_user_id {
    type: string
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: order_status_id {
    type: string
    sql: ${TABLE}."ORDER_STATUS_ID" ;;
  }

  dimension: insurance_policy_id {
    type: string
    sql: ${TABLE}."INSURANCE_POLICY_ID" ;;
  }

  dimension: user_id {
    type: string
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: location_id {
    type: string
    sql: ${TABLE}."LOCATION_ID" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: supplier_company_id {
    type: string
    sql: ${TABLE}."SUPPLIER_COMPANY_ID" ;;
  }

  dimension: purchase_order_id {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_ID" ;;
  }

  dimension: job_id {
    type: string
    sql: ${TABLE}."JOB_ID" ;;
  }

  dimension: universal_contact_id {
    type: string
    sql: ${TABLE}."UNIVERSAL_CONTACT_ID" ;;
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: application_source_id {
    type: string
    sql: ${TABLE}."APPLICATION_SOURCE_ID" ;;
  }

  dimension: billing_provider_id {
    type: string
    sql: ${TABLE}."BILLING_PROVIDER_ID" ;;
  }

  dimension: sub_renter_id {
    type: string
    sql: ${TABLE}."SUB_RENTER_ID" ;;
  }

  dimension: approver_user_id {
    type: string
    sql: ${TABLE}."APPROVER_USER_ID" ;;
  }

  dimension: reference {
    type: string
    sql: ${TABLE}."REFERENCE" ;;
  }

  dimension: accepted_by {
    type: string
    sql: ${TABLE}."ACCEPTED_BY" ;;
  }

  dimension: delivery_instructions {
    type: string
    sql: ${TABLE}."DELIVERY_INSTRUCTIONS" ;;
  }

  dimension: external_id {
    type: string
    sql: ${TABLE}."EXTERNAL_ID" ;;
  }

  dimension: order_invoice_memo {
    type: string
    sql: ${TABLE}."ORDER_INVOICE_MEMO" ;;
  }

  dimension: project_type {
    type: string
    sql: ${TABLE}."PROJECT_TYPE" ;;
  }

  dimension: application_source_ref_id {
    type: string
    sql: ${TABLE}."APPLICATION_SOURCE_REF_ID" ;;
  }

  dimension: application_source_ref {
    type: string
    sql: ${TABLE}."APPLICATION_SOURCE_REF" ;;
  }

  dimension: delivery_required {
    type: yesno
    sql: ${TABLE}."DELIVERY_REQUIRED" ;;
  }

  dimension: insurance_covers_rental {
    type: yesno
    sql: ${TABLE}."INSURANCE_COVERS_RENTAL" ;;
  }

  dimension: deleted {
    type: yesno
    sql: ${TABLE}."DELETED" ;;
  }

  dimension: crm_enabled {
    type: yesno
    sql: ${TABLE}."CRM_ENABLED" ;;
  }

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }

  dimension_group: date_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension_group: accepted_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."ACCEPTED_DATE" ;;
  }

  set: detail_drill {
    fields: [order_id, reference, company_id, location_id, market_id, date_created_date]
  }

  measure: count {
    type: count
    drill_fields: [detail_drill*]
  }
}
