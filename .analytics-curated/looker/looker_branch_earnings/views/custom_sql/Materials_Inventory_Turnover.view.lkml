view: materials_inventory_turnover {
  sql_table_name: analytics.materials.int_inventory_turnover_ratio ;;

  dimension: pkey {
    primary_key: yes
    hidden: yes
    type:  string
    sql:
    ${TABLE}.bt_branch_id::varchar || '|' ||
    to_char(${TABLE}.month_start, 'YYYY-MM-DD') || '|' ||
    ${TABLE}.product_id::varchar ;;
  }

  dimension: bt_branch_id {
    description: "Unique ID for each branch from BisTrack"
    type: number
    sql: ${TABLE}.bt_branch_id ;;
  }

  dimension_group: month_start {
    description: "Month Start Date"
    type: time
    timeframes: [raw, month]
    sql: ${TABLE}.month_start;;
  }

  dimension: product_id {
    description: "Product ID"
    type: number   # or string, depending on data type
    sql: ${TABLE}.product_id ;;
  }

  dimension: level_1_name {
    description: "Level 1 hierarchy name"
    type: string
    sql: ${TABLE}.level_1_name ;;
  }

  dimension: level_2_name {
    description: "Level 2 hierarchy name"
    type: string
    sql: ${TABLE}.level_2_name ;;
  }

  measure: start_value {
    description: "Starting value of inventory for the month"
    type: sum
    sql: ${TABLE}.start_value ;;
    value_format_name: usd_0
  }

  measure: end_value {
    description: "Ending value of inventory for the month"
    type: sum
    sql: ${TABLE}.end_value ;;
    value_format_name: usd_0
  }

  measure: total_cost {
    description: "Total COGs for products in the month"
    type: sum
    sql: ${TABLE}.total_cost ;;
    value_format_name: usd_0
  }

  measure: avg_inventory {
    type: number
    sql: (COALESCE(${start_value}, 0) + COALESCE(${end_value}, 0)) / 2.0 ;;
  }

  measure: inventory_turnover_ratio {
    type: number
    sql: ${total_cost} / NULLIF(${avg_inventory}, 0) ;;
    value_format: "0.00"
  }

}
