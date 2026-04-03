view: part_back_order_requests_board {
  sql_table_name: "ANALYTICS"."MONDAY"."PART_BACK_ORDER_REQUESTS_BOARD" ;;

  dimension: additional_notes {
    type: string
    sql: ${TABLE}."ADDITIONAL_NOTES" ;;
  }
  dimension: back_order_owner_name {
    type: string
    sql: ${TABLE}."BACK_ORDER_OWNER_NAME" ;;
  }
  dimension: back_order_status {
    type: string
    sql: ${TABLE}."BACK_ORDER_STATUS" ;;
  }
  dimension: board_id {
    type: string
    sql: ${TABLE}."BOARD_ID" ;;
  }
  dimension: equipment_priority {
    type: string
    sql: ${TABLE}."EQUIPMENT_PRIORITY" ;;
  }
  dimension: equipment_serial_number {
    type: string
    sql: ${TABLE}."EQUIPMENT_SERIAL_NUMBER" ;;
  }
  dimension: equipmentshare_po_number {
    type: string
    sql: ${TABLE}."EQUIPMENTSHARE_PO_NUMBER" ;;
  }
  dimension: group_id {
    type: string
    sql: ${TABLE}."GROUP_ID" ;;
  }
  dimension: group_title {
    type: string
    sql: ${TABLE}."GROUP_TITLE" ;;
  }
  dimension: item_id {
    type: string
    sql: ${TABLE}."ITEM_ID" ;;
  }
  dimension: machine_age {
    type: string
    sql: ${TABLE}."MACHINE_AGE" ;;
  }
  dimension: make_model {
    type: string
    sql: ${TABLE}."MAKE_MODEL" ;;
  }
  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }
  dimension: oem {
    type: string
    sql: ${TABLE}."OEM" ;;
  }
  dimension: oem_order_number {
    type: string
    sql: ${TABLE}."OEM_ORDER_NUMBER" ;;
  }
  dimension: oem_text_entry {
    type: string
    sql: ${TABLE}."OEM_TEXT_ENTRY" ;;
  }
  dimension_group: order {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."ORDER_DATE" ;;
  }
  dimension: part_description {
    type: string
    sql: ${TABLE}."PART_DESCRIPTION" ;;
  }
  dimension: part_number {
    type: string
    sql: ${TABLE}."PART_NUMBER" ;;
  }
  dimension: price {
    type: number
    sql: ${TABLE}."PRICE" ;;
  }
  dimension: region_name_number {
    type: string
    sql: ${TABLE}."REGION_NAME_NUMBER" ;;
  }
  dimension: strategic_sourcing_manager_name {
    type: string
    sql: ${TABLE}."STRATEGIC_SOURCING_MANAGER_NAME" ;;
  }
  dimension_group: submission {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."SUBMISSION_DATE" ;;
  }
  dimension: under_warranty_status {
    type: string
    sql: ${TABLE}."UNDER_WARRANTY_STATUS" ;;
  }
  dimension: user_email {
    type: string
    sql: ${TABLE}."USER_EMAIL" ;;
  }
  dimension: vendor_update_notes {
    type: string
    sql: ${TABLE}."VENDOR_UPDATE_NOTES" ;;
  }
  dimension: vendor_update_notes2 {
    type: string
    sql: ${TABLE}."VENDOR_UPDATE_NOTES2" ;;
  }
  dimension: vendor_updates {
    type: string
    sql: concat(${vendor_update_notes},' ',${vendor_update_notes2}) ;;
  }
  dimension: work_order_number {
    type: string
    sql: ${TABLE}."WORK_ORDER_NUMBER" ;;
  }
  measure: count {
    type: count
    drill_fields: [back_order_owner_name, market_name, strategic_sourcing_manager_name]
  }
}
