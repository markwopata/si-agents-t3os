view: apa__gl_entries_base_checks {
  sql_table_name: "ACCRUAL_GOLD"."APA__GL_ENTRIES_BASE_CHECKS" ;;

  dimension: fk_source_po_receipt_line_id {
    type: string
    sql: ${TABLE}."FK_SOURCE_PO_RECEIPT_LINE_ID" ;;
    group_label: "Foreign Keys"
  }

  dimension: fk_source_po_receipt_header_id {
    type: string
    sql: ${TABLE}."FK_SOURCE_PO_RECEIPT_HEADER_ID" ;;
    group_label: "Foreign Keys"
  }

  dimension: fk_source_po_header_id {
    type: string
    sql: ${TABLE}."FK_SOURCE_PO_HEADER_ID" ;;
    group_label: "Foreign Keys"
  }

  dimension: fk_source_po_line_id {
    type: string
    sql: ${TABLE}."FK_SOURCE_PO_LINE_ID" ;;
    group_label: "Foreign Keys"
  }

  dimension_group: date_posting_input {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_POSTING_INPUT" ;;
    group_label: "Dates"
  }

  dimension_group: date_posting_actual {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_POSTING_ACTUAL" ;;
    group_label: "Dates"
  }

  dimension: id_vendor {
    type: string
    sql: ${TABLE}."ID_VENDOR" ;;
  }

  dimension: po_number {
    type: string
    sql: ${TABLE}."PO_NUMBER" ;;
  }

  dimension: gl_account {
    type: string
    sql: ${TABLE}."GL_ACCOUNT" ;;
  }

  dimension: qty_receipt {
    type: number
    sql: ${TABLE}."QTY_RECEIPT" ;;
    group_label: "Quantities"
  }

  dimension: ppu_receipt {
    type: number
    sql: ${TABLE}."PPU_RECEIPT" ;;
  }

  dimension: amount_received {
    type: number
    sql: ${TABLE}."AMOUNT_RECEIVED" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: amount_debit {
    type: number
    sql: ${TABLE}."AMOUNT_DEBIT" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: amount_credit {
    type: number
    sql: ${TABLE}."AMOUNT_CREDIT" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: id_effective_branch {
    type: number
    sql: ${TABLE}."ID_EFFECTIVE_BRANCH" ;;
  }

  dimension: id_expense_line {
    type: number
    sql: ${TABLE}."ID_EXPENSE_LINE" ;;
  }

  dimension: memo {
    type: string
    sql: ${TABLE}."MEMO" ;;
  }

  dimension: url_source_po {
    type: string
    sql: ${TABLE}."URL_SOURCE_PO" ;;
    link: {
      label: "URL Source Po"
      url: "{{ value }}"
    }
  }

  dimension: url_vic_po {
    type: string
    sql: ${TABLE}."URL_VIC_PO" ;;
    link: {
      label: "URL Vic Po"
      url: "{{ value }}"
    }
  }

  dimension: url_sage_invoice {
    type: string
    sql: ${TABLE}."URL_SAGE_INVOICE" ;;
    link: {
      label: "URL Sage Invoice"
      url: "{{ value }}"
    }
  }

  dimension: url_vic_invoice {
    type: string
    sql: ${TABLE}."URL_VIC_INVOICE" ;;
    link: {
      label: "URL Vic Invoice"
      url: "{{ value }}"
    }
  }

  dimension: url_sage_apbill {
    type: string
    sql: ${TABLE}."URL_SAGE_APBILL" ;;
    link: {
      label: "URL Sage Apbill"
      url: "{{ value }}"
    }
  }

  dimension: entry_context {
    type: string
    sql: ${TABLE}."ENTRY_CONTEXT" ;;
  }

  dimension: accrual_type {
    type: string
    sql: ${TABLE}."ACCRUAL_TYPE" ;;
  }

  dimension: entry_source_model {
    type: string
    sql: ${TABLE}."ENTRY_SOURCE_MODEL" ;;
  }

  dimension_group: timestamp_posted {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_POSTED" ;;
    group_label: "Timestamps"
  }

  dimension: url_intacct_posted_entry {
    type: string
    sql: ${TABLE}."URL_INTACCT_POSTED_ENTRY" ;;
    link: {
      label: "URL Intacct Posted Entry"
      url: "{{ value }}"
    }
  }

  dimension: is_already_posted {
    type: yesno
    sql: ${TABLE}."IS_ALREADY_POSTED" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_missing_po_number {
    type: yesno
    sql: ${TABLE}."IS_MISSING_PO_NUMBER" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_historical_exclusion {
    type: yesno
    sql: ${TABLE}."IS_HISTORICAL_EXCLUSION" ;;
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

  dimension: is_unmapped_department {
    type: yesno
    sql: ${TABLE}."IS_UNMAPPED_DEPARTMENT" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_inactive_department {
    type: yesno
    sql: ${TABLE}."IS_INACTIVE_DEPARTMENT" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_non_vic_migrated_dept {
    type: yesno
    sql: ${TABLE}."IS_NON_VIC_MIGRATED_DEPT" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_entry_before_dept_migration_to_vic {
    type: yesno
    sql: ${TABLE}."IS_ENTRY_BEFORE_DEPT_MIGRATION_TO_VIC" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_unmapped_gl_account {
    type: yesno
    sql: ${TABLE}."IS_UNMAPPED_GL_ACCOUNT" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_inactive_gl_account {
    type: yesno
    sql: ${TABLE}."IS_INACTIVE_GL_ACCOUNT" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_expense_line_discontinued {
    type: yesno
    sql: ${TABLE}."IS_EXPENSE_LINE_DISCONTINUED" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_missing_required_expense_line {
    type: yesno
    sql: ${TABLE}."IS_MISSING_REQUIRED_EXPENSE_LINE" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_unmapped_expense_line_department {
    type: yesno
    sql: ${TABLE}."IS_UNMAPPED_EXPENSE_LINE_DEPARTMENT" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_invalid_expense_line_department_mapping {
    type: yesno
    sql: ${TABLE}."IS_INVALID_EXPENSE_LINE_DEPARTMENT_MAPPING" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_unmapped_expense_line_gl_account {
    type: yesno
    sql: ${TABLE}."IS_UNMAPPED_EXPENSE_LINE_GL_ACCOUNT" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_invalid_expense_line_gl_account_mapping {
    type: yesno
    sql: ${TABLE}."IS_INVALID_EXPENSE_LINE_GL_ACCOUNT_MAPPING" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_missing_qty {
    type: yesno
    sql: ${TABLE}."IS_MISSING_QTY" ;;
    group_label: "Quantities"
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_missing_amount_received {
    type: yesno
    sql: ${TABLE}."IS_MISSING_AMOUNT_RECEIVED" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_zero_dollar_entry {
    type: yesno
    sql: ${TABLE}."IS_ZERO_DOLLAR_ENTRY" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_missing_amount_debit_credit {
    type: yesno
    sql: ${TABLE}."IS_MISSING_AMOUNT_DEBIT_CREDIT" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_both_debit_credit_populated {
    type: yesno
    sql: ${TABLE}."IS_BOTH_DEBIT_CREDIT_POPULATED" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_amount_received_inconsistent_with_debit_value {
    type: yesno
    sql: ${TABLE}."IS_AMOUNT_RECEIVED_INCONSISTENT_WITH_DEBIT_VALUE" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_amount_received_inconsistent_with_credit_value {
    type: yesno
    sql: ${TABLE}."IS_AMOUNT_RECEIVED_INCONSISTENT_WITH_CREDIT_VALUE" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_negative_value_in_debit_or_credit {
    type: yesno
    sql: ${TABLE}."IS_NEGATIVE_VALUE_IN_DEBIT_OR_CREDIT" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_alert__posting_date_mismatch {
    type: yesno
    sql: ${TABLE}."IS_ALERT__POSTING_DATE_MISMATCH" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_alert__posting_month_mismatch {
    type: yesno
    sql: ${TABLE}."IS_ALERT__POSTING_MONTH_MISMATCH" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_alert__input_date_before_last_close_date {
    type: yesno
    sql: ${TABLE}."IS_ALERT__INPUT_DATE_BEFORE_LAST_CLOSE_DATE" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_entry_blocked {
    type: yesno
    sql: ${TABLE}."IS_ENTRY_BLOCKED" ;;
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
      fk_source_po_receipt_line_id,
      fk_source_po_receipt_header_id,
      fk_source_po_header_id,
      fk_source_po_line_id,
      date_posting_input_date,
      date_posting_actual_date,
      id_vendor,
      po_number,
      gl_account,
      qty_receipt,
      ppu_receipt,
      amount_received,
      amount_debit,
      amount_credit,
      id_effective_branch,
      id_expense_line,
      memo,
      url_source_po,
      url_vic_po,
      url_sage_invoice,
      url_vic_invoice,
      url_sage_apbill,
      entry_context,
      accrual_type,
      entry_source_model,
      timestamp_posted_date,
      url_intacct_posted_entry,
      is_already_posted,
      is_missing_po_number,
      is_historical_exclusion,
      is_unmapped_vendor,
      is_inactive_vendor,
      is_unmapped_department,
      is_inactive_department,
      is_non_vic_migrated_dept,
      is_entry_before_dept_migration_to_vic,
      is_unmapped_gl_account,
      is_inactive_gl_account,
      is_expense_line_discontinued,
      is_missing_required_expense_line,
      is_unmapped_expense_line_department,
      is_invalid_expense_line_department_mapping,
      is_unmapped_expense_line_gl_account,
      is_invalid_expense_line_gl_account_mapping,
      is_missing_qty,
      is_missing_amount_received,
      is_zero_dollar_entry,
      is_missing_amount_debit_credit,
      is_both_debit_credit_populated,
      is_amount_received_inconsistent_with_debit_value,
      is_amount_received_inconsistent_with_credit_value,
      is_negative_value_in_debit_or_credit,
      is_alert__posting_date_mismatch,
      is_alert__posting_month_mismatch,
      is_alert__input_date_before_last_close_date,
      is_entry_blocked,
    ]
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: total_amount_received {
    type: sum
    sql: ${TABLE}."AMOUNT_RECEIVED" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_debit {
    type: sum
    sql: ${TABLE}."AMOUNT_DEBIT" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_credit {
    type: sum
    sql: ${TABLE}."AMOUNT_CREDIT" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: avg_qty_receipt {
    type: average
    sql: ${TABLE}."QTY_RECEIPT" ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }
}
