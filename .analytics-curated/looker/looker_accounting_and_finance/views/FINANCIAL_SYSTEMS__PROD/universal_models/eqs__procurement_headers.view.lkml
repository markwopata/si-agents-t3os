view: eqs__procurement_headers {
  sql_table_name: "EQS_GOLD"."EQS__PROCUREMENT_HEADERS" ;;

  dimension: pk_procurement_header_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."PK_PROCUREMENT_HEADER_ID" ;;
  }

  dimension: document_type {
    type: string
    sql: ${TABLE}."DOCUMENT_TYPE" ;;
  }

  dimension: document_type_system {
    type: string
    sql: ${TABLE}."DOCUMENT_TYPE_SYSTEM" ;;
  }

  dimension: record_system {
    type: string
    sql: ${TABLE}."RECORD_SYSTEM" ;;
  }

  dimension: source_system {
    type: string
    sql: ${TABLE}."SOURCE_SYSTEM" ;;
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  dimension: document_number {
    type: string
    sql: ${TABLE}."DOCUMENT_NUMBER" ;;
  }

  dimension: document_number_converted_from {
    type: string
    sql: ${TABLE}."DOCUMENT_NUMBER_CONVERTED_FROM" ;;
  }

  dimension: document_number_origin {
    type: string
    sql: ${TABLE}."DOCUMENT_NUMBER_ORIGIN" ;;
  }

  dimension: department_id {
    type: string
    sql: ${TABLE}."DEPARTMENT_ID" ;;
  }

  dimension: department_name {
    type: string
    sql: ${TABLE}."DEPARTMENT_NAME" ;;
  }

  dimension: department_display_name {
    type: string
    sql: ${TABLE}."DEPARTMENT_DISPLAY_NAME" ;;
  }

  dimension: memo {
    type: string
    sql: ${TABLE}."MEMO" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: has_inventory {
    type: yesno
    sql: ${TABLE}."HAS_INVENTORY" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: has_cip {
    type: yesno
    sql: ${TABLE}."HAS_CIP" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: has_expense {
    type: yesno
    sql: ${TABLE}."HAS_EXPENSE" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: has_multiple_departments {
    type: yesno
    sql: ${TABLE}."HAS_MULTIPLE_DEPARTMENTS" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: has_gl_impact {
    type: yesno
    sql: ${TABLE}."HAS_GL_IMPACT" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: document_qty_status {
    type: string
    sql: ${TABLE}."DOCUMENT_QTY_STATUS" ;;
  }

  dimension: document_qty_status_converted_from {
    type: string
    sql: ${TABLE}."DOCUMENT_QTY_STATUS_CONVERTED_FROM" ;;
  }

  dimension: document_qty_status_origin {
    type: string
    sql: ${TABLE}."DOCUMENT_QTY_STATUS_ORIGIN" ;;
  }

  dimension: document_amt_status {
    type: string
    sql: ${TABLE}."DOCUMENT_AMT_STATUS" ;;
  }

  dimension: document_amt_status_converted_from {
    type: string
    sql: ${TABLE}."DOCUMENT_AMT_STATUS_CONVERTED_FROM" ;;
  }

  dimension: document_amt_status_origin {
    type: string
    sql: ${TABLE}."DOCUMENT_AMT_STATUS_ORIGIN" ;;
  }

  dimension: intacct_status {
    type: string
    sql: ${TABLE}."INTACCT_STATUS" ;;
  }

  dimension: vic_status {
    type: string
    sql: ${TABLE}."VIC_STATUS" ;;
  }

  dimension: t3_status {
    type: string
    sql: ${TABLE}."T3_STATUS" ;;
  }

  dimension_group: date_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_CREATED" ;;
    group_label: "Dates"
  }

  dimension_group: date_due {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_DUE" ;;
    group_label: "Dates"
  }

  dimension_group: date_gl_posted {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_GL_POSTED" ;;
    group_label: "Dates"
  }

  dimension_group: date_converted_from_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_CONVERTED_FROM_CREATED" ;;
    group_label: "Dates"
  }

  dimension_group: date_converted_from_gl_posted {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_CONVERTED_FROM_GL_POSTED" ;;
    group_label: "Dates"
  }

  dimension_group: date_origin_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_ORIGIN_CREATED" ;;
    group_label: "Dates"
  }

  dimension_group: date_origin_gl_posted {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_ORIGIN_GL_POSTED" ;;
    group_label: "Dates"
  }

  dimension: qty_requested {
    type: number
    sql: ${TABLE}."QTY_REQUESTED" ;;
    group_label: "Quantities"
  }

  dimension: qty_converted {
    type: number
    sql: ${TABLE}."QTY_CONVERTED" ;;
    group_label: "Quantities"
  }

  dimension: qty_remaining {
    type: number
    sql: ${TABLE}."QTY_REMAINING" ;;
    group_label: "Quantities"
  }

  dimension: amount_requested {
    type: number
    sql: ${TABLE}."AMOUNT_REQUESTED" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: amount_converted {
    type: number
    sql: ${TABLE}."AMOUNT_CONVERTED" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: amount_remaining {
    type: number
    sql: ${TABLE}."AMOUNT_REMAINING" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: qty_requested_inventory {
    type: number
    sql: ${TABLE}."QTY_REQUESTED_INVENTORY" ;;
    group_label: "Quantities"
  }

  dimension: qty_converted_inventory {
    type: number
    sql: ${TABLE}."QTY_CONVERTED_INVENTORY" ;;
    group_label: "Quantities"
  }

  dimension: qty_remaining_inventory {
    type: number
    sql: ${TABLE}."QTY_REMAINING_INVENTORY" ;;
    group_label: "Quantities"
  }

  dimension: amount_requested_inventory {
    type: number
    sql: ${TABLE}."AMOUNT_REQUESTED_INVENTORY" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: amount_converted_inventory {
    type: number
    sql: ${TABLE}."AMOUNT_CONVERTED_INVENTORY" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: amount_remaining_inventory {
    type: number
    sql: ${TABLE}."AMOUNT_REMAINING_INVENTORY" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: qty_requested_cip {
    type: number
    sql: ${TABLE}."QTY_REQUESTED_CIP" ;;
    group_label: "Quantities"
  }

  dimension: qty_converted_cip {
    type: number
    sql: ${TABLE}."QTY_CONVERTED_CIP" ;;
    group_label: "Quantities"
  }

  dimension: qty_remaining_cip {
    type: number
    sql: ${TABLE}."QTY_REMAINING_CIP" ;;
    group_label: "Quantities"
  }

  dimension: amount_requested_cip {
    type: number
    sql: ${TABLE}."AMOUNT_REQUESTED_CIP" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: amount_converted_cip {
    type: number
    sql: ${TABLE}."AMOUNT_CONVERTED_CIP" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: amount_remaining_cip {
    type: number
    sql: ${TABLE}."AMOUNT_REMAINING_CIP" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: qty_requested_expense {
    type: number
    sql: ${TABLE}."QTY_REQUESTED_EXPENSE" ;;
    group_label: "Quantities"
  }

  dimension: amount_requested_expense {
    type: number
    sql: ${TABLE}."AMOUNT_REQUESTED_EXPENSE" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: qty_converted_expense {
    type: number
    sql: ${TABLE}."QTY_CONVERTED_EXPENSE" ;;
    group_label: "Quantities"
  }

  dimension: amount_converted_expense {
    type: number
    sql: ${TABLE}."AMOUNT_CONVERTED_EXPENSE" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: qty_remaining_expense {
    type: number
    sql: ${TABLE}."QTY_REMAINING_EXPENSE" ;;
    group_label: "Quantities"
  }

  dimension: amount_remaining_expense {
    type: number
    sql: ${TABLE}."AMOUNT_REMAINING_EXPENSE" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: email_created_by {
    type: string
    sql: ${TABLE}."EMAIL_CREATED_BY" ;;
  }

  dimension: email_modified_by {
    type: string
    sql: ${TABLE}."EMAIL_MODIFIED_BY" ;;
  }

  dimension: email_archived_by {
    type: string
    sql: ${TABLE}."EMAIL_ARCHIVED_BY" ;;
  }

  dimension: email_site_owner {
    type: string
    sql: ${TABLE}."EMAIL_SITE_OWNER" ;;
  }

  dimension: fk_document_t3_header_id {
    type: string
    sql: ${TABLE}."FK_DOCUMENT_T3_HEADER_ID" ;;
    group_label: "Foreign Keys"
  }

  dimension: fk_document_intacct_header_id {
    type: number
    sql: ${TABLE}."FK_DOCUMENT_INTACCT_HEADER_ID" ;;
    value_format_name: id
    group_label: "Foreign Keys"
  }

  dimension: fk_document_vic_header_id {
    type: string
    sql: ${TABLE}."FK_DOCUMENT_VIC_HEADER_ID" ;;
    group_label: "Foreign Keys"
  }

  dimension: fk_converted_from_t3_header_id {
    type: string
    sql: ${TABLE}."FK_CONVERTED_FROM_T3_HEADER_ID" ;;
    group_label: "Foreign Keys"
  }

  dimension: fk_converted_from_intacct_header_id {
    type: number
    sql: ${TABLE}."FK_CONVERTED_FROM_INTACCT_HEADER_ID" ;;
    value_format_name: id
    group_label: "Foreign Keys"
  }

  dimension: fk_converted_from_vic_header_id {
    type: string
    sql: ${TABLE}."FK_CONVERTED_FROM_VIC_HEADER_ID" ;;
    group_label: "Foreign Keys"
  }

  dimension: fk_origin_t3_header_id {
    type: string
    sql: ${TABLE}."FK_ORIGIN_T3_HEADER_ID" ;;
    group_label: "Foreign Keys"
  }

  dimension: fk_origin_intacct_header_id {
    type: number
    sql: ${TABLE}."FK_ORIGIN_INTACCT_HEADER_ID" ;;
    value_format_name: id
    group_label: "Foreign Keys"
  }

  dimension: fk_origin_vic_header_id {
    type: string
    sql: ${TABLE}."FK_ORIGIN_VIC_HEADER_ID" ;;
    group_label: "Foreign Keys"
  }

  dimension: url_document_t3 {
    type: string
    sql: ${TABLE}."URL_DOCUMENT_T3" ;;
    link: {
      label: "URL Document T3"
      url: "{{ value }}"
    }
  }

  dimension: url_document_intacct {
    type: string
    sql: ${TABLE}."URL_DOCUMENT_INTACCT" ;;
    link: {
      label: "URL Document Intacct"
      url: "{{ value }}"
    }
  }

  dimension: url_document_vic {
    type: string
    sql: ${TABLE}."URL_DOCUMENT_VIC" ;;
    link: {
      label: "URL Document Vic"
      url: "{{ value }}"
    }
  }

  dimension: url_converted_from_t3 {
    type: string
    sql: ${TABLE}."URL_CONVERTED_FROM_T3" ;;
    link: {
      label: "URL Converted From T3"
      url: "{{ value }}"
    }
  }

  dimension: url_converted_from_intacct {
    type: string
    sql: ${TABLE}."URL_CONVERTED_FROM_INTACCT" ;;
    link: {
      label: "URL Converted From Intacct"
      url: "{{ value }}"
    }
  }

  dimension: url_converted_from_vic {
    type: string
    sql: ${TABLE}."URL_CONVERTED_FROM_VIC" ;;
    link: {
      label: "URL Converted From Vic"
      url: "{{ value }}"
    }
  }

  dimension: url_origin_t3 {
    type: string
    sql: ${TABLE}."URL_ORIGIN_T3" ;;
    link: {
      label: "URL Origin T3"
      url: "{{ value }}"
    }
  }

  dimension: url_origin_intacct {
    type: string
    sql: ${TABLE}."URL_ORIGIN_INTACCT" ;;
    link: {
      label: "URL Origin Intacct"
      url: "{{ value }}"
    }
  }

  dimension: url_origin_vic {
    type: string
    sql: ${TABLE}."URL_ORIGIN_VIC" ;;
    link: {
      label: "URL Origin Vic"
      url: "{{ value }}"
    }
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

  dimension_group: timestamp_archived {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_ARCHIVED" ;;
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
      pk_procurement_header_id,
      document_type,
      document_type_system,
      record_system,
      source_system,
      vendor_id,
      vendor_name,
      document_number,
      document_number_converted_from,
      document_number_origin,
      department_id,
      department_name,
      department_display_name,
      memo,
      description,
      has_inventory,
      has_cip,
      has_expense,
      has_multiple_departments,
      has_gl_impact,
      document_qty_status,
      document_qty_status_converted_from,
      document_qty_status_origin,
      document_amt_status,
      document_amt_status_converted_from,
      document_amt_status_origin,
      intacct_status,
      vic_status,
      t3_status,
      date_created_date,
      date_due_date,
      date_gl_posted_date,
      date_converted_from_created_date,
      date_converted_from_gl_posted_date,
      date_origin_created_date,
      date_origin_gl_posted_date,
      qty_requested,
      qty_converted,
      qty_remaining,
      amount_requested,
      amount_converted,
      amount_remaining,
      qty_requested_inventory,
      qty_converted_inventory,
      qty_remaining_inventory,
      amount_requested_inventory,
      amount_converted_inventory,
      amount_remaining_inventory,
      qty_requested_cip,
      qty_converted_cip,
      qty_remaining_cip,
      amount_requested_cip,
      amount_converted_cip,
      amount_remaining_cip,
      qty_requested_expense,
      amount_requested_expense,
      qty_converted_expense,
      amount_converted_expense,
      qty_remaining_expense,
      amount_remaining_expense,
      email_created_by,
      email_modified_by,
      email_archived_by,
      email_site_owner,
      fk_document_t3_header_id,
      fk_document_intacct_header_id,
      fk_document_vic_header_id,
      fk_converted_from_t3_header_id,
      fk_converted_from_intacct_header_id,
      fk_converted_from_vic_header_id,
      fk_origin_t3_header_id,
      fk_origin_intacct_header_id,
      fk_origin_vic_header_id,
      url_document_t3,
      url_document_intacct,
      url_document_vic,
      url_converted_from_t3,
      url_converted_from_intacct,
      url_converted_from_vic,
      url_origin_t3,
      url_origin_intacct,
      url_origin_vic,
      timestamp_created_date,
      timestamp_modified_date,
      timestamp_archived_date,
      timestamp_loaded_date,
    ]
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: total_amount_requested {
    type: sum
    sql: ${TABLE}."AMOUNT_REQUESTED" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_converted {
    type: sum
    sql: ${TABLE}."AMOUNT_CONVERTED" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_remaining {
    type: sum
    sql: ${TABLE}."AMOUNT_REMAINING" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_requested_inventory {
    type: sum
    sql: ${TABLE}."AMOUNT_REQUESTED_INVENTORY" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_converted_inventory {
    type: sum
    sql: ${TABLE}."AMOUNT_CONVERTED_INVENTORY" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_remaining_inventory {
    type: sum
    sql: ${TABLE}."AMOUNT_REMAINING_INVENTORY" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_requested_cip {
    type: sum
    sql: ${TABLE}."AMOUNT_REQUESTED_CIP" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_converted_cip {
    type: sum
    sql: ${TABLE}."AMOUNT_CONVERTED_CIP" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_remaining_cip {
    type: sum
    sql: ${TABLE}."AMOUNT_REMAINING_CIP" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_requested_expense {
    type: sum
    sql: ${TABLE}."AMOUNT_REQUESTED_EXPENSE" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_converted_expense {
    type: sum
    sql: ${TABLE}."AMOUNT_CONVERTED_EXPENSE" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_remaining_expense {
    type: sum
    sql: ${TABLE}."AMOUNT_REMAINING_EXPENSE" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: avg_qty_requested {
    type: average
    sql: ${TABLE}."QTY_REQUESTED" ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: avg_qty_converted {
    type: average
    sql: ${TABLE}."QTY_CONVERTED" ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: avg_qty_remaining {
    type: average
    sql: ${TABLE}."QTY_REMAINING" ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: avg_qty_requested_inventory {
    type: average
    sql: ${TABLE}."QTY_REQUESTED_INVENTORY" ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: avg_qty_converted_inventory {
    type: average
    sql: ${TABLE}."QTY_CONVERTED_INVENTORY" ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: avg_qty_remaining_inventory {
    type: average
    sql: ${TABLE}."QTY_REMAINING_INVENTORY" ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: avg_qty_requested_cip {
    type: average
    sql: ${TABLE}."QTY_REQUESTED_CIP" ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: avg_qty_converted_cip {
    type: average
    sql: ${TABLE}."QTY_CONVERTED_CIP" ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: avg_qty_remaining_cip {
    type: average
    sql: ${TABLE}."QTY_REMAINING_CIP" ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: avg_qty_requested_expense {
    type: average
    sql: ${TABLE}."QTY_REQUESTED_EXPENSE" ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: avg_qty_converted_expense {
    type: average
    sql: ${TABLE}."QTY_CONVERTED_EXPENSE" ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: avg_qty_remaining_expense {
    type: average
    sql: ${TABLE}."QTY_REMAINING_EXPENSE" ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }
}
