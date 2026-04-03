view: integrations_vic_t3__po_header_check {
  sql_table_name: "INTEGRATIONS_GOLD"."INTEGRATIONS_VIC_T3__PO_HEADER_CHECK" ;;

  dimension: pk_po_header_id {
    type: string
    primary_key: yes
    sql: ${TABLE}."PK_PO_HEADER_ID" ;;
  }

  dimension: po_number {
    type: string
    sql: ${TABLE}."PO_NUMBER" ;;
  }

  dimension: t3_id_vendor {
    type: string
    sql: ${TABLE}."T3_ID_VENDOR" ;;
  }

  dimension: vic_id_vendor {
    type: string
    sql: ${TABLE}."VIC_ID_VENDOR" ;;
  }

  dimension_group: t3_created_on {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."T3_CREATED_ON" ;;
  }

  dimension_group: vic_created_on {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."VIC_CREATED_ON" ;;
  }

  dimension_group: t3_issued_on {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."T3_ISSUED_ON" ;;
  }

  dimension_group: vic_issued_on {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."VIC_ISSUED_ON" ;;
  }

  dimension_group: t3_deliver_on {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."T3_DELIVER_ON" ;;
  }

  dimension_group: vic_deliver_on {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."VIC_DELIVER_ON" ;;
  }

  dimension: t3_email_created_by {
    type: string
    sql: ${TABLE}."T3_EMAIL_CREATED_BY" ;;
  }

  dimension: vic_email_requestor {
    type: string
    sql: ${TABLE}."VIC_EMAIL_REQUESTOR" ;;
  }

  dimension: t3_email_gm {
    type: string
    sql: ${TABLE}."T3_EMAIL_GM" ;;
  }

  dimension: vic_email_site_owner {
    type: string
    sql: ${TABLE}."VIC_EMAIL_SITE_OWNER" ;;
  }

  dimension: t3_payment_term {
    type: string
    sql: ${TABLE}."T3_PAYMENT_TERM" ;;
  }

  dimension: vic_payment_term_id {
    type: string
    sql: ${TABLE}."VIC_PAYMENT_TERM_ID" ;;
  }

  dimension: t3_matching_type {
    type: string
    sql: ${TABLE}."T3_MATCHING_TYPE" ;;
  }

  dimension: vic_matching_type {
    type: string
    sql: ${TABLE}."VIC_MATCHING_TYPE" ;;
  }

  dimension: t3_amount {
    type: number
    sql: ${TABLE}."T3_AMOUNT" ;;
  }

  dimension: vic_amount {
    type: number
    sql: ${TABLE}."VIC_AMOUNT" ;;
  }

  dimension: t3_description {
    type: string
    sql: ${TABLE}."T3_DESCRIPTION" ;;
  }

  dimension: vic_description {
    type: string
    sql: ${TABLE}."VIC_DESCRIPTION" ;;
  }

  dimension: name_vendor {
    type: string
    sql: ${TABLE}."NAME_VENDOR" ;;
  }

  dimension: status_vendor {
    type: string
    sql: ${TABLE}."STATUS_VENDOR" ;;
  }

  dimension: is_do_not_cut_check {
    type: yesno
    sql: ${TABLE}."IS_DO_NOT_CUT_CHECK" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: email_vic_ap_rep_corp_cc {
    type: string
    sql: ${TABLE}."EMAIL_VIC_AP_REP_CORP_CC" ;;
  }

  dimension: id_effective_branch {
    type: number
    sql: ${TABLE}."ID_EFFECTIVE_BRANCH" ;;
  }

  dimension: name_effective_branch {
    type: string
    sql: ${TABLE}."NAME_EFFECTIVE_BRANCH" ;;
  }

  dimension: status_effective_branch {
    type: string
    sql: ${TABLE}."STATUS_EFFECTIVE_BRANCH" ;;
  }

  dimension: unblocked_line_count {
    type: number
    sql: ${TABLE}."UNBLOCKED_LINE_COUNT" ;;
  }

  dimension: is_header_blocked {
    type: yesno
    sql: ${TABLE}."IS_HEADER_BLOCKED" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_header_alerted {
    type: yesno
    sql: ${TABLE}."IS_HEADER_ALERTED" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_archived {
    type: yesno
    sql: ${TABLE}."IS_ARCHIVED" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_null_po_number {
    type: yesno
    sql: ${TABLE}."IS_NULL_PO_NUMBER" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_po_already_converted_in_intacct {
    type: yesno
    sql: ${TABLE}."IS_PO_ALREADY_CONVERTED_IN_INTACCT" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_in_vic {
    type: yesno
    sql: ${TABLE}."IS_IN_VIC" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_null_effective_branch {
    type: yesno
    sql: ${TABLE}."IS_NULL_EFFECTIVE_BRANCH" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_inactive_effective_branch {
    type: yesno
    sql: ${TABLE}."IS_INACTIVE_EFFECTIVE_BRANCH" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_effective_branch_not_yet_migrated_to_vic {
    type: yesno
    sql: ${TABLE}."IS_EFFECTIVE_BRANCH_NOT_YET_MIGRATED_TO_VIC" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_stale_po_date_compared_to_effective_branch_migration {
    type: yesno
    sql: ${TABLE}."IS_STALE_PO_DATE_COMPARED_TO_EFFECTIVE_BRANCH_MIGRATION" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_unmapped_vendor {
    type: yesno
    sql: ${TABLE}."IS_UNMAPPED_VENDOR" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_inactive_vendor {
    type: yesno
    sql: ${TABLE}."IS_INACTIVE_VENDOR" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_vendor_not_approved_for_t3 {
    type: yesno
    sql: ${TABLE}."IS_VENDOR_NOT_APPROVED_FOR_T3" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_vendor_missing_ap_rep_email {
    type: yesno
    sql: ${TABLE}."IS_VENDOR_MISSING_AP_REP_EMAIL" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_vendor_on_hold {
    type: yesno
    sql: ${TABLE}."IS_VENDOR_ON_HOLD" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_vendor_prevent_new_poe_in_sage {
    type: yesno
    sql: ${TABLE}."IS_VENDOR_PREVENT_NEW_POE_IN_SAGE" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_vendor_invalid_type {
    type: yesno
    sql: ${TABLE}."IS_VENDOR_INVALID_TYPE" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_date_delivered_changed {
    type: yesno
    sql: ${TABLE}."IS_DATE_DELIVERED_CHANGED" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_email_requestor_changed {
    type: yesno
    sql: ${TABLE}."IS_EMAIL_REQUESTOR_CHANGED" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_email_site_owner_changed {
    type: yesno
    sql: ${TABLE}."IS_EMAIL_SITE_OWNER_CHANGED" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_id_vendor_changed {
    type: yesno
    sql: ${TABLE}."IS_ID_VENDOR_CHANGED" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_matching_type_changed {
    type: yesno
    sql: ${TABLE}."IS_MATCHING_TYPE_CHANGED" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_date_created_changed {
    type: yesno
    sql: ${TABLE}."IS_DATE_CREATED_CHANGED" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_date_issued_changed {
    type: yesno
    sql: ${TABLE}."IS_DATE_ISSUED_CHANGED" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_amount_changed {
    type: yesno
    sql: ${TABLE}."IS_AMOUNT_CHANGED" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: has_header_changed {
    type: yesno
    sql: ${TABLE}."HAS_HEADER_CHANGED" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  set: detail {
    fields: [
      pk_po_header_id,
      po_number,
      t3_id_vendor,
      vic_id_vendor,
      t3_created_on_date,
      vic_created_on_date,
      t3_issued_on_date,
      vic_issued_on_date,
      t3_deliver_on_date,
      vic_deliver_on_date,
      t3_email_created_by,
      vic_email_requestor,
      t3_email_gm,
      vic_email_site_owner,
      t3_payment_term,
      vic_payment_term_id,
      t3_matching_type,
      vic_matching_type,
      t3_amount,
      vic_amount,
      t3_description,
      vic_description,
      name_vendor,
      status_vendor,
      is_do_not_cut_check,
      email_vic_ap_rep_corp_cc,
      id_effective_branch,
      name_effective_branch,
      status_effective_branch,
      unblocked_line_count,
      is_header_blocked,
      is_header_alerted,
      is_archived,
      is_null_po_number,
      is_po_already_converted_in_intacct,
      is_in_vic,
      is_null_effective_branch,
      is_inactive_effective_branch,
      is_effective_branch_not_yet_migrated_to_vic,
      is_stale_po_date_compared_to_effective_branch_migration,
      is_unmapped_vendor,
      is_inactive_vendor,
      is_vendor_not_approved_for_t3,
      is_vendor_missing_ap_rep_email,
      is_vendor_on_hold,
      is_vendor_prevent_new_poe_in_sage,
      is_vendor_invalid_type,
      is_date_delivered_changed,
      is_email_requestor_changed,
      is_email_site_owner_changed,
      is_id_vendor_changed,
      is_matching_type_changed,
      is_date_created_changed,
      is_date_issued_changed,
      is_amount_changed,
      has_header_changed,
    ]
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: total_t3_amount {
    type: sum
    sql: ${TABLE}."T3_AMOUNT" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_vic_amount {
    type: sum
    sql: ${TABLE}."VIC_AMOUNT" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }
}
