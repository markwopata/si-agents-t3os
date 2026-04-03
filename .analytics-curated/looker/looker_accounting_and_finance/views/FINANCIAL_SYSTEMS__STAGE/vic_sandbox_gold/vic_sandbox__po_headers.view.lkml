view: vic_sandbox__po_headers {
  sql_table_name: "VIC_GOLD"."VIC_SANDBOX__PO_HEADERS" ;;

  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_CREATED" ;;
  }
  dimension_group: date_delivered {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_DELIVERED" ;;
  }
  dimension_group: date_issued {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_ISSUED" ;;
  }
  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }
  dimension: fk_extract_hash_id {
    type: number
    sql: ${TABLE}."FK_EXTRACT_HASH_ID" ;;
  }
  dimension: fk_source_po_header_id {
    type: string
    sql: ${TABLE}."FK_SOURCE_PO_HEADER_ID" ;;
  }
  dimension: id_vendor {
    type: string
    sql: ${TABLE}."ID_VENDOR" ;;
  }
  dimension: name_environment {
    type: string
    sql: ${TABLE}."NAME_ENVIRONMENT" ;;
  }
  dimension: name_vendor {
    type: string
    sql: ${TABLE}."NAME_VENDOR" ;;
  }
  dimension: pk_vic_po_header_id {
    type: string
    sql: ${TABLE}."PK_VIC_PO_HEADER_ID" ;;
    primary_key: yes
  }
  dimension: po_number {
    type: string
    sql: ${TABLE}."PO_NUMBER" ;;
  }
  dimension: status_matching {
    type: string
    sql: ${TABLE}."STATUS_MATCHING" ;;
  }
  dimension_group: timestamp_extracted {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TIMESTAMP_EXTRACTED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: timestamp_modified {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TIMESTAMP_MODIFIED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: type_matching {
    type: string
    sql: ${TABLE}."TYPE_MATCHING" ;;
  }
  dimension: type_po_document {
    type: string
    sql: ${TABLE}."TYPE_PO_DOCUMENT" ;;
  }
  dimension: url_source {
    type: string
    sql: ${TABLE}."URL_SOURCE" ;;
  }
  dimension: url_vic {
    type: string
    sql: ${TABLE}."URL_VIC" ;;
  }
  measure: count {
    type: count
  }
}
