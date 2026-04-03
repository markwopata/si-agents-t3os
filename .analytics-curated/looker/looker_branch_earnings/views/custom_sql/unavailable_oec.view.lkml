view: unavailable_oec {
  derived_table: {
    sql:
    with asset_status_key_values_cte as (select *
                                     from ES_WAREHOUSE.PUBLIC.ASSET_STATUS_KEY_VALUES
                                     where name = 'asset_inventory_status')
        ,
     asset_purchase_history_initial as (
         select asset_id,
                max(PURCHASE_HISTORY_ID) as latest_purchase_id
         from ES_WAREHOUSE.PUBLIC.ASSET_PURCHASE_HISTORY
         group by asset_id
     ),
     asset_purchase_history_final_cte as (
         select asset_purchase_history_initial.ASSET_ID,
                asset_purchase_history_initial.latest_purchase_id,
                coalesce(ASSET_PURCHASE_HISTORY.oec, ASSET_PURCHASE_HISTORY.PURCHASE_PRICE) as latest_purchase_price

         from asset_purchase_history_initial
                  left join ES_WAREHOUSE.PUBLIC.ASSET_PURCHASE_HISTORY
                            on asset_purchase_history_initial.latest_purchase_id =
                               asset_purchase_history.PURCHASE_HISTORY_ID
     )
select mrx.MARKET_ID,
       mrx.MARKET_NAME,
       mrx.REGION_DISTRICT                                            district,
       mrx.REGION_NAME                                                region,
       sum(case
               when asset_status_key_values_cte.VALUE in
                    ('Pending Return', 'Make Ready', 'Needs Inspection', 'Soft Down', 'Hard Down')
                   then asset_purchase_history_final_cte.latest_purchase_price end)
           /
       sum(asset_purchase_history_final_cte.latest_purchase_price) AS unavailable_oec_percent

from ES_WAREHOUSE.PUBLIC.ASSETS assets_inventory
         left join ES_WAREHOUSE.PUBLIC.MARKETS m
                   on coalesce(assets_inventory.RENTAL_BRANCH_ID, assets_inventory.INVENTORY_BRANCH_ID) = m.MARKET_ID
         left join ES_WAREHOUSE.PUBLIC.ASSETS a
                   on assets_inventory.ASSET_ID = a.ASSET_ID
         left join asset_status_key_values_cte
                   on assets_inventory.ASSET_ID = asset_status_key_values_cte.ASSET_ID
         left join ES_WAREHOUSE.PUBLIC.ASSET_PURCHASE_HISTORY aph
                   on assets_inventory.ASSET_ID = aph.ASSET_ID
         left join asset_purchase_history_final_cte
                   on assets_inventory.ASSET_ID = asset_purchase_history_final_cte.ASSET_ID
         left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK mrx
                   on m.MARKET_ID = mrx.MARKET_ID
where assets_inventory.ASSET_TYPE_ID = 1
  AND (NOT (assets_inventory."DELETED") OR (assets_inventory."DELETED") IS NULL)
  AND ((m."COMPANY_ID") = 1854 AND (m."IS_PUBLIC_RSP"))
  AND ((((SUBSTR(TRIM((assets_inventory."SERIAL_NUMBER")), 1, 3) != 'RR-' and
          SUBSTR(TRIM((assets_inventory."SERIAL_NUMBER")), 1, 2) != 'RR') or
         (assets_inventory."SERIAL_NUMBER") is null)) AND
       ((aph."PURCHASE_HISTORY_ID") >= asset_purchase_history_final_cte.latest_purchase_id) AND
       ((assets_inventory."RENTAL_BRANCH_ID") IS NOT NULL AND (asset_status_key_values_cte."VALUE") IS NOT NULL))
group by mrx.MARKET_ID, mrx.MARKET_NAME, mrx.REGION_DISTRICT, mrx.REGION_NAME
order by MARKET_ID
    ;;
  }

  dimension: market_id {
    label: "Market ID"
    type: string
    primary_key: yes
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    label: "Market Name"
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: region_district {
    label: "District"
    type: string
    sql: ${TABLE}."REGION_DISTRICT" ;;
  }

  dimension: region_name {
    label: "Region"
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  measure: unavailable_oec_percent {
    label: "Unavailable OEC %"
    type: average
    sql: ${TABLE}."UNAVAILABLE_OEC_PERCENT" ;;
  }

















}
