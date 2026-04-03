include: "/_base/analytics/intacct_models/part_inventory_transactions.view.lkml"

view: work_order_parts {
  derived_table: {
    sql:
    select
        concat(pit.WORK_ORDER_ID,'-',pit.PART_ID) as wo_part,
        pit.WORK_ORDER_ID,
        part_id,
        part_number,
        description as part_description,
        max(pit.date_completed) as date_completed,
        max(pit.cost_per_item) as transaction_cost,
        sum(-pit.amount) as part_cost,
        sum(-pit.quantity) as final_quantity
    from ${part_inventory_transactions.SQL_TABLE_NAME} pit
    where transaction_status = 'Completed'
        and WORK_ORDER_ID is not null
    group by pit.WORK_ORDER_ID, pit.part_id, pit.part_number, pit.description
    having final_quantity > 0 ;;
  }
  dimension: wo_part {
    type: string
    sql: ${TABLE}."WO_PART" ;;
    primary_key: yes
  }
  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
    value_format_name: id
  }
  dimension: part_id {
    type: number
    sql: ${TABLE}."PART_ID" ;;
    value_format_name: id
  }
  dimension: part_number {
    type: string
    sql: ${TABLE}."PART_NUMBER" ;;
  }
  dimension: part_description {
    type: string
    sql: ${TABLE}."PART_DESCRIPTION" ;;
  }
  dimension_group: date_completed {
    type: time
    timeframes: [raw,date,week,month,quarter,year]
    sql: ${TABLE}."DATE_COMPLETED" ;;
  }
  dimension: transaction_cost {
    type: number
    sql: ${TABLE}."TRANSACTION_COST" ;;
    value_format_name: usd
  }
  dimension: part_cost {
    type: number
    sql: zeroifnull(${TABLE}."PART_COST") ;;
    value_format_name: usd
  }
  dimension: final_quantity {
    type: number
    sql: ${TABLE}."FINAL_QUANTITY" ;;
  }
  dimension: work_order_part_cost {
    type: number
    sql: coalesce(nullifzero(${price_list_entries.amount}),nullifzero(${dim_parts_fleet_opt.part_msrp}),1.2*${transaction_cost}) * ${final_quantity} ;;
  }
  measure: part_list {
    type: list
    list_field: part_description
  }
  measure: total_part_cost {
    type: sum
    sql: ${part_cost} ;;
    value_format_name: usd
  }
  measure: total_work_order_part_cost {
    type: sum
    sql: ${work_order_part_cost} ;;
    value_format_name: usd
  }
  measure: last_part_added {
    type: date
    sql: MAX(${date_completed_raw}) ;;
  }
  measure: last_interaction {
    type: date
    sql: iff(${last_part_added}>${time_entries.last_labor_completed},${last_part_added},${time_entries.last_labor_completed}) ;;
  }
}
