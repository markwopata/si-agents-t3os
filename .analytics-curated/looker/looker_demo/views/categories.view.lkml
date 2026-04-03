view: categories {
  sql_table_name: "PUBLIC"."CATEGORIES"
    ;;
  drill_fields: [parent_category_id]

  dimension: parent_category_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."PARENT_CATEGORY_ID" ;;
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

  dimension: active {
    type: yesno
    sql: ${TABLE}."ACTIVE" ;;
  }

  dimension: canonical_name {
    type: string
    sql: ${TABLE}."CANONICAL_NAME" ;;
  }

  dimension: category_id {
    type: number
    sql: ${TABLE}."CATEGORY_ID" ;;
  }

  dimension: company_division_id {
    type: number
    sql: ${TABLE}."COMPANY_DIVISION_ID" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: image {
    type: string
    sql: ${TABLE}."IMAGE" ;;
  }

  dimension: layout_script {
    type: string
    sql: ${TABLE}."LAYOUT_SCRIPT" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: singular_name {
    type: string
    sql: ${TABLE}."SINGULAR_NAME" ;;
  }

  dimension: sort_index {
    type: number
    sql: ${TABLE}."SORT_INDEX" ;;
  }

  measure: count {
    type: count
    drill_fields: [parent_category_id, singular_name, canonical_name, name]
  }
}
