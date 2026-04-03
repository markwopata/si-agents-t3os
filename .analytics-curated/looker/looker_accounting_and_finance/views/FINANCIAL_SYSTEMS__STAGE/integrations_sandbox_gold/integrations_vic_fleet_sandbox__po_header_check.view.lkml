view: integrations_vic_fleet_sandbox__po_header_check {
  sql_table_name: "INTEGRATIONS_GOLD"."INTEGRATIONS_VIC_FLEET_SANDBOX__PO_HEADER_CHECK" ;;

  dimension: is_amount_non_positive {
    type: yesno
    sql: ${TABLE}."IS_AMOUNT_NON_POSITIVE" ;;
  }
  dimension: is_archived {
    type: yesno
    sql: ${TABLE}."IS_ARCHIVED" ;;
  }
  dimension: is_header_alerted {
    type: yesno
    sql: ${TABLE}."IS_HEADER_ALERTED" ;;
  }
  dimension: is_header_blocked {
    type: yesno
    sql: ${TABLE}."IS_HEADER_BLOCKED" ;;
  }
  dimension: is_inactive_market {
    type: yesno
    sql: ${TABLE}."IS_INACTIVE_MARKET" ;;
  }
  dimension: is_inactive_vendor {
    type: yesno
    sql: ${TABLE}."IS_INACTIVE_VENDOR" ;;
  }
  dimension: is_not_approved {
    type: yesno
    sql: ${TABLE}."IS_NOT_APPROVED" ;;
  }
  dimension: is_not_eligible_market {
    type: yesno
    sql: ${TABLE}."IS_NOT_ELIGIBLE_MARKET" ;;
  }
  dimension: is_null_market {
    type: yesno
    sql: ${TABLE}."IS_NULL_MARKET" ;;
  }
  dimension: is_null_po_number {
    type: yesno
    sql: ${TABLE}."IS_NULL_PO_NUMBER" ;;
  }
  dimension: is_payment_term_blocked {
    type: yesno
    sql: ${TABLE}."IS_PAYMENT_TERM_BLOCKED" ;;
  }
  dimension: is_qty_ordered_not_positive {
    type: yesno
    sql: ${TABLE}."IS_QTY_ORDERED_NOT_POSITIVE" ;;
  }
  dimension: is_unmapped_vendor {
    type: yesno
    sql: ${TABLE}."IS_UNMAPPED_VENDOR" ;;
  }
  dimension: is_vendor_invalid_type {
    type: yesno
    sql: ${TABLE}."IS_VENDOR_INVALID_TYPE" ;;
  }
  dimension: is_vendor_missing_ap_rep_email {
    type: yesno
    sql: ${TABLE}."IS_VENDOR_MISSING_AP_REP_EMAIL" ;;
  }
  dimension: is_vendor_not_approved_for_fleet {
    type: yesno
    sql: ${TABLE}."IS_VENDOR_NOT_APPROVED_FOR_FLEET" ;;
  }
  dimension: is_vendor_on_hold {
    type: yesno
    sql: ${TABLE}."IS_VENDOR_ON_HOLD" ;;
  }
  dimension: matching_type {
    type: string
    sql: ${TABLE}."MATCHING_TYPE" ;;
  }
  dimension: name_payment_term {
    type: string
    sql: ${TABLE}."NAME_PAYMENT_TERM" ;;
  }
  dimension: pk_po_line_id {
    type: number
    sql: ${TABLE}."PK_PO_LINE_ID" ;;
    primary_key: yes
  }
  dimension: po_number {
    type: string
    sql: ${TABLE}."PO_NUMBER" ;;
  }
  dimension: product_number {
    type: string
    sql: ${TABLE}."PRODUCT_NUMBER" ;;
  }
  dimension: sync_environment {
    type: string
    sql: ${TABLE}."SYNC_ENVIRONMENT" ;;
  }
  measure: count {
    type: count
  }
}
