view: part_mapping {
  sql_table_name: "ANALYTICS"."PARTS_INVENTORY"."PART_MAPPING" ;;

  dimension: _es_update_timestamp {
    type: string
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }
  dimension: es_part_id {
    type: number
    sql: ${TABLE}."ES_PART_ID" ;;
    value_format_name: id
  }
  dimension: oem_part_id {
    type: number
    sql: ${TABLE}."OEM_PART_ID" ;;
    value_format_name: id
  }
  dimension: oem_part_number {
    type: string
    sql: ${TABLE}."OEM_PART_NUMBER" ;;
  }
  dimension: part_id {
    type: number
    sql: ${TABLE}."PART_ID" ;;
    value_format_name: id
  }
  dimension: updated_email {
    type: string
    sql: ${TABLE}."UPDATED_EMAIL" ;;
  }
  dimension: updated_user_id {
    type: number
    sql: ${TABLE}."UPDATED_USER_ID" ;;
    value_format_name: id
  }
  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }
  dimension: vendor_part_number {
    type: string
    sql: ${TABLE}."VENDOR_PART_NUMBER" ;;
  }
  measure: count {
    type: count
  }
}
