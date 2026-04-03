view: v_parts {
  view_label: "Parts"
  sql_table_name: "GOLD"."V_PARTS" ;;

  dimension: part_category_id {
    type: number
    sql: ${TABLE}."PART_CATEGORY_ID" ;;
  }
  dimension: part_category_name {
    type: string
    sql: ${TABLE}."PART_CATEGORY_NAME" ;;
  }
  dimension: part_id {
    type: number
    sql: ${TABLE}."PART_ID" ;;
  }
  dimension: part_internal_use {
    type: yesno
    sql: ${TABLE}."PART_INTERNAL_USE" ;;
  }
  dimension: part_key {
    type: number
    primary_key: yes
    sql: ${TABLE}."PART_KEY" ;;
  }
  dimension: part_manufacturer_number {
    type: string
    sql: ${TABLE}."PART_MANUFACTURER_NUMBER" ;;
  }
  dimension: part_name {
    type: string
    sql: ${TABLE}."PART_NAME" ;;
  }
  dimension: part_number {
    type: string
    sql: ${TABLE}."PART_NUMBER" ;;
  }
  dimension: part_provider_id {
    type: number
    sql: ${TABLE}."PART_PROVIDER_ID" ;;
  }
  dimension: part_provider_name {
    type: string
    sql: ${TABLE}."PART_PROVIDER_NAME" ;;
  }
  dimension: part_recordtimestamp {
    type: date
    sql: ${TABLE}."PART_RECORDTIMESTAMP" ;;
  }
  dimension: part_source {
    type: string
    sql: ${TABLE}."PART_SOURCE" ;;
  }
  dimension: part_type_description {
    type: string
    sql: ${TABLE}."PART_TYPE_DESCRIPTION" ;;
  }
  dimension: part_type_id {
    type: number
    sql: ${TABLE}."PART_TYPE_ID" ;;
  }
  measure: count {
    type: count
    drill_fields: [part_provider_name, part_name, part_category_name]
  }
}
