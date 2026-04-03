view: parts_write_offs {
  derived_table: {
    sql: SELECT
wo.work_order_id
  , t.store_id
, l.branch_id as market_id
, t.PART_ID                                       AS part_id
, t.transaction_type
, t.TRANSACTION_ID
, -quantity qty
, -quantity*zeroifnull(weighted_average_cost) ext_wac
, t.date_completed transaction_completed
,wo.date_completed
, iff(wo.asset_id is null, ext_wac, 0) write_off
, iff(wo.asset_id is not null, ext_wac, 0) service
, wo.description
, case when wo.asset_id is not null then 'Service'
when wo.work_order_id in (select distinct work_order_id
from "ES_WAREHOUSE"."WORK_ORDERS"."WORK_ORDERS_BY_TAG"
where name like '%return%') or wo.description ilike '%return%' or wo.description ilike '%claim%' or wo.description ilike '%delivery%' or wo.description ilike '%OEM%'
then 'Parts_Return'
when wo.work_order_id in (select distinct work_order_id
from "ES_WAREHOUSE"."WORK_ORDERS"."WORK_ORDERS_BY_TAG"
where name like '%damage%') or wo.description ilike '%damage%'
then 'Damage_Parts'
when wo.work_order_id in (select distinct work_order_id
from "ES_WAREHOUSE"."WORK_ORDERS"."WORK_ORDERS_BY_TAG"
where name ='Inventory') or wo.description ilike '%count%' or wo.description ilike '%adjustment%' or wo.description ilike '%inventory%'
then 'Inventory'
else 'Other' end internal_type
from ANALYTICS.INTACCT_MODELS.PART_INVENTORY_TRANSACTIONS t
   join ES_WAREHOUSE.INVENTORY.INVENTORY_LOCATIONS l
  on t.store_id=l.inventory_location_id
join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
on t.work_order_id=wo.work_order_id
WHERE t.TRANSACTION_TYPE_ID IN (7, 9) --store to work order and work order to store
and t.quantity is not null
and wo.archived_date is null --removing deleted WOs
and t.date_cancelled is null --removing deleted transactions
and l.company_id=1854 --filtering to equipmentshare locations
and l.date_archived is null --removind deleted store locations
and wo.billing_type_id=3 --internal billed
--and wo.date_completed is not null -- taking filter out so it can be filtered at the visual level depending on the ask
;;
  }

  dimension: work_order_id {
    type: string
    sql: ${TABLE}.work_order_id ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}.market_id ;;
  }

  dimension: part_id {
    type: string
    sql: ${TABLE}.part_id ;;
  }
  dimension: transaction_type {
    type: string
    sql: ${TABLE}.transaction_type ;;
  }
  dimension: transaction_id {
    type: string
    sql: ${TABLE}.transaction_id ;;
  }
  dimension_group: transaction_completed {
    type: time
    timeframes: [date,month,quarter,year]
    sql: ${TABLE}.transaction_completed ;;
  }
  dimension_group: work_order_completed {
    type: time
    timeframes: [date,month,quarter,year]
    sql: ${TABLE}.date_completed ;;
  }
  dimension: wo_description {
    type: string
    sql: ${TABLE}.description ;;
  }

  dimension: internal_type {
    type: string
    sql: ${TABLE}.internal_type ;;
  }
  measure: quantity {
    type: sum
    sql: ${TABLE}.qty ;;
  }

  measure: parts_cost {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}.ext_wac ;;
  }

  measure: writeoff_amt {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}.write_off ;;
  }

  measure: service_amt { #billed internal service
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}.service ;;
  }
 }
