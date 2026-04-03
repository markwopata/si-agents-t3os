view: part_categorization_structure {
  sql_table_name: "ANALYTICS"."PARTS_INVENTORY"."PART_CATEGORIZATION_STRUCTURE" ;;

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }
  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }
  dimension: part_categorization_id {
    type: number
    primary_key: yes
    sql: ${TABLE}."PART_CATEGORIZATION_ID" ;;
  }
  dimension: part_containers {
    type: string
    sql: ${TABLE}."PART_CONTAINERS" ;;
  }
  dimension: subcategory {
    type: string
    sql: ${TABLE}."SUBCATEGORY" ;;
  }
  dimension: fluids {
    type: yesno
    sql: ${TABLE}."SUBCATEGORY" = 'Fluids & Lubricants' ;;
  }
  measure: count {
    type: count
  }
}
