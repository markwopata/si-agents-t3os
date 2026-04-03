view: weighted_average_cost { ##specifically for use in the wac override assistant DB
  derived_table: {
    sql:with wac_prep as ( -- suppressing overridden wac snapshots based on date_applied values
    select *
    from es_warehouse.inventory.weighted_average_cost_snapshots wacs
        qualify
                row_number() over (
                    partition by wacs.inventory_location_id, wacs.product_id, date_applied
                    order by wacs.date_created desc)
                = 1
    order by product_id, INVENTORY_LOCATION_ID, date_applied desc)

select *
     , lead(DATE_APPLIED, 1) over (
         partition by PRODUCT_ID, INVENTORY_LOCATION_ID
         order by DATE_APPLIED asc) as date_end
      , lag(WEIGHTED_AVERAGE_COST, 1) over (
          partition by PRODUCT_ID, INVENTORY_LOCATION_ID
          order by DATE_APPLIED asc) as prior_avg_cost
from wac_prep

--    with snapshot_selection as (
--select wacs.*, po.purchase_order_number
--from ES_WAREHOUSE.INVENTORY.WEIGHTED_AVERAGE_COST_SNAPSHOTS wacs
--join ES_WAREHOUSE.INVENTORY.TRANSACTION_ITEMS ti
--on wacs.TRANSACTION_ID = ti.TRANSACTION_ID
--and wacs.PRODUCT_ID = ti.PART_ID
--join ES_WAREHOUSE.INVENTORY.PARTS p
--on ti.PART_ID = p.PART_ID
--join ES_WAREHOUSE.INVENTORY.TRANSACTIONS t
--on ti.TRANSACTION_ID = t.TRANSACTION_ID
--left join PROCUREMENT.PUBLIC.PURCHASE_ORDERS po
--on t.FROM_UUID_ID = po.PURCHASE_ORDER_ID
--)

--, history as (
--    select wacs.inventory_location_id as store_id
--        , wacs.PRODUCT_ID as part_id
--        , lag(wacs.WEIGHTED_AVERAGE_COST) over (partition by wacs.product_id order by wacs.date_applied) as prior_avg_cost
--        , wacs.TOTAL_QUANTITY - wacs.INCOMING_QUANTITY as prior_qty_in_inventory
--        , wacs.INCOMING_COST_PER_ITEM
--        , wacs.INCOMING_QUANTITY
--        , prior_avg_cost * prior_qty_in_inventory as prior_amt_in_inventory
--        , wacs.INCOMING_QUANTITY * wacs.INCOMING_COST_PER_ITEM as new_amt_to_add
--        , wacs.TOTAL_QUANTITY
--        , wacs.WEIGHTED_AVERAGE_COST
--        , iff(wacs.WAC_SNAPSHOT_ID = ss.WAC_SNAPSHOT_ID, 'reviewing', null) as flag
--        , wacs.TRANSACTION_ID as source_transaction
--        , wacs.IS_OVERRIDE
--        , wacs.REASON as override_reason
--        , ss.purchase_order_number
--        , wacs.date_applied
--        , wacs.wac_snapshot_id
--    from ES_WAREHOUSE.INVENTORY.WEIGHTED_AVERAGE_COST_SNAPSHOTS wacs
--    join snapshot_selection ss
--    on wacs.PRODUCT_ID = ss.PRODUCT_ID
--    and wacs.INVENTORY_LOCATION_ID = ss.INVENTORY_LOCATION_ID
--)

--select *
--from history
;;
  }
  dimension: part_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."PRODUCT_ID" ;;
  }

  dimension: store_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."INVENTORY_LOCATION_ID" ;;
  }

  dimension: is_current {
    type: string
    sql: ${TABLE}.is_current ;;
  }

  dimension: wac_snapshot_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."WAC_SNAPSHOT_ID" ;;
    primary_key: yes
  }

  dimension: source_transaction_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."TRANSACTION_ID" ;;
  }

  dimension: prior_avg_cost {
    type: number
    sql: ${TABLE}."PRIOR_AVG_COST" ;;
  }

  dimension: prior_qty { #change to a formula
    type: number
    # sql: ${TABLE}."PRIOR_QTY_IN_INVENTORY" ;;
    sql: ${TABLE}."TOTAL_QUANTITY" - ${TABLE}."INCOMING_QUANTITY" ;;
  }

  dimension: incoming_cost_per_item {
    type: number
    sql: ${TABLE}."INCOMING_COST_PER_ITEM" ;;
  }

  dimension: incoming_qty {
    type: number
    sql: ${TABLE}."INCOMING_QUANTITY" ;;
  }

  dimension: new_qty {
    type: number
    sql: ${TABLE}."TOTAL_QUANTITY" ;;
  }

  dimension: weighted_average_cost {
    type: number
    value_format_name: usd
    sql: ${TABLE}."WEIGHTED_AVERAGE_COST" ;;
  }

  # dimension: flag { #lose this
  #   type: string
  #   sql: ${TABLE}."FLAG" ;;
  # }

  # dimension: po_number { #lose this
  #   type: number
  #   value_format_name: id
  #   sql: ${TABLE}."PURCHASE_ORDER_NUMBER" ;;
  # }

  dimension_group: date_applied {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."DATE_APPLIED" ;;
  }

  dimension: date_formatted {
    type: date_time
    sql: ${TABLE}."DATE_APPLIED" ;;
    html: {{ rendered_value | date: "%F %r" }};;
  }

  }
