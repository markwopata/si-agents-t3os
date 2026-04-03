view: costentory__po_headers {
  sql_table_name: "COSTENTORY_GOLD"."COSTENTORY__PO_HEADERS" ;;

  dimension: pk_po_header_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."PK_PO_HEADER_ID" ;;
  }

  dimension: id_vendor {
    type: string
    sql: ${TABLE}."ID_VENDOR" ;;
  }

  dimension: name_vendor {
    type: string
    sql: ${TABLE}."NAME_VENDOR" ;;
  }

  dimension: po_number {
    type: string
    sql: ${TABLE}."PO_NUMBER" ;;
  }

  dimension: status_po {
    type: string
    sql: ${TABLE}."STATUS_PO" ;;
  }

  dimension_group: date_promised {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_PROMISED" ;;
  }

  dimension: amount_approved {
    type: number
    sql: ${TABLE}."AMOUNT_APPROVED" ;;
    value_format_name: usd
  }

  dimension: search {
    type: string
    sql: ${TABLE}."SEARCH" ;;
  }

  dimension: reference {
    type: string
    sql: ${TABLE}."REFERENCE" ;;
  }

  dimension: external_po_id {
    type: string
    sql: ${TABLE}."EXTERNAL_PO_ID" ;;
  }

  dimension: is_external {
    type: yesno
    sql: ${TABLE}."IS_EXTERNAL" ;;
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

  dimension: qty_ordered {
    type: number
    sql: ${TABLE}."QTY_ORDERED" ;;
  }

  dimension: qty_accepted {
    type: number
    sql: ${TABLE}."QTY_ACCEPTED" ;;
  }

  dimension: qty_rejected {
    type: number
    sql: ${TABLE}."QTY_REJECTED" ;;
  }

  dimension: qty_received {
    type: number
    sql: ${TABLE}."QTY_RECEIVED" ;;
  }

  dimension: amount_ordered {
    type: number
    sql: ${TABLE}."AMOUNT_ORDERED" ;;
    value_format_name: usd
  }

  dimension: amount_accepted {
    type: number
    sql: ${TABLE}."AMOUNT_ACCEPTED" ;;
    value_format_name: usd
  }

  dimension: amount_rejected {
    type: number
    sql: ${TABLE}."AMOUNT_REJECTED" ;;
    value_format_name: usd
  }

  dimension: amount_received {
    type: number
    sql: ${TABLE}."AMOUNT_RECEIVED" ;;
    value_format_name: usd
  }

  dimension: name_requesting_branch {
    type: string
    sql: ${TABLE}."NAME_REQUESTING_BRANCH" ;;
  }

  dimension: name_deliver_to_branch {
    type: string
    sql: ${TABLE}."NAME_DELIVER_TO_BRANCH" ;;
  }

  dimension: name_effective_branch {
    type: string
    sql: ${TABLE}."NAME_EFFECTIVE_BRANCH" ;;
  }

  dimension: name_store {
    type: string
    sql: ${TABLE}."NAME_STORE" ;;
  }

  dimension: name_created_by {
    type: string
    sql: ${TABLE}."NAME_CREATED_BY" ;;
  }

  dimension: email_created_by {
    type: string
    sql: ${TABLE}."EMAIL_CREATED_BY" ;;
  }

  dimension: name_modified_by {
    type: string
    sql: ${TABLE}."NAME_MODIFIED_BY" ;;
  }

  dimension: email_modified_by {
    type: string
    sql: ${TABLE}."EMAIL_MODIFIED_BY" ;;
  }

  dimension: name_archived_by {
    type: string
    sql: ${TABLE}."NAME_ARCHIVED_BY" ;;
  }

  dimension: email_archived_by {
    type: string
    sql: ${TABLE}."EMAIL_ARCHIVED_BY" ;;
  }

  dimension: email_gm {
    type: string
    sql: ${TABLE}."EMAIL_GM" ;;
  }

  dimension: num_days_since_created {
    type: number
    sql: ${TABLE}."NUM_DAYS_SINCE_CREATED" ;;
    value_format_name: id
  }

  dimension: num_days_since_first_receipt {
    type: number
    sql: ${TABLE}."NUM_DAYS_SINCE_FIRST_RECEIPT" ;;
    value_format_name: id
  }

  dimension: num_days_since_last_receipt {
    type: number
    sql: ${TABLE}."NUM_DAYS_SINCE_LAST_RECEIPT" ;;
    value_format_name: id
  }

  dimension: url_t3 {
    type: string
    sql: ${TABLE}."URL_T3" ;;
    link: {
      label: "URL T3"
      url: "{{ value }}"
    }
  }

  dimension: fk_company_id {
    type: number
    sql: ${TABLE}."FK_COMPANY_ID" ;;
    value_format_name: id
  }

  dimension: fk_effective_branch_id {
    type: number
    sql: ${TABLE}."FK_EFFECTIVE_BRANCH_ID" ;;
    value_format_name: id
  }

  dimension: fk_requesting_branch_id {
    type: number
    sql: ${TABLE}."FK_REQUESTING_BRANCH_ID" ;;
    value_format_name: id
  }

  dimension: fk_deliver_to_id {
    type: number
    sql: ${TABLE}."FK_DELIVER_TO_ID" ;;
    value_format_name: id
  }

  dimension: fk_store_id {
    type: number
    sql: ${TABLE}."FK_STORE_ID" ;;
    value_format_name: id
  }

  dimension: fk_parent_store_id {
    type: number
    sql: ${TABLE}."FK_PARENT_STORE_ID" ;;
    value_format_name: id
  }

  dimension: fk_vendor_snapshot_id {
    type: string
    sql: ${TABLE}."FK_VENDOR_SNAPSHOT_ID" ;;
  }

  dimension: fk_deliver_to_snapshot_id {
    type: string
    sql: ${TABLE}."FK_DELIVER_TO_SNAPSHOT_ID" ;;
  }

  dimension: fk_cost_center_snapshot_id {
    type: string
    sql: ${TABLE}."FK_COST_CENTER_SNAPSHOT_ID" ;;
  }

  dimension: fk_created_by_user_id {
    type: number
    sql: ${TABLE}."FK_CREATED_BY_USER_ID" ;;
    value_format_name: id
  }

  dimension: fk_modified_by_user_id {
    type: number
    sql: ${TABLE}."FK_MODIFIED_BY_USER_ID" ;;
    value_format_name: id
  }

  dimension: fk_archived_by_user_id {
    type: number
    sql: ${TABLE}."FK_ARCHIVED_BY_USER_ID" ;;
    value_format_name: id
  }

  dimension_group: timestamp_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_CREATED" ;;
  }

  dimension_group: timestamp_modified {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_MODIFIED" ;;
  }

  dimension_group: timestamp_first_receipt {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_FIRST_RECEIPT" ;;
  }

  dimension_group: timestamp_last_receipt {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_LAST_RECEIPT" ;;
  }

  dimension_group: timestamp_archived {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_ARCHIVED" ;;
  }

  dimension_group: timestamp_loaded {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_LOADED" ;;
  }

  set: detail {
    fields: [
      pk_po_header_id,
      id_vendor,
      name_vendor,
      po_number,
      status_po,
      date_promised_date,
      amount_approved,
      search,
      reference,
      external_po_id,
      is_external,
      is_archived,
      qty_ordered,
      qty_accepted,
      qty_rejected,
      qty_received,
      amount_ordered,
      amount_accepted,
      amount_rejected,
      amount_received,
      name_requesting_branch,
      name_deliver_to_branch,
      name_effective_branch,
      name_store,
      name_created_by,
      email_created_by,
      name_modified_by,
      email_modified_by,
      name_archived_by,
      email_archived_by,
      email_gm,
      num_days_since_created,
      num_days_since_first_receipt,
      num_days_since_last_receipt,
      url_t3,
      fk_company_id,
      fk_effective_branch_id,
      fk_requesting_branch_id,
      fk_deliver_to_id,
      fk_store_id,
      fk_parent_store_id,
      fk_vendor_snapshot_id,
      fk_deliver_to_snapshot_id,
      fk_cost_center_snapshot_id,
      fk_created_by_user_id,
      fk_modified_by_user_id,
      fk_archived_by_user_id,
      timestamp_created_date,
      timestamp_modified_date,
      timestamp_first_receipt_date,
      timestamp_last_receipt_date,
      timestamp_archived_date,
      timestamp_loaded_date,
    ]
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: total_amount_approved {
    type: sum
    sql: ${TABLE}."AMOUNT_APPROVED" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_ordered {
    type: sum
    sql: ${TABLE}."AMOUNT_ORDERED" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_accepted {
    type: sum
    sql: ${TABLE}."AMOUNT_ACCEPTED" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_rejected {
    type: sum
    sql: ${TABLE}."AMOUNT_REJECTED" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_received {
    type: sum
    sql: ${TABLE}."AMOUNT_RECEIVED" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }
}
