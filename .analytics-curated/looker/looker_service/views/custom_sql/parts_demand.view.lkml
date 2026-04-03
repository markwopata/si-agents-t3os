view: parts_demand {
  derived_table: {

    sql:with all_txns as (

    select txn.transaction_id
         , txn.transaction_type_id
         , txn.from_id
         , txn.to_id
         , CASE
                WHEN txn.transaction_type_ID = 4 THEN txn.to_ID
                ELSE txn.from_ID
           END as store_ID
         , IFF(txn.transaction_type_id in (4,9), ti.QUANTITY_ORDERED * -1, ti.QUANTITY_ORDERED) as quantity_ordered
         , ti.COST_PER_ITEM
         , wo.WORK_ORDER_ID
         , wo.ASSET_ID
         , ti.PART_ID
         , ti.QUANTITY_ORDERED * ti.COST_PER_ITEM                                          as total_cost
    from ES_WAREHOUSE.INVENTORY.transactions txn
             left join es_warehouse.WORK_ORDERS.WORK_ORDERS wo
                       on txn.to_id = wo.WORK_ORDER_ID
             inner join es_warehouse.inventory.transaction_items ti
                        on txn.transaction_id = ti.transaction_id
    where txn.TRANSACTION_TYPE_ID in (3  -- Store to Retail Sale
                                    , 4  -- Retail Sale to Store
                                    , 7  -- Store to Work Order
                                    , 9) -- Work Order to store
      and txn.TRANSACTION_STATUS_ID = 5
      and txn.DATE_CANCELLED is null

)

, initial_totals as (

select TRANSACTION_TYPE_ID
     , prov.name as provider
     , m.name as Market
     , all_txns.store_id
     , parts.PART_NUMBER
     , parts.part_id
     , ptype.DESCRIPTION
     , aa.CATEGORY
     , aa.CLASS
     , aa.MAKE
     , aa.MODEL
     , sum(all_txns.quantity_ordered) as total_quantity
     , IFF(transaction_type_id in (4, 9), sum(all_txns.total_cost) * -1, sum(all_txns.total_cost)) as total_cost1
     , IFF(TRANSACTION_TYPE_ID in (3, 4), sum(all_txns.quantity_ordered), null) as total_sold_quantity
     , IFF(TRANSACTION_TYPE_ID in (3, 4), total_cost1, null) as total_sold_cost
     , IFF(TRANSACTION_TYPE_ID in (7, 9), sum(all_txns.quantity_ordered), null) as total_WO_quantity
     , IFF(TRANSACTION_TYPE_ID in (7, 9), total_cost1, null) as total_WO_cost

from all_txns
         left join es_warehouse.INVENTORY.parts parts
                   on all_txns.PART_ID = parts.PART_ID
         left join es_warehouse.inventory.PART_TYPES ptype
                   on parts.PART_TYPE_ID = ptype.PART_TYPE_ID
         left join ES_WAREHOUSE.INVENTORY.providers prov
                   on parts.PROVIDER_ID = prov.PROVIDER_ID
         left join ES_WAREHOUSE.public.ASSETS_AGGREGATE aa
                   on all_txns.ASSET_ID = aa.ASSET_ID
         left join ES_WAREHOUSE.INVENTORY.INVENTORY_LOCATIONS s
                   on all_txns.store_id = s.inventory_location_id
         left join ES_Warehouse.public.markets m
                   on s.branch_ID = m.market_ID
      where s.company_id = 1854

group by all_txns.TRANSACTION_TYPE_ID
     , all_txns.store_id
     , prov.name
     , parts.PART_NUMBER
     , parts.part_id
     , ptype.DESCRIPTION
     , aa.CATEGORY
     , aa.CLASS
     , aa.MAKE
     , aa.MODEL
     , m.NAME
)

select provider                 as Provider
     , Market
     , part_number              as Part
     , part_id                  as part_id
     , DESCRIPTION              as Description
     , category                 as "Category"
     , class                    as "Class"
     , make
     , model
     , sum(total_quantity)      as "Total Qty"
     , sum(total_cost1)         as "Total Cost"
     , sum(total_sold_quantity) as "Total Sold"
     , sum(total_sold_cost)     as "Total Sold Cost"
     , sum(total_WO_quantity)   as "Total on WOs"
     , sum(total_WO_cost)       as "Total WOs Cost"
from initial_totals
group by provider, part_number, part_id, DESCRIPTION, category, class, make, model, market;;
  }

# part_id can't be the primary key since I've added the category and class. It'd have to be part_id, category, class
  dimension: part_id {
    type: number
    sql: ${TABLE}."PART_ID" ;;
  }

  dimension: provider {
    type: string
    sql: ${TABLE}."PROVIDER" ;;
  }

  dimension: part {
    type: string
    sql: ${TABLE}."PART" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}."Category" ;;
  }

  dimension: class {
    type: string
    sql: ${TABLE}."Class" ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: market {
    type: string
    sql: ${TABLE}."MARKET" ;;
  }

  measure: total_sold {
    type: sum
    sql: ${TABLE}."Total Sold" ;;
  }

  measure: total_wo {
    type: sum
    label: "Total on WOs"
    sql: ${TABLE}."Total on WOs" ;;
  }

  measure: total_qty {
    type: sum
    sql: ${TABLE}."Total Qty" ;;
  }

  measure: total_sold_cost {
    type: sum
    value_format_name: usd
    sql: ${TABLE}."Total Sold Cost" ;;
  }

  measure: total_wos_cost {
    type: sum
    value_format_name: usd
    label: "Total WOs Cost"
    sql: ${TABLE}."Total WOs Cost" ;;
  }

  measure: total_cost {
    type: sum
    value_format_name: usd
    sql: ${TABLE}."Total Cost" ;;
  }

  filter: date_filter {
    type: date
  }


  }
