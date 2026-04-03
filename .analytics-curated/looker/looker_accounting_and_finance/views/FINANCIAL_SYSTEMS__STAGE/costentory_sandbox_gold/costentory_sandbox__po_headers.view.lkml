view: costentory_sandbox__po_headers {
  sql_table_name: "COSTENTORY_GOLD"."COSTENTORY_SANDBOX__PO_HEADERS" ;;

  dimension: amount_approved {
    type: number
    sql: ${TABLE}."AMOUNT_APPROVED" ;;
  }
  dimension_group: date_promised {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_PROMISED" ;;
  }
  dimension: email_archived_by {
    type: string
    sql: ${TABLE}."EMAIL_ARCHIVED_BY" ;;
  }
  dimension: email_created_by {
    type: string
    sql: ${TABLE}."EMAIL_CREATED_BY" ;;
  }
  dimension: email_modified_by {
    type: string
    sql: ${TABLE}."EMAIL_MODIFIED_BY" ;;
  }
  dimension: external_po_id {
    type: string
    sql: ${TABLE}."EXTERNAL_PO_ID" ;;
  }
  dimension: fk_archived_by_user_id {
    type: number
    sql: ${TABLE}."FK_ARCHIVED_BY_USER_ID" ;;
  }
  dimension: fk_company_id {
    type: number
    sql: ${TABLE}."FK_COMPANY_ID" ;;
  }
  dimension: fk_cost_center_snapshot_id {
    type: string
    sql: ${TABLE}."FK_COST_CENTER_SNAPSHOT_ID" ;;
  }
  dimension: fk_created_by_user_id {
    type: number
    sql: ${TABLE}."FK_CREATED_BY_USER_ID" ;;
  }
  dimension: fk_deliver_to_id {
    type: number
    sql: ${TABLE}."FK_DELIVER_TO_ID" ;;
  }
  dimension: fk_deliver_to_snapshot_id {
    type: string
    sql: ${TABLE}."FK_DELIVER_TO_SNAPSHOT_ID" ;;
  }
  dimension: fk_modified_by_user_id {
    type: number
    sql: ${TABLE}."FK_MODIFIED_BY_USER_ID" ;;
  }
  dimension: fk_parent_store_id {
    type: number
    sql: ${TABLE}."FK_PARENT_STORE_ID" ;;
  }
  dimension: fk_requesting_branch_id {
    type: number
    sql: ${TABLE}."FK_REQUESTING_BRANCH_ID" ;;
  }
  dimension: fk_store_id {
    type: number
    sql: ${TABLE}."FK_STORE_ID" ;;
  }
  dimension: fk_vendor_snapshot_id {
    type: string
    sql: ${TABLE}."FK_VENDOR_SNAPSHOT_ID" ;;
  }
  dimension: id_vendor {
    type: string
    sql: ${TABLE}."ID_VENDOR" ;;
  }
  dimension: is_archived {
    type: yesno
    sql: ${TABLE}."IS_ARCHIVED" ;;
  }
  dimension: is_external {
    type: yesno
    sql: ${TABLE}."IS_EXTERNAL" ;;
  }
  dimension: name_archived_by {
    type: string
    sql: ${TABLE}."NAME_ARCHIVED_BY" ;;
  }
  dimension: name_created_by {
    type: string
    sql: ${TABLE}."NAME_CREATED_BY" ;;
  }
  dimension: name_deliver_to_branch {
    type: string
    sql: ${TABLE}."NAME_DELIVER_TO_BRANCH" ;;
  }
  dimension: name_modified_by {
    type: string
    sql: ${TABLE}."NAME_MODIFIED_BY" ;;
  }
  dimension: name_requesting_branch {
    type: string
    sql: ${TABLE}."NAME_REQUESTING_BRANCH" ;;
  }
  dimension: name_store {
    type: string
    sql: ${TABLE}."NAME_STORE" ;;
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
  dimension: reference {
    type: string
    sql: ${TABLE}."REFERENCE" ;;
  }
  dimension: search {
    type: string
    sql: ${TABLE}."SEARCH" ;;
  }
  dimension: status_po {
    type: string
    sql: ${TABLE}."STATUS_PO" ;;
  }
  dimension_group: timestamp_archived {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TIMESTAMP_ARCHIVED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: timestamp_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_CREATED" ;;
  }
  dimension_group: timestamp_loaded {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TIMESTAMP_LOADED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: timestamp_modified {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_MODIFIED" ;;
  }
  dimension: url_t3 {
    type: string
    sql: ${TABLE}."URL_T3" ;;
  }
  measure: count {
    type: count
  }
}
