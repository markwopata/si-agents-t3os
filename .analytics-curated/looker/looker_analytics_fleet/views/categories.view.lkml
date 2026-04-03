view: categories {
  sql_table_name: "PUBLIC"."CATEGORIES"
    ;;
  drill_fields: [parent_category_id]

  dimension: parent_category_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."PARENT_CATEGORY_ID" ;;
    hidden: yes
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
    hidden: yes
  }

  dimension: active {
    type: yesno
    sql: ${TABLE}."ACTIVE" ;;
    hidden: yes
  }

  dimension: canonical_name {
    type: string
    sql: ${TABLE}."CANONICAL_NAME" ;;
    hidden: yes
  }

  dimension: category_id {
    type: number
    sql: ${TABLE}."CATEGORY_ID" ;;
    hidden: yes
  }

  dimension: company_division_id {
    type: number
    sql: ${TABLE}."COMPANY_DIVISION_ID" ;;
    hidden: yes
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
    label: "Category Description"
    view_label: "Assets"
  }

  dimension: image {
    type: string
    sql: ${TABLE}."IMAGE" ;;
    hidden: yes
  }

  dimension: layout_script {
    type: string
    sql: ${TABLE}."LAYOUT_SCRIPT" ;;
    hidden: yes
  }

  dimension: name {
    label: "Category Name"
    type: string
    sql: ${TABLE}."NAME" ;;
    view_label: "Assets"
  }

  dimension: singular_name {
    type: string
    sql: ${TABLE}."SINGULAR_NAME" ;;
    hidden: yes
  }

  dimension: sort_index {
    type: number
    sql: ${TABLE}."SORT_INDEX" ;;
    hidden: yes
  }

  measure: count {
    type: count
    drill_fields: [parent_category_id, singular_name, name, canonical_name]
    hidden: yes
  }
}
