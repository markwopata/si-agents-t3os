view: base_table {
 derived_table: {
  sql:with
      asset_purchase_history_initial AS (SELECT asset_id
          , max(purchase_history_id) as latest_purchase_id
          , min(purchase_history_id) as original_purchase_id
          , max(coalesce(oec,purchase_price)) as highest_purchase_price
          , min(coalesce(oec,purchase_price)) as lowest_purchase_price
          FROM ES_WAREHOUSE.PUBLIC.asset_purchase_history
          GROUP BY 1
          )
        ,  asset_purchase_history_facts_intermediary AS (SELECT asset_purchase_history_initial.asset_id
          , asset_purchase_history_initial.latest_purchase_id
          , asset_purchase_history_initial.original_purchase_id
          , asset_purchase_history_initial.highest_purchase_price
          , asset_purchase_history_initial.lowest_purchase_price
          , coalesce(asset_purchase_history.oec,asset_purchase_history.purchase_price) as original_purchase_price
          FROM asset_purchase_history_initial LEFT JOIN ES_WAREHOUSE.PUBLIC.asset_purchase_history ON asset_purchase_history_initial.original_purchase_id = asset_purchase_history.purchase_history_id
          )
        ,  asset_purchase_history_facts_final AS (SELECT asset_purchase_history_facts_intermediary.asset_id
          , asset_purchase_history_facts_intermediary.latest_purchase_id
          , asset_purchase_history_facts_intermediary.original_purchase_id
          , asset_purchase_history_facts_intermediary.highest_purchase_price
          , asset_purchase_history_facts_intermediary.lowest_purchase_price
          , asset_purchase_history_facts_intermediary.original_purchase_price
          , coalesce(asset_purchase_history.oec,asset_purchase_history.purchase_price) as latest_purchase_price
          ,current_date() as last_updated
          FROM asset_purchase_history_facts_intermediary LEFT JOIN ES_WAREHOUSE.PUBLIC.asset_purchase_history ON asset_purchase_history_facts_intermediary.latest_purchase_id = asset_purchase_history.purchase_history_id
          )
        ,  asset_status_key_values AS (select * from ES_WAREHOUSE.PUBLIC.ASSET_STATUS_KEY_VALUES where name = 'asset_inventory_status'
            )

    -- link these OEC tables to vendor table and create vendor level measures
    , oec_detailed as (
    SELECT
    SAGE_VENDOR_NAME,
    vendorid,
    --add 30 / 60 day flags
    CASE WHEN ai.date_created <= GETDATE() AND ai.date_created > (DATEADD(DAY, -30, GETDATE())) THEN 30
    WHEN ai.date_created <= (DATEADD(DAY, -30, GETDATE())) AND ai.date_created > (DATEADD(DAY, -60, GETDATE())) THEN 60
    ELSE 0
    END AS days_30_60,
    aphhff.latest_purchase_price AS oec,
    CASE WHEN askv.value IN ('Pending Return','Make Ready','Needs Inspection', 'Soft Down','Hard Down')
    THEN aphhff.latest_purchase_price
    ELSE null
    END AS unavailable_oec
    FROM "ES_WAREHOUSE"."PUBLIC"."ASSETS" ai
    LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."MARKETS" m ON coalesce(ai.rental_branch_id, ai.inventory_branch_id) = m.market_id
    LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."ASSETS" a ON ai.asset_id = a.asset_id
    LEFT JOIN asset_status_key_values askv ON askv.asset_id = a.asset_id
    LEFT JOIN asset_purchase_history_facts_final aphhff ON aphhff.asset_id = ai.asset_id
    --add vendor info
    LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."ASSET_PURCHASE_HISTORY" aph ON ai.asset_id = aph.asset_id
    LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."COMPANY_PURCHASE_ORDER_LINE_ITEMS" li ON aph.asset_id = li.asset_id
    LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."COMPANY_PURCHASE_ORDERS" po ON li.company_purchase_order_id = po.company_purchase_order_id
    LEFT JOIN "ANALYTICS"."INTACCT"."COMPANY_TO_SAGE_VENDOR_XWALK" x ON po.vendor_id = x.company_id
    WHERE ai.asset_type_id = 1
    AND m.company_id = 1854
    AND (
    (ai.company_id <> 11606
    and LEFT(ai.serial_number, 2) <> 'RR'
    and LEFT(ai.custom_name, 2) <> 'RR')
    or ai.serial_number is null
    )
    AND ai.rental_branch_id IS NOT NULL AND askv.value IS NOT NULL
    AND li.deleted_at IS NULL
    )

    SELECT
    SAGE_VENDOR_NAME as vendor_name,
    vendorid,
    sum(oec) as total_oec
    FROM oec_detailed
    where vendorid is not null
    GROUP BY SAGE_VENDOR_NAME, vendorid
    order by total_oec desc
    limit 100
    ;;
}

dimension: vendor_name {
  type: string
  sql: ${TABLE}.vendor_name ;;
}

dimension: vendorid {
  type: string
  sql: ${TABLE}.vendorid ;;
}

dimension: total_oec {
  type: number
  sql: ${TABLE}.total_oec ;;
}
}
