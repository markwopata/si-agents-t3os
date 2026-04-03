view: fact_cycle_counts {

   sql_table_name: ANALYTICS.PARTS_INVENTORY.FACT_CYCLE_COUNTS;;

  dimension: cycle_count_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.CYCLE_COUNT_ID ;;
  }

  dimension: distribution_center {
    type: string
    sql: ${TABLE}.DISTRIBUTION_CENTER ;;
  }

  dimension: part_number {
    type: string
    sql: ${TABLE}.PART_NUMBER ;;
  }

  dimension: inventory_location {
    type: string
    sql: ${TABLE}.INVENTORY_LOCATION ;;
  }

  dimension: counted_by_employee_id {
    type: number
    sql: ${TABLE}.COUNTED_BY_EMPLOYEE_ID ;;
  }

  dimension_group: cycle_count_date {
    type: time
    timeframes: [date, week, month, quarter, year]
    sql: ${TABLE}.CYCLE_COUNT_DATE;;
  }

  dimension_group: load_timestamp {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.LOAD_TIMESTAMP;;
  }

  dimension: system_quantity {
    type: number
    sql: ${TABLE}.SYSTEM_QUANTITY ;;
  }

  dimension: counted_quantity {
    type: number
    sql: ${TABLE}.COUNTED_QUANTITY ;;
  }

  dimension: quantity_difference {
    type: number
    sql: ${TABLE}.QUANTITY_DIFFERENCE ;;
  }

  dimension: unit_cost {
    type: number
    value_format_name: usd
    sql: ${TABLE}.UNIT_COST ;;
  }

  dimension: write_off_value {
    type: number
    value_format_name: usd
    sql: ${TABLE}.WRITE_OFF_VALUE ;;
  }

  dimension: notes {
    type: string
    sql: ${TABLE}.NOTES ;;
  }

  measure: count {
    type: count
    drill_fields: [cycle_count_id, part_number, inventory_location]
  }

  measure: total_system_quantity {
    type: sum
    sql: ${system_quantity} ;;
  }

  measure: total_counted_quantity {
    type: sum
    sql: ${counted_quantity} ;;
  }

  measure: total_quantity_difference {
    type: sum
    sql: ${quantity_difference} ;;
  }

  measure: total_write_off_value {
    type: sum
    sql: ${write_off_value} ;;
    value_format_name: usd
  }

  measure: unit_accuracy_percent {
    type: number
    sql:
    CASE
      WHEN SUM(${system_quantity}) = 0 AND SUM(${quantity_difference}) = 0 THEN 1
      WHEN SUM(${system_quantity}) = 0 THEN 0
      ELSE
        1 - (
          ABS(SUM(${quantity_difference}))
          / SUM(${system_quantity})
        )
    END ;;
    value_format_name: percent_2
  }


  measure: total_system_inventory_value {
    type: sum
    sql: ${system_quantity} * ${unit_cost} ;;
    value_format_name: usd
  }

  measure: value_accuracy_percent {
    type: number
    sql:
    CASE
      WHEN ${total_system_inventory_value} = 0
           AND SUM(${write_off_value}) = 0 THEN 1
      WHEN ${total_system_inventory_value} = 0 THEN 0
      ELSE
        1 - (
          ABS(SUM(${write_off_value}))
          / ${total_system_inventory_value}
        )
    END ;;
    value_format_name: percent_2
  }


}
