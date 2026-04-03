view: integrations_vic_costcapture_sandbox__po_header_check {
  sql_table_name: "INTEGRATIONS_GOLD"."INTEGRATIONS_VIC_COSTCAPTURE_SANDBOX__PO_HEADER_CHECK" ;;

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
  dimension: is_inactive_deliver_to_branch {
    type: yesno
    sql: ${TABLE}."IS_INACTIVE_DELIVER_TO_BRANCH" ;;
  }
  dimension: is_inactive_requesting_branch {
    type: yesno
    sql: ${TABLE}."IS_INACTIVE_REQUESTING_BRANCH" ;;
  }
  dimension: is_inactive_vendor {
    type: yesno
    sql: ${TABLE}."IS_INACTIVE_VENDOR" ;;
  }
  dimension: is_not_eligible_deliver_to_branch {
    type: yesno
    sql: ${TABLE}."IS_NOT_ELIGIBLE_DELIVER_TO_BRANCH" ;;
  }
  dimension: is_not_eligible_requesting_branch {
    type: yesno
    sql: ${TABLE}."IS_NOT_ELIGIBLE_REQUESTING_BRANCH" ;;
  }
  dimension: is_null_deliver_to_branch {
    type: yesno
    sql: ${TABLE}."IS_NULL_DELIVER_TO_BRANCH" ;;
  }
  dimension: is_null_po_number {
    type: yesno
    sql: ${TABLE}."IS_NULL_PO_NUMBER" ;;
  }
  dimension: is_null_requesting_branch {
    type: yesno
    sql: ${TABLE}."IS_NULL_REQUESTING_BRANCH" ;;
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
  dimension: is_vendor_not_approved_for_t3 {
    type: yesno
    sql: ${TABLE}."IS_VENDOR_NOT_APPROVED_FOR_T3" ;;
  }
  dimension: is_vendor_on_hold {
    type: yesno
    sql: ${TABLE}."IS_VENDOR_ON_HOLD" ;;
  }
  dimension: is_vendor_prevent_new_poe_in_sage {
    type: yesno
    sql: ${TABLE}."IS_VENDOR_PREVENT_NEW_POE_IN_SAGE" ;;
  }
  dimension: matching_type {
    type: string
    sql: ${TABLE}."MATCHING_TYPE" ;;
  }
  dimension: pk_po_header_id {
    type: string
    sql: ${TABLE}."PK_PO_HEADER_ID" ;;
    primary_key: yes
  }
  dimension: po_number {
    type: number
    sql: ${TABLE}."PO_NUMBER" ;;
  }
  measure: count {
    type: count
  }
}
