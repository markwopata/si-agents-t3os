view: telematics_part_ids {
  sql_table_name:ANALYTICS.PARTS_INVENTORY.TELEMATICS_PART_IDS ;;

  dimension: part_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.part_id ;;
  }

  dimension: part_type {
    type: string
    sql: iff(${part_id} is null, 'Other', 'Telematics');;
  }
}
