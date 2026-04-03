view: intacct__vendors {
  sql_table_name: "INTACCT_GOLD"."INTACCT__VENDORS" ;;

  dimension: pk_vendor_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."PK_VENDOR_ID" ;;
    value_format_name: id
  }

  dimension: id_vendor {
    type: string
    sql: ${TABLE}."ID_VENDOR" ;;
  }

  dimension: id_tax {
    type: string
    sql: ${TABLE}."ID_TAX" ;;
  }

  dimension: status_vendor {
    type: string
    sql: ${TABLE}."STATUS_VENDOR" ;;
  }

  dimension: name_vendor {
    type: string
    sql: ${TABLE}."NAME_VENDOR" ;;
  }

  dimension: name_legal {
    type: string
    sql: ${TABLE}."NAME_LEGAL" ;;
  }

  dimension: name_dba {
    type: string
    sql: ${TABLE}."NAME_DBA" ;;
  }

  dimension: ach_account_number {
    type: string
    sql: ${TABLE}."ACH_ACCOUNT_NUMBER" ;;
  }

  dimension: ach_routing_number {
    type: string
    sql: ${TABLE}."ACH_ROUTING_NUMBER" ;;
  }

  dimension: is_ach_enabled {
    type: yesno
    sql: ${TABLE}."IS_ACH_ENABLED" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: approved_entities {
    type: string
    sql: ${TABLE}."APPROVED_ENTITIES" ;;
  }

  dimension: email_vic_ap_rep_corp_cc {
    type: string
    sql: ${TABLE}."EMAIL_VIC_AP_REP_CORP_CC" ;;
  }

  dimension: email_vic_ap_rep_fleet {
    type: string
    sql: ${TABLE}."EMAIL_VIC_AP_REP_FLEET" ;;
  }

  dimension: url_coi {
    type: string
    sql: ${TABLE}."URL_COI" ;;
    link: {
      label: "URL Coi"
      url: "{{ value }}"
    }
  }

  dimension: comments {
    type: string
    sql: ${TABLE}."COMMENTS" ;;
  }

  dimension: commodity {
    type: string
    sql: ${TABLE}."COMMODITY" ;;
  }

  dimension: amount_credit_limit {
    type: number
    sql: ${TABLE}."AMOUNT_CREDIT_LIMIT" ;;
    value_format_name: usd
    group_label: "Amounts"
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

  dimension: is_credit_card_vendor {
    type: yesno
    sql: ${TABLE}."IS_CREDIT_CARD_VENDOR" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_display_term_discount {
    type: yesno
    sql: ${TABLE}."IS_DISPLAY_TERM_DISCOUNT" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_display_loc_acct_no_check {
    type: yesno
    sql: ${TABLE}."IS_DISPLAY_LOC_ACCT_NO_CHECK" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_check_enabled {
    type: yesno
    sql: ${TABLE}."IS_CHECK_ENABLED" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_d365_dc {
    type: yesno
    sql: ${TABLE}."IS_D365_DC" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_individual {
    type: yesno
    sql: ${TABLE}."IS_INDIVIDUAL" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_owner {
    type: yesno
    sql: ${TABLE}."IS_OWNER" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_cip_vendor {
    type: yesno
    sql: ${TABLE}."IS_CIP_VENDOR" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_merge_payment_requests {
    type: yesno
    sql: ${TABLE}."IS_MERGE_PAYMENT_REQUESTS" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_non_inventory {
    type: yesno
    sql: ${TABLE}."IS_NON_INVENTORY" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_one_time_use {
    type: yesno
    sql: ${TABLE}."IS_ONE_TIME_USE" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_on_hold {
    type: yesno
    sql: ${TABLE}."IS_ON_HOLD" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_payment_notify {
    type: yesno
    sql: ${TABLE}."IS_PAYMENT_NOTIFY" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_prevent_new_poe_in_sage {
    type: yesno
    sql: ${TABLE}."IS_PREVENT_NEW_POE_IN_SAGE" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_requires_coi {
    type: yesno
    sql: ${TABLE}."IS_REQUIRES_COI" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: name_diversity_classification {
    type: string
    sql: ${TABLE}."NAME_DIVERSITY_CLASSIFICATION" ;;
  }

  dimension: name_file_payment_service {
    type: string
    sql: ${TABLE}."NAME_FILE_PAYMENT_SERVICE" ;;
  }

  dimension: form_1099_box {
    type: string
    sql: ${TABLE}."FORM_1099_BOX" ;;
  }

  dimension: form_1099_type {
    type: string
    sql: ${TABLE}."FORM_1099_TYPE" ;;
  }

  dimension: fleet_book_of_business {
    type: string
    sql: ${TABLE}."FLEET_BOOK_OF_BUSINESS" ;;
  }

  dimension: fleet_category {
    type: string
    sql: ${TABLE}."FLEET_CATEGORY" ;;
  }

  dimension: fleet_core_designation {
    type: string
    sql: ${TABLE}."FLEET_CORE_DESIGNATION" ;;
  }

  dimension: fleet_financing_designation {
    type: string
    sql: ${TABLE}."FLEET_FINANCING_DESIGNATION" ;;
  }

  dimension: ach_prenote_last_auth_account_number {
    type: string
    sql: ${TABLE}."ACH_PRENOTE_LAST_AUTH_ACCOUNT_NUMBER" ;;
  }

  dimension: name_vendor_1099 {
    type: string
    sql: ${TABLE}."NAME_VENDOR_1099" ;;
  }

  dimension: name_restricted_objects {
    type: string
    sql: ${TABLE}."NAME_RESTRICTED_OBJECTS" ;;
  }

  dimension: priority_payment {
    type: string
    sql: ${TABLE}."PRIORITY_PAYMENT" ;;
  }

  dimension: ach_prenote_account_number {
    type: string
    sql: ${TABLE}."ACH_PRENOTE_ACCOUNT_NUMBER" ;;
  }

  dimension: id_document {
    type: string
    sql: ${TABLE}."ID_DOCUMENT" ;;
  }

  dimension: name_payment_term {
    type: string
    sql: ${TABLE}."NAME_PAYMENT_TERM" ;;
  }

  dimension: payment_term_description {
    type: string
    sql: ${TABLE}."PAYMENT_TERM_DESCRIPTION" ;;
  }

  dimension: days_payment_due {
    type: number
    sql: ${TABLE}."DAYS_PAYMENT_DUE" ;;
  }

  dimension: due_from_basis {
    type: string
    sql: ${TABLE}."DUE_FROM_BASIS" ;;
  }

  dimension: pct_discount_early_payment {
    type: number
    sql: ${TABLE}."PCT_DISCOUNT_EARLY_PAYMENT" ;;
    value_format_name: percent_2
  }

  dimension: days_discount_window {
    type: number
    sql: ${TABLE}."DAYS_DISCOUNT_WINDOW" ;;
  }

  dimension: num_days_epay_due_date_deduction {
    type: number
    sql: ${TABLE}."NUM_DAYS_EPAY_DUE_DATE_DEDUCTION" ;;
  }

  dimension: days_payment_due_effective {
    type: number
    sql: ${TABLE}."DAYS_PAYMENT_DUE_EFFECTIVE" ;;
  }

  dimension: amount_due {
    type: number
    sql: ${TABLE}."AMOUNT_DUE" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: id_tax_foreign {
    type: string
    sql: ${TABLE}."ID_TAX_FOREIGN" ;;
  }

  dimension: email_eqs_employee_notify_on_vendor_creation {
    type: string
    sql: ${TABLE}."EMAIL_EQS_EMPLOYEE_NOTIFY_ON_VENDOR_CREATION" ;;
  }

  dimension: email_vendor_invoices_from {
    type: string
    sql: ${TABLE}."EMAIL_VENDOR_INVOICES_FROM" ;;
  }

  dimension: vendor_purchases_financed_by {
    type: string
    sql: ${TABLE}."VENDOR_PURCHASES_FINANCED_BY" ;;
  }

  dimension: category_vendor_new {
    type: string
    sql: ${TABLE}."CATEGORY_VENDOR_NEW" ;;
  }

  dimension: category_reporting {
    type: string
    sql: ${TABLE}."CATEGORY_REPORTING" ;;
  }

  dimension: category_vendor {
    type: string
    sql: ${TABLE}."CATEGORY_VENDOR" ;;
  }

  dimension: category_vendor_sub {
    type: string
    sql: ${TABLE}."CATEGORY_VENDOR_SUB" ;;
  }

  dimension: name_payment_method {
    type: string
    sql: ${TABLE}."NAME_PAYMENT_METHOD" ;;
  }

  dimension: is_related_party {
    type: yesno
    sql: ${TABLE}."IS_RELATED_PARTY" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: type_ach_account {
    type: string
    sql: ${TABLE}."TYPE_ACH_ACCOUNT" ;;
  }

  dimension: type_ach_remittance {
    type: string
    sql: ${TABLE}."TYPE_ACH_REMITTANCE" ;;
  }

  dimension: type_alt_pay_method {
    type: string
    sql: ${TABLE}."TYPE_ALT_PAY_METHOD" ;;
  }

  dimension: type_billing {
    type: string
    sql: ${TABLE}."TYPE_BILLING" ;;
  }

  dimension: type_vendor {
    type: string
    sql: ${TABLE}."TYPE_VENDOR" ;;
  }

  dimension: name_created_by_user {
    type: string
    sql: ${TABLE}."NAME_CREATED_BY_USER" ;;
  }

  dimension: name_modified_by_user {
    type: string
    sql: ${TABLE}."NAME_MODIFIED_BY_USER" ;;
  }

  dimension: fk_1099_contact_id {
    type: number
    sql: ${TABLE}."FK_1099_CONTACT_ID" ;;
    value_format_name: id
    group_label: "Foreign Keys"
  }

  dimension: fk_created_by_user_id {
    type: number
    sql: ${TABLE}."FK_CREATED_BY_USER_ID" ;;
    value_format_name: id
    group_label: "Foreign Keys"
  }

  dimension: fk_display_contact_id {
    type: number
    sql: ${TABLE}."FK_DISPLAY_CONTACT_ID" ;;
    value_format_name: id
    group_label: "Foreign Keys"
  }

  dimension: fk_es_admin_id {
    type: string
    sql: ${TABLE}."FK_ES_ADMIN_ID" ;;
    group_label: "Foreign Keys"
  }

  dimension: fk_fleet_track_id {
    type: string
    sql: ${TABLE}."FK_FLEET_TRACK_ID" ;;
    group_label: "Foreign Keys"
  }

  dimension: fk_modified_by_user_id {
    type: number
    sql: ${TABLE}."FK_MODIFIED_BY_USER_ID" ;;
    value_format_name: id
    group_label: "Foreign Keys"
  }

  dimension: fk_pay_to_contact_id {
    type: number
    sql: ${TABLE}."FK_PAY_TO_CONTACT_ID" ;;
    value_format_name: id
    group_label: "Foreign Keys"
  }

  dimension: fk_primary_contact_id {
    type: number
    sql: ${TABLE}."FK_PRIMARY_CONTACT_ID" ;;
    value_format_name: id
    group_label: "Foreign Keys"
  }

  dimension: fk_return_to_contact_id {
    type: number
    sql: ${TABLE}."FK_RETURN_TO_CONTACT_ID" ;;
    value_format_name: id
    group_label: "Foreign Keys"
  }

  dimension: fk_payment_term_id {
    type: number
    sql: ${TABLE}."FK_PAYMENT_TERM_ID" ;;
    value_format_name: id
    group_label: "Foreign Keys"
  }

  dimension: fk_vendor_portal_id {
    type: number
    sql: ${TABLE}."FK_VENDOR_PORTAL_ID" ;;
    value_format_name: id
    group_label: "Foreign Keys"
  }

  dimension: fk_vendor_redirect_id {
    type: string
    sql: ${TABLE}."FK_VENDOR_REDIRECT_ID" ;;
    group_label: "Foreign Keys"
  }

  dimension: fk_vendor_type_id {
    type: number
    sql: ${TABLE}."FK_VENDOR_TYPE_ID" ;;
    value_format_name: id
    group_label: "Foreign Keys"
  }

  dimension: fk_payment_method_id {
    type: number
    sql: ${TABLE}."FK_PAYMENT_METHOD_ID" ;;
    value_format_name: id
    group_label: "Foreign Keys"
  }

  dimension_group: date_earliest_coi_expiration {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_EARLIEST_COI_EXPIRATION" ;;
    group_label: "Dates"
  }

  dimension_group: date_prenote_last_auth {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_PRENOTE_LAST_AUTH" ;;
    group_label: "Dates"
  }

  dimension_group: date_msa_valid_through {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_MSA_VALID_THROUGH" ;;
    group_label: "Dates"
  }

  dimension_group: timestamp_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_CREATED" ;;
    group_label: "Timestamps"
  }

  dimension_group: timestamp_modified {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_MODIFIED" ;;
    group_label: "Timestamps"
  }

  dimension_group: timestamp_dds_loaded {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_DDS_LOADED" ;;
    group_label: "Timestamps"
  }

  dimension_group: timestamp_loaded {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_LOADED" ;;
    group_label: "Timestamps"
  }

  set: detail {
    fields: [
      pk_vendor_id,
      id_vendor,
      id_tax,
      status_vendor,
      name_vendor,
      name_legal,
      name_dba,
      ach_account_number,
      ach_routing_number,
      is_ach_enabled,
      approved_entities,
      email_vic_ap_rep_corp_cc,
      email_vic_ap_rep_fleet,
      url_coi,
      comments,
      commodity,
      amount_credit_limit,
      is_do_not_cut_check,
      is_credit_card_vendor,
      is_display_term_discount,
      is_display_loc_acct_no_check,
      is_check_enabled,
      is_d365_dc,
      is_individual,
      is_owner,
      is_cip_vendor,
      is_merge_payment_requests,
      is_non_inventory,
      is_one_time_use,
      is_on_hold,
      is_payment_notify,
      is_prevent_new_poe_in_sage,
      is_requires_coi,
      name_diversity_classification,
      name_file_payment_service,
      form_1099_box,
      form_1099_type,
      fleet_book_of_business,
      fleet_category,
      fleet_core_designation,
      fleet_financing_designation,
      ach_prenote_last_auth_account_number,
      name_vendor_1099,
      name_restricted_objects,
      priority_payment,
      ach_prenote_account_number,
      id_document,
      name_payment_term,
      payment_term_description,
      days_payment_due,
      due_from_basis,
      pct_discount_early_payment,
      days_discount_window,
      num_days_epay_due_date_deduction,
      days_payment_due_effective,
      amount_due,
      id_tax_foreign,
      email_eqs_employee_notify_on_vendor_creation,
      email_vendor_invoices_from,
      vendor_purchases_financed_by,
      category_vendor_new,
      category_reporting,
      category_vendor,
      category_vendor_sub,
      name_payment_method,
      is_related_party,
      type_ach_account,
      type_ach_remittance,
      type_alt_pay_method,
      type_billing,
      type_vendor,
      name_created_by_user,
      name_modified_by_user,
      fk_1099_contact_id,
      fk_created_by_user_id,
      fk_display_contact_id,
      fk_es_admin_id,
      fk_fleet_track_id,
      fk_modified_by_user_id,
      fk_pay_to_contact_id,
      fk_primary_contact_id,
      fk_return_to_contact_id,
      fk_payment_term_id,
      fk_vendor_portal_id,
      fk_vendor_redirect_id,
      fk_vendor_type_id,
      fk_payment_method_id,
      date_earliest_coi_expiration_date,
      date_prenote_last_auth_date,
      date_msa_valid_through_date,
      timestamp_created_date,
      timestamp_modified_date,
      timestamp_dds_loaded_date,
      timestamp_loaded_date,
    ]
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: total_amount_credit_limit {
    type: sum
    sql: ${TABLE}."AMOUNT_CREDIT_LIMIT" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_due {
    type: sum
    sql: ${TABLE}."AMOUNT_DUE" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: avg_num_days_epay_due_date_deduction {
    type: average
    sql: ${TABLE}."NUM_DAYS_EPAY_DUE_DATE_DEDUCTION" ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }
}
