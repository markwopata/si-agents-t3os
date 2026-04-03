view: vic__po_lines {
  sql_table_name: "VIC_GOLD"."VIC__PO_LINES" ;;

  dimension: pk_po_line_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."PK_PO_LINE_ID" ;;
  }

  dimension: fk_source_po_line_id {
    type: string
    sql: ${TABLE}."FK_SOURCE_PO_LINE_ID" ;;
    group_label: "Foreign Keys"
  }

  dimension: fk_po_header_id {
    type: string
    sql: ${TABLE}."FK_PO_HEADER_ID" ;;
    group_label: "Foreign Keys"
  }

  dimension: fk_source_po_header_id {
    type: string
    sql: ${TABLE}."FK_SOURCE_PO_HEADER_ID" ;;
    group_label: "Foreign Keys"
  }

  dimension: po_number {
    type: string
    sql: ${TABLE}."PO_NUMBER" ;;
  }

  dimension: po_line_number {
    type: number
    sql: ${TABLE}."PO_LINE_NUMBER" ;;
    value_format_name: id
  }

  dimension: status_po_vic {
    type: string
    sql: ${TABLE}."STATUS_PO_VIC" ;;
  }

  dimension: type_line_matching {
    type: string
    sql: ${TABLE}."TYPE_LINE_MATCHING" ;;
  }

  dimension: status_line_matching {
    type: string
    sql: ${TABLE}."STATUS_LINE_MATCHING" ;;
  }

  dimension: product_number {
    type: string
    sql: ${TABLE}."PRODUCT_NUMBER" ;;
  }

  dimension: product_description {
    type: string
    sql: ${TABLE}."PRODUCT_DESCRIPTION" ;;
  }

  dimension: memo {
    type: string
    sql: ${TABLE}."MEMO" ;;
  }

  dimension: unit_of_measure {
    type: string
    sql: ${TABLE}."UNIT_OF_MEASURE" ;;
  }

  dimension: qty_requested {
    type: number
    sql: ${TABLE}."QTY_REQUESTED" ;;
    group_label: "Quantities"
  }

  dimension: qty_accepted {
    type: number
    sql: ${TABLE}."QTY_ACCEPTED" ;;
    group_label: "Quantities"
  }

  dimension: qty_received {
    type: number
    sql: ${TABLE}."QTY_RECEIVED" ;;
    group_label: "Quantities"
  }

  dimension: amount_unit {
    type: number
    sql: ${TABLE}."AMOUNT_UNIT" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: amount_line {
    type: number
    sql: ${TABLE}."AMOUNT_LINE" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: id_location {
    type: string
    sql: ${TABLE}."ID_LOCATION" ;;
  }

  dimension: name_location {
    type: string
    sql: ${TABLE}."NAME_LOCATION" ;;
  }

  dimension: id_department {
    type: string
    sql: ${TABLE}."ID_DEPARTMENT" ;;
  }

  dimension: name_department {
    type: string
    sql: ${TABLE}."NAME_DEPARTMENT" ;;
  }

  dimension: name_line_memo {
    type: string
    sql: ${TABLE}."NAME_LINE_MEMO" ;;
  }

  dimension: name_line_description {
    type: string
    sql: ${TABLE}."NAME_LINE_DESCRIPTION" ;;
  }

  dimension: name_part_number {
    type: string
    sql: ${TABLE}."NAME_PART_NUMBER" ;;
  }

  dimension: name_part_description {
    type: string
    sql: ${TABLE}."NAME_PART_DESCRIPTION" ;;
  }

  dimension: name_part_provider {
    type: string
    sql: ${TABLE}."NAME_PART_PROVIDER" ;;
  }

  dimension: invoice_items_matched {
    type: string
    sql: ${TABLE}."INVOICE_ITEMS_MATCHED" ;;
  }

  dimension: dimensions {
    type: string
    sql: ${TABLE}."DIMENSIONS" ;;
  }

  dimension: fk_dim_location_id {
    type: string
    sql: ${TABLE}."FK_DIM_LOCATION_ID" ;;
    group_label: "Foreign Keys"
  }

  dimension: fk_dim_department_id {
    type: string
    sql: ${TABLE}."FK_DIM_DEPARTMENT_ID" ;;
    group_label: "Foreign Keys"
  }

  dimension: fk_dim_line_memo_id {
    type: string
    sql: ${TABLE}."FK_DIM_LINE_MEMO_ID" ;;
    group_label: "Foreign Keys"
  }

  dimension: fk_source_dim_line_memo_id {
    type: string
    sql: ${TABLE}."FK_SOURCE_DIM_LINE_MEMO_ID" ;;
    group_label: "Foreign Keys"
  }

  dimension: fk_dim_line_description_id {
    type: string
    sql: ${TABLE}."FK_DIM_LINE_DESCRIPTION_ID" ;;
    group_label: "Foreign Keys"
  }

  dimension: fk_source_dim_line_description_id {
    type: string
    sql: ${TABLE}."FK_SOURCE_DIM_LINE_DESCRIPTION_ID" ;;
    group_label: "Foreign Keys"
  }

  dimension: fk_dim_part_number_id {
    type: string
    sql: ${TABLE}."FK_DIM_PART_NUMBER_ID" ;;
    group_label: "Foreign Keys"
  }

  dimension: fk_source_dim_part_number_id {
    type: string
    sql: ${TABLE}."FK_SOURCE_DIM_PART_NUMBER_ID" ;;
    group_label: "Foreign Keys"
  }

  dimension: fk_dim_part_description_id {
    type: string
    sql: ${TABLE}."FK_DIM_PART_DESCRIPTION_ID" ;;
    group_label: "Foreign Keys"
  }

  dimension: fk_source_dim_part_description_id {
    type: string
    sql: ${TABLE}."FK_SOURCE_DIM_PART_DESCRIPTION_ID" ;;
    group_label: "Foreign Keys"
  }

  dimension: fk_dim_part_provider_id {
    type: string
    sql: ${TABLE}."FK_DIM_PART_PROVIDER_ID" ;;
    group_label: "Foreign Keys"
  }

  dimension: fk_source_dim_part_provider_id {
    type: string
    sql: ${TABLE}."FK_SOURCE_DIM_PART_PROVIDER_ID" ;;
    group_label: "Foreign Keys"
  }

  dimension: name_environment {
    type: string
    sql: ${TABLE}."NAME_ENVIRONMENT" ;;
  }

  dimension: name_environment_alias {
    type: string
    sql: ${TABLE}."NAME_ENVIRONMENT_ALIAS" ;;
  }

  dimension: fk_company_id_numeric {
    type: number
    sql: ${TABLE}."FK_COMPANY_ID_NUMERIC" ;;
    value_format_name: id
    group_label: "Foreign Keys"
  }

  dimension: fk_company_id_uuid {
    type: string
    sql: ${TABLE}."FK_COMPANY_ID_UUID" ;;
    group_label: "Foreign Keys"
  }

  dimension_group: timestamp_modified {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_MODIFIED" ;;
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
      pk_po_line_id,
      fk_source_po_line_id,
      fk_po_header_id,
      fk_source_po_header_id,
      po_number,
      po_line_number,
      status_po_vic,
      type_line_matching,
      status_line_matching,
      product_number,
      product_description,
      memo,
      unit_of_measure,
      qty_requested,
      qty_accepted,
      qty_received,
      amount_unit,
      amount_line,
      id_location,
      name_location,
      id_department,
      name_department,
      name_line_memo,
      name_line_description,
      name_part_number,
      name_part_description,
      name_part_provider,
      invoice_items_matched,
      dimensions,
      fk_dim_location_id,
      fk_dim_department_id,
      fk_dim_line_memo_id,
      fk_source_dim_line_memo_id,
      fk_dim_line_description_id,
      fk_source_dim_line_description_id,
      fk_dim_part_number_id,
      fk_source_dim_part_number_id,
      fk_dim_part_description_id,
      fk_source_dim_part_description_id,
      fk_dim_part_provider_id,
      fk_source_dim_part_provider_id,
      name_environment,
      name_environment_alias,
      fk_company_id_numeric,
      fk_company_id_uuid,
      timestamp_modified_date,
      timestamp_loaded_date,
    ]
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: total_amount_unit {
    type: sum
    sql: ${TABLE}."AMOUNT_UNIT" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_line {
    type: sum
    sql: ${TABLE}."AMOUNT_LINE" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: avg_qty_requested {
    type: average
    sql: ${TABLE}."QTY_REQUESTED" ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: avg_qty_accepted {
    type: average
    sql: ${TABLE}."QTY_ACCEPTED" ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: avg_qty_received {
    type: average
    sql: ${TABLE}."QTY_RECEIVED" ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }
}
