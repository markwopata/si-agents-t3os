view: commission_types {
  sql_table_name: "ANALYTICS"."COMMISSION"."COMMISSION_TYPES" ;;
  drill_fields: [commission_type_id]

  dimension: commission_type_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."COMMISSION_TYPE_ID" ;;
  }
  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }
  measure: count {
    type: count
    drill_fields: [commission_type_id, name]
  }
}
