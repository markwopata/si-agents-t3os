view: vic__invoice_lines_v2 {
  sql_table_name: "VIC_GOLD"."VIC__INVOICE_LINES_V2" ;;

  dimension: pk_invoice_line_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."PK_INVOICE_LINE_ID" ;;
  }

  dimension: type_line {
    type: string
    sql: ${TABLE}."TYPE_LINE" ;;
  }

  dimension: line_number {
    type: number
    sql: ${TABLE}."LINE_NUMBER" ;;
    value_format_name: id
  }

  dimension: item_number {
    type: string
    sql: ${TABLE}."ITEM_NUMBER" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: ai_comment {
    type: string
    sql: ${TABLE}."AI_COMMENT" ;;
  }

  dimension: qty_line {
    type: number
    sql: ${TABLE}."QTY_LINE" ;;
    group_label: "Quantities"
  }

  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: amount_net {
    type: number
    sql: ${TABLE}."AMOUNT_NET" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: amount_freight {
    type: number
    sql: ${TABLE}."AMOUNT_FREIGHT" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: amount_tax {
    type: number
    sql: ${TABLE}."AMOUNT_TAX" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: amount_unit_raw {
    type: number
    sql: ${TABLE}."AMOUNT_UNIT_RAW" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: amount_unit {
    type: number
    sql: ${TABLE}."AMOUNT_UNIT" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: amount_unit_discount {
    type: number
    sql: ${TABLE}."AMOUNT_UNIT_DISCOUNT" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: pct_unit_discount {
    type: number
    sql: ${TABLE}."PCT_UNIT_DISCOUNT" ;;
    value_format_name: percent_2
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

  dimension: number_account {
    type: string
    sql: ${TABLE}."NUMBER_ACCOUNT" ;;
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

  dimension: id_inv_item {
    type: string
    sql: ${TABLE}."ID_INV_ITEM" ;;
  }

  dimension: id_pol_item {
    type: string
    sql: ${TABLE}."ID_POL_ITEM" ;;
  }

  dimension: name_inv_item {
    type: string
    sql: ${TABLE}."NAME_INV_ITEM" ;;
  }

  dimension: name_pol_item {
    type: string
    sql: ${TABLE}."NAME_POL_ITEM" ;;
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
    type: string
    sql: ${TABLE}."FK_COMPANY_ID_NUMERIC" ;;
    group_label: "Foreign Keys"
  }

  dimension: fk_company_id_uuid {
    type: string
    sql: ${TABLE}."FK_COMPANY_ID_UUID" ;;
    group_label: "Foreign Keys"
  }

  dimension: fk_vic_cost_account_id {
    type: string
    sql: ${TABLE}."FK_VIC_COST_ACCOUNT_ID" ;;
    group_label: "Foreign Keys"
  }

  dimension: fk_vic_location_id {
    type: string
    sql: ${TABLE}."FK_VIC_LOCATION_ID" ;;
    group_label: "Foreign Keys"
  }

  dimension: fk_vic_department_id {
    type: string
    sql: ${TABLE}."FK_VIC_DEPARTMENT_ID" ;;
    group_label: "Foreign Keys"
  }

  dimension: fk_vic_item_id {
    type: string
    sql: ${TABLE}."FK_VIC_ITEM_ID" ;;
    group_label: "Foreign Keys"
  }

  dimension: fk_invoice_header_id {
    type: string
    sql: ${TABLE}."FK_INVOICE_HEADER_ID" ;;
    group_label: "Foreign Keys"
  }

  dimension: fk_sage_bill_header_id {
    type: string
    sql: ${TABLE}."FK_SAGE_BILL_HEADER_ID" ;;
    group_label: "Foreign Keys"
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

  dimension_group: timestamp_loaded {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_LOADED" ;;
    group_label: "Timestamps"
  }

  set: detail {
    fields: [
      pk_invoice_line_id,
      type_line,
      line_number,
      item_number,
      description,
      ai_comment,
      qty_line,
      amount,
      amount_net,
      amount_freight,
      amount_tax,
      amount_unit_raw,
      amount_unit,
      amount_unit_discount,
      pct_unit_discount,
      po_number,
      po_line_number,
      number_account,
      id_location,
      name_location,
      id_department,
      name_department,
      id_inv_item,
      id_pol_item,
      name_inv_item,
      name_pol_item,
      name_environment,
      name_environment_alias,
      fk_company_id_numeric,
      fk_company_id_uuid,
      fk_vic_cost_account_id,
      fk_vic_location_id,
      fk_vic_department_id,
      fk_vic_item_id,
      fk_invoice_header_id,
      fk_sage_bill_header_id,
      timestamp_created_date,
      timestamp_modified_date,
      timestamp_loaded_date,
    ]
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: total_amount {
    type: sum
    sql: ${TABLE}."AMOUNT" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_net {
    type: sum
    sql: ${TABLE}."AMOUNT_NET" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_freight {
    type: sum
    sql: ${TABLE}."AMOUNT_FREIGHT" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_tax {
    type: sum
    sql: ${TABLE}."AMOUNT_TAX" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_unit_raw {
    type: sum
    sql: ${TABLE}."AMOUNT_UNIT_RAW" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_unit {
    type: sum
    sql: ${TABLE}."AMOUNT_UNIT" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_unit_discount {
    type: sum
    sql: ${TABLE}."AMOUNT_UNIT_DISCOUNT" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: avg_qty_line {
    type: average
    sql: ${TABLE}."QTY_LINE" ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }
}
