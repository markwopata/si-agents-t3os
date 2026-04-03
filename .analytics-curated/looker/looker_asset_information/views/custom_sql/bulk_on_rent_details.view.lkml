view: bulk_on_rent_details {
  derived_table: {
      sql:
            select
                 rpa.rental_id
                 , pt.part_type_id
                 , pt.description
                 , p1.PART_ID
                 , p1.part_number
                 , rpa.QUANTITY
                 , rpa.START_DATE::date as start_date
                 , rpa.END_DATE::date as end_date
            from ES_WAREHOUSE.PUBLIC.RENTAL_PART_ASSIGNMENTS rpa
                     join ES_WAREHOUSE.INVENTORY.PARTS p1
                          on rpa.part_id = p1.part_id
                     join ES_WAREHOUSE.INVENTORY.PART_TYPES pt
                          on pt.PART_TYPE_ID = p1.PART_TYPE_ID;;
  }

  dimension: rental_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
    value_format_name: id
  }

  dimension: part_id {
    type: number
    sql: ${TABLE}."PART_ID" ;;
    value_format_name: id
  }

  dimension: part_type_id {
    type: number
    sql: ${TABLE}."PART_TYPE_ID" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: part_number {
    type: string
    sql: ${TABLE}."PART_NUMBER" ;;
  }

  dimension: quantity {
    type: number
    sql: ${TABLE}."QUANTITY" ;;
    value_format_name: decimal_0
  }

  measure: total_quantity {
    type: sum
    sql: ${quantity} ;;
    value_format_name: id
    drill_fields: [part_id, description, quantity]
  }
}
