view: parts {
  sql_table_name: "ES_WAREHOUSE"."INVENTORY"."PARTS"
    ;;
  drill_fields: [part_id]

  dimension: part_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."PART_ID" ;;
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

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension_group: date_archived {
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
    sql: CAST(${TABLE}."DATE_ARCHIVED" AS TIMESTAMP_NTZ) ;;
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
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
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
    sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: duplicate_of_id {
    type: number
    sql: ${TABLE}."DUPLICATE_OF_ID" ;;
  }

  dimension: item_id {
    type: string
    sql: ${TABLE}."ITEM_ID" ;;
  }

  dimension: part_number {
    type: string
    sql: ${TABLE}."PART_NUMBER" ;;
  }

  dimension: part_type_id {
    type: number
    sql: ${TABLE}."PART_TYPE_ID" ;;
  }

  dimension: provider_id {
    type: number
    sql: ${TABLE}."PROVIDER_ID" ;;
  }

  dimension: provider_part_number_id {
    type: number
    sql: ${TABLE}."PROVIDER_PART_NUMBER_ID" ;;
  }

  dimension: part_name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: search {
    type: string
    sql: ${TABLE}."SEARCH" ;;
  }

  dimension: verified {
    type: yesno
    sql: ${TABLE}."VERIFIED" ;;
  }

  dimension: UPC {
    type: string
    sql: ${TABLE}."UPC" ;;
  }

  measure: count {
    type: count
    drill_fields: [part_id]
  }

  dimension: msrp {
    type: number
    sql: ${TABLE}."MSRP" ;;
  }
}
