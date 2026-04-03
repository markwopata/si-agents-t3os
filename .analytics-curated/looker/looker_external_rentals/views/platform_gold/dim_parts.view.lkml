view: dim_parts {
  sql_table_name: "PLATFORM"."GOLD"."V_PARTS" ;;

  # PRIMARY KEY
  dimension: part_key {
    primary_key: yes
    type: string
    sql: ${TABLE}."PART_KEY" ;;
    hidden: yes
  }

  # NATURAL KEYS
  dimension: part_source {
    type: string
    sql: ${TABLE}."PART_SOURCE" ;;
    description: "Source system for part data"
  }

  dimension: part_id {
    type: number
    sql: ${TABLE}."PART_ID" ;;
    description: "Natural part ID"
    value_format_name: id
  }

  # PART IDENTIFICATION
  dimension: part_name {
    type: string
    sql: ${TABLE}."PART_NAME" ;;
    description: "Name of the part"
  }

  dimension: part_number {
    type: string
    sql: ${TABLE}."PART_NUMBER" ;;
    description: "Part number"
  }

  dimension: part_manufacturer_number {
    type: string
    sql: ${TABLE}."PART_MANUFACTURER_NUMBER" ;;
    description: "Manufacturer part number"
  }

  # PART TYPE (CLASS)
  dimension: part_type_id {
    type: number
    sql: ${TABLE}."PART_TYPE_ID" ;;
    description: "Part type ID"
  }

  dimension: part_type_description {
    type: string
    sql: ${TABLE}."PART_TYPE_DESCRIPTION" ;;
    description: "Part type description (equivalent to asset class for bulk orders)"
    label: "Part Type (Class)"
  }

  # PART CATEGORY
  dimension: part_category_id {
    type: number
    sql: ${TABLE}."PART_CATEGORY_ID" ;;
    description: "Part category ID"
  }

  dimension: part_category_name {
    type: string
    sql: ${TABLE}."PART_CATEGORY_NAME" ;;
    description: "Part category name"
  }

  # PART PROVIDER
  dimension: part_provider_id {
    type: number
    sql: ${TABLE}."PART_PROVIDER_ID" ;;
    description: "Part provider ID"
  }

  dimension: part_provider_name {
    type: string
    sql: ${TABLE}."PART_PROVIDER_NAME" ;;
    description: "Part provider name"
  }

  # PART STATUS
  dimension: part_archived {
    type: yesno
    sql: ${TABLE}."PART_ARCHIVED" ;;
    description: "Whether the part is archived"
  }

  dimension: part_verified_for_company {
    type: yesno
    sql: ${TABLE}."PART_VERIFIED_FOR_COMPANY" ;;
    description: "Whether the part is verified for the company"
  }

  dimension: part_verified_globally {
    type: yesno
    sql: ${TABLE}."PART_VERIFIED_GLOBALLY" ;;
    description: "Whether the part is verified globally"
  }

  dimension: part_is_global {
    type: yesno
    sql: ${TABLE}."PART_IS_GLOBAL" ;;
    description: "Whether the part is global"
  }

  # PRICING
  dimension: part_msrp {
    type: number
    sql: ${TABLE}."PART_MSRP" ;;
    description: "Manufacturer's suggested retail price"
    value_format_name: usd
  }

  # METADATA
  dimension_group: part_record {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."PART_RECORDTIMESTAMP" ;;
    description: "Record timestamp"
  }

  # MEASURES
  measure: count {
    type: count
    drill_fields: [part_id, part_name, part_type_description, part_category_name]
  }

  measure: total_parts {
    type: count_distinct
    sql: ${part_id} ;;
    description: "Total number of distinct parts"
  }
}
