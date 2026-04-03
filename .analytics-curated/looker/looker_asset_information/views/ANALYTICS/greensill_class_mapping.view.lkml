view: greensill_class_mapping {
  sql_table_name: "PUBLIC"."GREENSILL_CLASS_MAPPING"
    ;;

  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }

  dimension: greensill_class {
    type: string
    sql: ${TABLE}."GREENSILL_CLASS" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
