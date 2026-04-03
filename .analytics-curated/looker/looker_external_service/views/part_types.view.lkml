view: part_types {
  sql_table_name: "INVENTORY"."PART_TYPES"
    ;;
  drill_fields: [part_type_id]

  dimension: part_type_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."PART_TYPE_ID" ;;
  }

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: class_number {
    type: string
    sql: ${TABLE}."CLASS_NUMBER" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension_group: date_created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension_group: date_updated {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."DATE_UPDATED" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: image_url {
    type: string
    sql: ${TABLE}."IMAGE_URL" ;;
  }

  dimension: part_category_id {
    type: number
    sql: ${TABLE}."PART_CATEGORY_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [part_type_id, parts.count]
  }
}
