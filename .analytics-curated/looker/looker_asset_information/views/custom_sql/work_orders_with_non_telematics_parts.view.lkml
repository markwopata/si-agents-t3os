view: work_orders_with_non_telematics_parts {
    derived_table: {
      sql:with wo_trans AS (
         SELECT IFF(TRANSACTION_TYPE_ID = 7, t.TO_ID, t.FROM_ID) AS wo_id
              , IFF(TRANSACTION_TYPE_ID = 7, t.FROM_ID, t.TO_ID) as store_id
              , wo.BRANCH_ID
              , ti.PART_ID                                       AS part_id
              , t.transaction_type_id                            AS transaction_type_id
              , t.TRANSACTION_ID
              , IFF(transaction_type_id = 7, ti.quantity_received, 0-ti.quantity_received)                  AS qty
          FROM ES_WAREHOUSE.INVENTORY.TRANSACTIONS t
          LEFT JOIN ES_WAREHOUSE.INVENTORY.TRANSACTION_ITEMS ti
              ON t.TRANSACTION_ID = ti.TRANSACTION_ID
          JOIN es_warehouse.WORK_ORDERS.WORK_ORDERS wo
              ON IFF(TRANSACTION_TYPE_ID = 7, t.TO_ID, t.FROM_ID) = wo.WORK_ORDER_ID
          JOIN ANALYTICS.PUBLIC.MARKET_REGION_XWALK m
            on wo.BRANCH_ID = m.MARKET_ID
          WHERE TRANSACTION_TYPE_ID IN (7, 9)
            AND qty is not null
            and t.date_cancelled is null
            and t.date_completed is not null
            AND qty > 0
          )

, no_parts_wo_ids AS --add this one in last
          (
            SELECT distinct wo.work_order_id
            FROM es_warehouse.WORK_ORDERS.WORK_ORDERS wo
            INNER JOIN analytics.public.market_region_xwalk xwalk
                on xwalk.market_id = wo.branch_id
            INNER JOIN ES_WAREHOUSE.WORK_ORDERS.WORK_ORDER_COMPANY_TAGS woct
                  on wo.work_order_id = woct.WORK_ORDER_ID
            INNER JOIN ES_WAREHOUSE.WORK_ORDERS.COMPANY_TAGS ct
                  on woct.COMPANY_TAG_ID = ct.COMPANY_TAG_ID
            left join wo_trans wt
                on wo.work_order_id = wt.wo_id
            WHERE asset_id is not NULL
              AND ct.company_tag_id <> 1738 --1738 = inventory
              AND part_id is null
          )

, non_telematics_wo_parts AS (
    select distinct(wt.wo_id) AS work_order_id
                --, wt.part_id
            from wo_trans wt
            where part_id not in (select part_id from analytics.PARTS_INVENTORY.TELEMATICS_PART_IDS)
    )

--work order ids where at least 1 part in the work order is not telematics
--or there are no parts
select *
from non_telematics_wo_parts
UNION
SELECT *
FROM no_parts_wo_ids
          ;;
    }

    dimension: work_order_id {
      type: number
      sql: ${TABLE}.work_order_id ;;
    }

  }
