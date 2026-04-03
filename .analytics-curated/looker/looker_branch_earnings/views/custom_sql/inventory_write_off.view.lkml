view: inventory_write_off {
  derived_table: {
    sql:

/*
Inventory write off model to catch when parts and inventory are written off in new branches. Existing branches move
inventory to new locations in order to hide the inventory on the exisitng branches P&L
*/

/*
CTE to get market name and start dates
*/
with new_store_info as (
select distinct part_inventory_transaction.store_id,
                part_inventory_transaction.market_id,
                part_inventory_transaction.market_name,
                market.child_market_name,
                market.child_market_id,
                market.region,
                market.region_name,
                market.district,
                market.market_type,
                market.market_type_id,
                market.market_start_month
from analytics.intacct_models.part_inventory_transactions part_inventory_transaction
left join analytics.branch_earnings.market market
on part_inventory_transaction.market_id = market.child_market_id
),

/*
CTE to get written off transactions, these transactions are manually entered as missing and
the transaction type is marked as "Store to Adjust"
*/
written_off_transactions as (
select
    store_id as to_store_id,
    store_name as to_store_name,
    market_id as to_market_id,
    market_name as to_market_name,
    transaction_type_id as to_transaction_type_id,
    transaction_type as to_transaction_type,
    quantity as to_quantity,
    cost as to_cost,
    weighted_average_cost as to_weighted_cost,
    amount as to_amount,
    part_id as to_part_id,
    part_number as to_part_number,
    description as to_descrtiption,
    from_id as to_from_id,
    to_id as to_sent_to_id,
    created_by_user_id as to_user_id,
    created_by_user_id as to_user_name,
    transaction_item_id as to_transaction_item_id,
    transaction_id as to_transaction_id,
    manual_adjustment_reason as to_manual_adjustment_reason,
    manual_adjustment_reason_id as to_manual_adjustment_reason_id,
    memo as to_memo,
    date_completed as to_date_completed
from analytics.intacct_models.part_inventory_transactions part_inventory_transaction
where transaction_type in (
                           'Store to Obsolete',
                           'Store to Loss',
                           'Store To Adjust')
or work_order_id in (
        select work_order_id
        from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS
        where asset_id is null
        and description ilike '%cycle%count%')
and market_name != 'Distribution Center'
),

/*
CTE to get all the parts that were transfered to another story
*/
store_to_store_origin as (
select
        store_id as origin_store_id,
        store_name as origin_store_name,
        market_id as origin_market_id,
        market_name as origin_market_name,
        transaction_type_id as origin_transaction_type_id,
        transaction_type as origin_transaction_type,
        quantity as origin_quantity,
        cost as origin_cost,
        weighted_average_cost as origin_weighted_cost,
        amount as origin_amount,
        part_id as origin_part_id,
        part_number as origin_part_number,
        from_id as from_id,
        to_id as sent_to_id,
        created_by_user_id as origin_user_id,
        created_by_user_id as origin_user_name,
        transaction_item_id as origin_transaction_item_id,
        transaction_id as origin_transaction_id,
        memo as origin_memo,
        date_completed as origin_date_completed
from analytics.intacct_models.part_inventory_transactions part_inventory_transaction
where transaction_type ilike '%Store to Store%'
and store_id = from_id
and market_name != 'Distribution Center'
)

/*
Joining the store_to_store_origin to the written_off_transactions. Checks if the written off
transaction part came from a certain location.
*/
--final_table as (
select
        store_to_store_origin.origin_store_id,
        store_to_store_origin.origin_store_name,
        store_to_store_origin.origin_market_id,
        store_to_store_origin.origin_market_name,
        store_to_store_origin.origin_transaction_type_id,
        store_to_store_origin.origin_transaction_type,
        store_to_store_origin.origin_quantity,
        round(store_to_store_origin.origin_cost,2) as origin_cost,
        round(store_to_store_origin.origin_weighted_cost,2) as origin_weighted_cost,
        round(store_to_store_origin.origin_amount,2) as origin_amount,
        store_to_store_origin.origin_part_id,
        store_to_store_origin.origin_part_number,
        store_to_store_origin.from_id,
        store_to_store_origin.sent_to_id,
        store_to_store_origin.origin_user_id,
        store_to_store_origin.origin_user_name,
        store_to_store_origin.origin_transaction_id,
        store_to_store_origin.origin_transaction_item_id,
        store_to_store_origin.origin_memo,
        store_to_store_origin.origin_date_completed,
        written_off_transactions.to_store_id,
        written_off_transactions.to_store_name,
        written_off_transactions.to_market_id,
        written_off_transactions.to_market_name,
        written_off_transactions.to_transaction_type_id,
        written_off_transactions.to_transaction_type,
        written_off_transactions.to_quantity,
        round(written_off_transactions.to_cost,2) as to_cost,
        round(written_off_transactions.to_weighted_cost,2) as to_weighted_cost,
        round(written_off_transactions.to_amount,2) as to_amount,
        written_off_transactions.to_part_id,
        written_off_transactions.to_part_number,
        written_off_transactions.to_descrtiption,
        written_off_transactions.to_from_id,
        written_off_transactions.to_sent_to_id,
        written_off_transactions.to_user_id,
        written_off_transactions.to_user_name,
        written_off_transactions.to_transaction_item_id,
        written_off_transactions.to_transaction_id,
        case when written_off_transactions.to_manual_adjustment_reason is null then 'No Reason Given' else written_off_transactions.to_manual_adjustment_reason end as to_manual_adjustment_reason,
        written_off_transactions.to_manual_adjustment_reason_id,
        written_off_transactions.to_memo,
        written_off_transactions.to_date_completed,
        datediff('week',origin_date_completed,to_date_completed) as weeks_sitting,
        datediff('month',market_start_month,current_date())+1 as market_age,
        new_store_info.market_start_month,
        new_store_info.region_name,
        new_store_info.district
from store_to_store_origin
left join written_off_transactions
on store_to_store_origin.sent_to_id = written_off_transactions.to_store_id
and store_to_store_origin.origin_part_id = written_off_transactions.to_part_id
left join new_store_info
on written_off_transactions.to_store_id = new_store_info.store_id
where origin_part_number not ilike 'BWS%'
and origin_date_completed <= to_date_completed
and to_market_id != origin_market_id
and datediff('month', market_start_month, origin_date_completed) <= 13

;;
}


  dimension: origin_store_id {
     description: ""
     type: number
     sql: ${TABLE}.origin_store_id ;;
  }

  dimension: origin_part_id {
    description: ""
    type: number
    sql: ${TABLE}.origin_part_id ;;
  }

  dimension: origin_store_name {
     description: ""
     type: string
     sql: ${TABLE}.origin_store_name ;;
  }

  dimension: origin_market_name {
     description: ""
     type: string
     sql: ${TABLE}.origin_market_name ;;
  }

  dimension: origin_transaction_type_id {
    description: ""
    type: string
    sql: ${TABLE}.origin_transaction_type_id ;;
  }

  dimension: origin_transaction_type {
    description: ""
    type: string
    sql: ${TABLE}.origin_transaction_type ;;
  }

  dimension: origin_quantity {
    description: ""
    type: number
    sql: ${TABLE}.origin_quantity ;;
  }

  dimension: origin_weighted_cost {
    description: ""
    type: number
    sql: ${TABLE}.origin_weighted_cost ;;
  }

  dimension: origin_transaction_id {
    description: ""
    type: number
    sql: ${TABLE}.origin_transaction_id ;;
  }

  dimension:  origin_transaction_item_id {
    description: ""
    type: number
    sql: ${TABLE}.origin_transaction_item_id ;;
  }

  dimension: origin_date_completed {
    description: ""
    type: date
    sql: ${TABLE}.origin_date_completed ;;
  }

  dimension: to_store_name {
      description: ""
      type: string
      sql: ${TABLE}.to_store_name ;;
  }

  dimension: to_transaction_type {
      description: ""
      type: string
      sql: ${TABLE}.to_transaction_type ;;
  }

  dimension: to_part_id {
      description: ""
      type: string
      sql: ${TABLE}.to_part_id ;;
  }

  dimension: to_part_number {
      description: ""
      type: string
      sql: ${TABLE}.to_part_number ;;
  }

  dimension: to_descrtiption {
    description: ""
    type: string
    sql: ${TABLE}.to_descrtiption ;;
  }

  dimension: to_manual_adjustment_reason {
      description: ""
      type: string
      sql: ${TABLE}.to_manual_adjustment_reason ;;
  }

  dimension: to_manual_adjustment_reason_id {
      description: ""
      type: string
      sql: ${TABLE}.to_manual_adjustment_reason_id ;;
  }

  dimension: to_date_completed {
    description: ""
    type: date
    sql: ${TABLE}.to_date_completed ;;
  }

  dimension: to_memo {
    description: ""
    type: string
    sql: ${TABLE}.to_memo ;;
  }

  dimension: market_start_month {
    description: ""
    type: date
    sql: ${TABLE}.market_start_month ;;
  }

  dimension: region_name {
    description: ""
    type: string
    sql: ${TABLE}.region_name ;;
  }

  dimension: district {
    description: ""
    type: string
    sql: ${TABLE}.district ;;
  }

  dimension: to_quantity {
    description: ""
    type: number
    sql: ${TABLE}.to_quantity ;;
  }

  dimension: to_cost {
    description: ""
    type: number
    sql: ${TABLE}.to_cost ;;
  }

  dimension: to_weighted_cost {
    description: ""
    type: number
    sql: ${TABLE}.to_weighted_cost ;;
  }

  dimension: to_amount {
    description: ""
    type: number
    sql: ${TABLE}.to_amount ;;
  }


  dimension: to_transaction_item_id {
    description: ""
    type: number
    sql: ${TABLE}.to_transaction_item_id ;;
  }

  dimension: to_transaction_id {
    description: ""
    type: number
    sql: ${TABLE}.to_transaction_id ;;
  }


  dimension: to_market_name {
    description: ""
    type: string
    sql:  ${TABLE}.to_market_name ;;
  }

  dimension: to_market_id {
    description: ""
    type: string
    sql:  ${TABLE}.to_market_id ;;
  }

  dimension: weeks_sitting {
    description: ""
    type: number
    sql:  ${TABLE}.weeks_sitting ;;
  }

  dimension: market_age {
    description: ""
    type: string
    sql:  ${TABLE}.market_age ;;
  }
}
  #
  # measure: total_lifetime_orders {
  #   description: "Use this for counting lifetime orders across many users"
  #   type: sum
  #   sql: ${lifetime_orders} ;;
  # }


# view: invnetory_write_off {
#   # Or, you could make this view a derived table, like this:
#   derived_table: {
#     sql: SELECT
#         user_id as user_id
#         , COUNT(*) as lifetime_orders
#         , MAX(orders.created_at) as most_recent_purchase_at
#       FROM orders
#       GROUP BY user_id
#       ;;
#   }
#
#   # Define your dimensions and measures here, like this:
#   dimension: user_id {
#     description: "Unique ID for each user that has ordered"
#     type: number
#     sql: ${TABLE}.user_id ;;
#   }
#
#   dimension: lifetime_orders {
#     description: "The total number of orders for each user"
#     type: number
#     sql: ${TABLE}.lifetime_orders ;;
#   }
#
#   dimension_group: most_recent_purchase {
#     description: "The date when each user last ordered"
#     type: time
#     timeframes: [date, week, month, year]
#     sql: ${TABLE}.most_recent_purchase_at ;;
#   }
#
#   measure: total_lifetime_orders {
#     description: "Use this for counting lifetime orders across many users"
#     type: sum
#     sql: ${lifetime_orders} ;;
#   }
# }
