view: part_spend_vs_consumption {
  derived_table: {
  sql: with relevent_transactions as (
    select t.transaction_id
        , ti.transaction_item_id
        , t.from_id as store_id
        , t.to_id as receiver_store
        , t.transaction_type_id
        , p.part_number
        , IFF(transaction_type_id = 9, 0 - ti.quantity_received, ti.quantity_received) AS qty
        , qty * ti.cost_per_item as value
    from ES_WAREHOUSE.INVENTORY.TRANSACTIONS t
    join ES_WAREHOUSE.INVENTORY.TRANSACTION_ITEMS ti
        on ti.transaction_id = t.transaction_id
    join ES_WAREHOUSE.INVENTORY.PARTS p
        on p.part_id = ti.part_id
    where t.date_completed  >= DATEADD(day, -365, current_date)
        and t.date_cancelled is null
        and t.transaction_type_id in (7 ,9, 3, 13, 21, 23)
)

, store_part_combos as (
    select distinct store_id
        , part_number
    from relevent_transactions
    where store_id is not null
        and part_number is not null
)

, incoming_parts as (
    select receiver_store
        , part_number
        , sum(value) as purchase_value
        , sum(qty) as qty_to_store
    from relevent_transactions
    where transaction_type_id in (21, 23)
    group by receiver_store, part_number
)

, wos as (
    select store_id
        , part_number
        , sum(qty) as wo_qty
    from relevent_transactions
    where transaction_type_id in (7,9)
    group by store_id, part_number
)

, sales as (
    select store_id
        , part_number
        , sum(qty) as qty_sold
    from relevent_transactions
    where transaction_type_id in (13, 3)
    group by store_id, part_number
)

select rt.store_id
    , rt.part_number
    , coalesce(ip.purchase_value, 0) as part_spend
    , coalesce(ip.qty_to_store, 0) as qty_bought
    , coalesce(wos.wo_qty, 0) as qty_to_wo
    , coalesce(s.qty_sold, 0) as qty_to_sale
from store_part_combos rt
left join incoming_parts ip
    on ip.receiver_store = rt.store_id
        and ip.part_number = rt.part_number
left join wos
    on wos.part_number = rt.part_number
        and wos.store_id = rt.store_id
left join sales s
    on s.part_number = rt.part_number
        and s.store_id = rt.store_id
order by store_id, part_spend desc
 ;;
}

dimension: store_id {
  type: number
  value_format_name: id
  sql: ${TABLE}."STORE_ID" ;;
}

dimension: part_number {
  type: string
  sql: ${TABLE}."PART_NUMBER" ;;
}

dimension: primary_key {
  primary_key: yes
  type:  string
  sql: concat(${store_id},', ',${part_number}) ;;
}

dimension: part_spend {
  type: number
  value_format_name: usd
  sql: ${TABLE}."PART_SPEND" ;;
}

dimension: qty_bought {
  type: number
  sql: ${TABLE}."QTY_BOUGHT" ;;
}

dimension: qty_to_wo {
  type: number
  sql: ${TABLE}."QTY_TO_WO" ;;
}

dimension: qty_to_sale {
  type: number
  sql: ${TABLE}."QTY_TO_SALE" ;;
}

measure: total_part_spend {
  type: sum
  sql: ${part_spend} ;;
}

measure: total_qty_bought {
  type: sum
  sql: ${qty_bought} ;;
}

measure: total_qty_to_wo {
  type: sum
  sql: ${qty_to_wo} ;;
}

measure: total_qty_to_sale {
  type: sum
  sql: ${qty_to_sale};;
}
}
