view: transaction_items_w_avg_cost {
  derived_table: {
    sql: with avg_cost_per_part as ( --For only when the average cost snapshot is unavailable
    select tran.current_part_id as part_id
        , tran.snapshot_date
        , sum(tran.amount) / sum(tran.quantity) as avg_cost
    from ANALYTICS.PUBLIC.AVERAGE_COST_TRANSACTIONS tran
    where tran.contribute_to_avg_flag = true             --only want transaction types that are considered valid
        and tran.cost > 0                                  --no part costs nothing, suppressing data entry errors
        and tran.cost is not null                          --no part costs nothing, suppressing data entry errors
        and tran.quantity > 0                              --if there's no quantity, there shouldn't be a transaction; i cannot divide by zero
    group by tran.current_part_id
        , tran.current_part_number
        , tran.snapshot_date
    order by tran.current_part_id
)

, test as (
select ti.*
    , transaction_type_id
    , coalesce(snap.avg_cost, acpp.avg_cost) as average_cost
    , IFF(TRANSACTION_TYPE_ID = 9, ti.cost_per_item * -1, ti.cost_per_item) * QUANTITY_RECEIVED as cost_of_transaction --Also line item value effectively
    , IFF(TRANSACTION_TYPE_ID = 9, average_cost * -1, average_cost) * QUANTITY_RECEIVED as part_value_moved
    , coalesce(p2.part_id, p.part_id) as joining_part_id
    , coalesce(p2.provider_id, p.provider_id) as joining_provider_id
from ES_WAREHOUSE.INVENTORY.transaction_items ti
inner join es_warehouse.inventory.transactions t
    on ti.transaction_id = t.transaction_id
join "ES_WAREHOUSE"."INVENTORY"."PARTS" p
    on ti.part_id = p.part_id
left join ES_WAREHOUSE.INVENTORY.PARTS p2
    on p.DUPLICATE_OF_ID = p2.PART_ID
left join ANALYTICS.PUBLIC.AVERAGE_COST_SNAPSHOT snap
    on snap.current_part_id = joining_part_id
        and snap.store_id = t.from_id
        and iff(month(t.date_completed) = month(current_date) and year(t.date_completed) = year(current_date),
        dateadd('day', -1, date_trunc('month', t.date_completed)) = snap.snapshot_date,
            last_day(t.date_completed) = snap.snapshot_date)
left join avg_cost_per_part acpp
    on acpp.part_id = joining_part_id
    and iff(month(t.date_completed) = month(current_date) and year(t.date_completed) = year(current_date),
            dateadd('day', -1, date_trunc('month', t.date_completed)) = acpp.snapshot_date,
            last_day(t.date_completed) = acpp.snapshot_date)
where ti.date_created >= '2022-01-01'
  and cost_of_transaction > 0
)

select * from test ;;
  }
  measure: count {
    type: count
  }

  dimension_group: _es_update_timestamp {
    type: time
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }

  dimension_group: date_created {
    type: time
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension_group: date_updated {
    type: time
    sql: ${TABLE}."DATE_UPDATED" ;;
  }

  dimension: transaction_item_id {
    type: number
    sql: ${TABLE}."TRANSACTION_ITEM_ID" ;;
    primary_key: yes
  }

  dimension: transaction_id {
    type: number
    sql: ${TABLE}."TRANSACTION_ID" ;;
  }

  dimension: part_id {
    type: string
    sql: ${TABLE}."PART_ID" ;;
  }

  dimension: quantity_ordered {
    type: number
    sql: ${TABLE}."QUANTITY_ORDERED" ;;
  }

  dimension: quantity_received {
    type: number
    sql: ${TABLE}."QUANTITY_RECEIVED" ;;
  }

  dimension: cost_per_item {
    type: number
    sql: ${TABLE}."COST_PER_ITEM" ;;
  }

  dimension: item_status_id {
    type: number
    sql: ${TABLE}."ITEM_STATUS_ID" ;;
  }

  dimension: created_by {
    type: number
    sql: ${TABLE}."CREATED_BY" ;;
  }

  dimension: modified_by {
    type: number
    sql: ${TABLE}."MODIFIED_BY" ;;
  }

  dimension: cost_of_transaction {
    type: number
    value_format: "$0.00"
    sql: ${TABLE}."COST_OF_TRANSACTION" ;;
  }

  dimension: part_value_moved{
    type: number
    value_format: "$0.00"
    sql: ${TABLE}."PART_VALUE_MOVED" ;;
  }

  dimension: average_cost {
    type: number
    value_format: "$0.00"
    sql: ${TABLE}."AVERAGE_COST" ;;
  }

  dimension: joining_part_id {
    type: number
    sql: ${TABLE}."JOINING_PART_ID" ;;
  }

  dimension: joining_provider_id {
    type: number
    sql: ${TABLE}."JOINING_PROVIDER_ID" ;;
  }

  measure: total_cost_of_parts {
    type: sum
    value_format_name: usd
    sql: ${part_value_moved} ;;
  }

  measure: total_value_of_transaction {
    type: sum
    value_format_name: usd
    sql: ${cost_of_transaction} ;;
  }

  measure: total_quantity_ordered {
    type:  sum
    sql: ${quantity_ordered} ;;
  }

  # measure: gross_profit {
  #   value_format_name: usd
  #   sql: ${total_value_of_transaction} - ${total_cost_of_parts} ;;
  # }

  # measure: gross_profit_margin {
  #   type: sum
  #   value_format_name: percent_1
  #   sql: ${gross_profit} / ${total_value_of_transaction} ;;
  # }
}
