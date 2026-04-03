view: current_oec_per_branch {
  derived_table: {
    sql: select market_id
    , m.market_name
    , count(aa.asset_id) as assets
    , sum(aa.oec) as total_oec
from ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
left join ES_WAREHOUSE.SCD.SCD_ASSET_MSP msp
    on msp.asset_id = aa.asset_id
        and msp.current_flag = TRUE
left join ES_WAREHOUSE.SCD.SCD_ASSET_RSP rsp
    on rsp.asset_id = aa.asset_id
        and rsp.current_flag = TRUE
join ANALYTICS.PUBLIC.MARKET_REGION_XWALK m
    on m.market_id = coalesce(rsp.rental_branch_id, msp.service_branch_id)
group by market_id
    , m.market_name ;;
  }
 dimension: market_id {
  type: number
  value_format_name: id
  sql: ${TABLE}.market_id ;;
 }

dimension: market_name {
  type: string
  sql: ${TABLE}.market_name;;
}

dimension: oec {
  type: number
  value_format_name: usd_0
  sql: ${TABLE}.total_oec ;;
}
}
