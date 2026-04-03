view: invoices {
  sql_table_name: "GLOBAL_BILLING"."GLOBAL_BILLING"."INVOICES" ;;
  # sql_table_name: "PUBLIC"."INVOICES"
    # ;;
  # drill_fields: [credit_note_parent_invoice_id]

  dimension: credit_note_parent_invoice_id {
    type: number
    sql: ${TABLE}."CREDIT_NOTE_PARENT_INVOICE_ID" ;;
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

  dimension: billing_address {
    type: string
    sql: ${TABLE}."BILLING_ADDRESS" ;;
  }

  dimension_group: created {
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
    sql: CAST(${TABLE}."CREATED_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: currency_code {
    type: string
    sql: ${TABLE}."CURRENCY_CODE" ;;
  }

  dimension_group: deleted {
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
    sql: CAST(${TABLE}."DELETEDAT" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: due {
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
    sql: CAST(${TABLE}."DUE_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: email_sent {
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
    sql: CAST(${TABLE}."EMAIL_SENT" AS TIMESTAMP_NTZ) ;;
  }

  dimension: erp_id {
    type: number
    sql: ${TABLE}."ERP_ID" ;;
  }

  dimension: erp_invoice_id {
    type: string
    sql: ${TABLE}."ERP_INVOICE_ID" ;;
  }

  dimension: erp_public_url {
    type: string
    sql: ${TABLE}."ERP_PUBLIC_URL" ;;
  }

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
    value_format_name: id
  }

  dimension: invoice_from_ou_id {
    type: string
    sql: ${TABLE}."INVOICE_FROM_OU_ID" ;;
  }

  dimension: invoice_name {
    label: "Invoice"
    type: string
    sql: ${TABLE}."NAME" ;;
    required_fields: [public_id]
    # html: <font color="blue"><u><a href="https://manage.estrack.io/billing/v2/invoices/{{ invoices.uuid._filterable_value }}" target="_blank">{{value}}</a></font></u>;;
    html: <font color="blue"><u><a href="https://global.dev.estrack.io/billing/invoices/inv-{{ invoice_name_seq._value }}?publicId={{ public_id._value }}" target="_blank">{{value}}</a></font></u>;;
  }

  dimension: invoice_reference {
    type: string
    sql: ${TABLE}."INVOICE_REFERENCE" ;;
  }

  dimension: invoice_name_seq {
    type: string
    sql: ${TABLE}."INVOICE_NAME_SEQ" ;;
  }

  dimension: invoice_to_crm_entity_uuid {
    type: string
    sql: ${TABLE}."INVOICE_TO_CRM_ENTITY_UUID" ;;
  }

  dimension_group: issue {
    type: time
    timeframes: [
      raw,
      time,
      date,
      month,
      year
    ]
    sql: CAST(${TABLE}."ISSUEDATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: order_external_id {
    type: number
    sql: ${TABLE}."ORDER_EXTERNAL_ID" ;;
  }

  dimension: order_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension: order_purchase_order_reference {
    type: string
    sql: ${TABLE}."ORDER_PURCHASE_ORDER_REFERENCE" ;;
  }

  dimension: ou_tax {
    type: number
    sql: ${TABLE}."OU_TAX" ;;
  }

  dimension: remaining_balance {
    type: number
    sql: ${TABLE}."REMAINING_BALANCE" ;;
  }

  dimension: rental_id_search {
    type: string
    sql: ${TABLE}."RENTAL_ID_SEARCH" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  dimension: sub_total {
    type: number
    sql: ${TABLE}."SUB_TOTAL" ;;
  }

  dimension: total {
    type: number
    sql: ${TABLE}."TOTAL" ;;
  }

  dimension: type {
    type: string
    sql: ${TABLE}."TYPE" ;;
  }

  dimension: public_id {
    type: string
    sql: ${TABLE}."PUBLICID" ;;
  }

  dimension_group: updated {
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
    sql: CAST(${TABLE}."UPDATED_DATE" AS TIMESTAMP_NTZ) ;;
  }

  # dimension: uuid {
  #   type: number
  #   sql: ${TABLE}."UUID" ;;
  # }

  measure: count {
    type: count
    drill_fields: [invoice_name, orders.id, line_items.count]
  }

}
