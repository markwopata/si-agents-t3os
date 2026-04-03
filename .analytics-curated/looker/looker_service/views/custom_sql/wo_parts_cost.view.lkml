view: wo_parts_cost {
  derived_table: {
    sql:
--TA Updated logic on June 10, 2025
 with prep as (
    select wo.work_order_id
        , max(pit.date_completed) as last_interaction
        , pit.part_number
        , pit.description
        , sum(-pit.quantity) as quantity
        , sum(-quantity * coalesce(pit.weighted_average_cost, pit.cost_per_item)) as cost
    from es_warehouse.work_orders.work_orders wo
    join ANALYTICS.INTACCT_MODELS.PART_INVENTORY_TRANSACTIONS pit
        on pit.work_order_id = wo.work_order_id
    where pit.date_completed is not null
        and pit.date_cancelled is null
    group by 1,3,4
    having sum(-pit.quantity) > 0
)

select work_order_id
    , max(last_interaction) as last_part_added
    , listagg(distinct part_number, ' / ') as part_numbers
    , listagg(distinct description, ' / ') as descriptions
    , sum(quantity) as quantity
    , sum(cost) as total_cost
from prep
group by 1 ;;
  }

  dimension: work_order_id {
    primary_key: yes
    type: number
    value_format_name: id
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }

  dimension_group: last_part_added {
      type: time
      timeframes: [
        date,
        week,
        month,
        quarter,
        year
      ]
      sql: ${TABLE}."LAST_PART_ADDED" ;;
  }

  measure: max_part_added {
    type: date
    sql: max(${last_part_added_date}) ;;
  }

  dimension: part_numbers {
    type: string
    sql: ${TABLE}.part_numbers ;;
  }

  dimension: descriptions {
    type: string
    sql: ${TABLE}.descriptions ;;
  }

  dimension: quantity {
    type: number
    sql: ${TABLE}."QUANTITY" ;;
  }

  dimension: cost {
    type: number
    sql: ${TABLE}."TOTAL_COST" ;;
  }

  measure: total_quantity {
    type: sum
    sql: ${quantity} ;;
    drill_fields: [work_order_id, quantity, cost]
  }

  measure: total_cost {
    label: "Total Parts Cost"
    type: sum
    value_format_name: usd
    sql: ${cost} ;;
    drill_fields: [
                  work_order_id,
                  part_numbers,
                  descriptions,
                  cost,
                  descriptions,
                  quantity,
                  cost
                  ]
  }

  measure: est_parts_charge {
    type: number
    value_format_name: usd
    sql: ROUND(${total_cost} * 1.10, 2) ;;
  }
}

view: wo_parts_cost_agg {
  derived_table: {
    sql:
SELECT
  work_order_id,
  SUM(COALESCE(TOTAL_COST,0)) AS total_parts_cost
FROM ${wo_parts_cost.SQL_TABLE_NAME} as wo_parts_cost
GROUP BY work_order_id
;;
  }
  dimension: work_order_id {
    type:  string sql: ${TABLE}.work_order_id ;;
    primary_key: yes }

  measure: total_parts_cost {
    type: sum
    value_format_name: usd
    sql: ${TABLE}.total_parts_cost ;;
    }
  }
