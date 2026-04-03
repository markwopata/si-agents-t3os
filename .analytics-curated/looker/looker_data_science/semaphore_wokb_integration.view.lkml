view: semaphore_wokb_integration {
  derived_table: {
    sql:    -- Pull assets that have triggered an AMS warning
with asset_id_cte as (
  select distinct
    pk_id_json:asset_id as asset_id,
    max(date_processed) as date_of_semaphore
  from data_science.public.data_metrics
  where data_source ilike '%ams%'
  group by pk_id_json:asset_id
  --order by metric_value
)
-- Use the asset above to get the associated meta-information
, asset_meta_information as (
  select
    asset_id,
    year,
    make,
    model
  from es_warehouse.public.assets
  where asset_id in (select asset_id from asset_id_cte)
)
-- Find the WO ID for associated time range
, work_order_id_cte as (
  select
    asset_id,
    work_order_id,
    asset_id_cte.date_of_semaphore-- as date_of_semaphore
  from es_warehouse.work_orders.work_orders
  join asset_id_cte using (asset_id)
  where work_orders.date_created between
    -- Lower bound on timestamp comes first
    dateadd(day, -60, asset_id_cte.date_of_semaphore)
    -- Upper bound on timestamp comes second
    and dateadd(day, 60, asset_id_cte.date_of_semaphore)
)
-- Pull in the associated parsed WOs from WOKB
, work_order_parsed as (
  select
    work_order_id_cte.asset_id,
    work_order_notes.work_order_id,
    work_order_id_cte.date_of_semaphore,
    ccc.*
  from es_warehouse.work_orders.work_order_notes
  join work_order_id_cte using (work_order_id)
  join data_science.wokb.ccc using (work_order_note_id)
)
select
  asset_meta_information.year,
  asset_meta_information.make,
  asset_meta_information.model,
  work_order_parsed.asset_id,
  work_order_parsed.complaint,
  work_order_parsed.cause,
  work_order_parsed.correction,
  to_date(work_order_parsed.date_of_semaphore) as date_of_semaphore,
  to_date(date_trunc('day', work_order_parsed.date_created)) as date_of_work_order
from work_order_parsed
join asset_meta_information using (asset_id)
order by asset_id, date_of_work_order
;;
  }

  dimension: asset_id {}
  dimension: date_of_work_order {}
  dimension: date_of_semaphore {}
  dimension: cause {}
  dimension: complaint {}
  dimension: correction {}
  # # You can specify the table name if it's different from the view name:
  # sql_table_name: my_schema_name.tester ;;
  #
  # # Define your dimensions and measures here, like this:
  # dimension: user_id {
  #   description: "Unique ID for each user that has ordered"
  #   type: number
  #   sql: ${TABLE}.user_id ;;
  # }
  #
  # dimension: lifetime_orders {
  #   description: "The total number of orders for each user"
  #   type: number
  #   sql: ${TABLE}.lifetime_orders ;;
  # }
  #
  # dimension_group: most_recent_purchase {
  #   description: "The date when each user last ordered"
  #   type: time
  #   timeframes: [date, week, month, year]
  #   sql: ${TABLE}.most_recent_purchase_at ;;
  # }
  #
  # measure: total_lifetime_orders {
  #   description: "Use this for counting lifetime orders across many users"
  #   type: sum
  #   sql: ${lifetime_orders} ;;
  # }
}

# view: semaphore_wokb_integration {
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
