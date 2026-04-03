view: equipment_classes_itl {
  sql_table_name: "ANALYTICS"."PUBLIC"."EQUIPMENT_CLASSES_ITL"
    ;;

  dimension: equipment_class {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS" ;;
  }

  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
