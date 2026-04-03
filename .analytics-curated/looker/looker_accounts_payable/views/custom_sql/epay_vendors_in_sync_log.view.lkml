view: epay_vendors_in_sync_log {
  derived_table: {
    sql:
    SELECT *
FROM ANALYTICS.FINANCIAL_SYSTEMS.EPAY_VENDOR_SYNC_LOG;;
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  dimension: contact_name {
    type: string
    sql: ${TABLE}."CONTACT_NAME" ;;
  }

  dimension: contact_email {
    type: string
    sql: ${TABLE}."CONTACT_EMAIL" ;;
  }

  dimension: contact_phone {
    type: string
    sql: ${TABLE}."CONTACT_PHONE" ;;
  }

  dimension: when_created {
    type: date_time
    sql: ${TABLE}."WHENCREATED";;
  }

  dimension: when_modified {
    type: date_time
    sql: ${TABLE}."WHENMODIFIED";;
  }
}
