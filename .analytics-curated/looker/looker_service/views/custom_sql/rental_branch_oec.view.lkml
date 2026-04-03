view: rental_branch_oec {
  derived_table: {
    sql:
      select market_id
          , m.market_name
          , count(aa.asset_id) as assets
          , sum(aa.oec) as total_oec
      from ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
      left join ES_WAREHOUSE.SCD.SCD_ASSET_RSP rsp
          on rsp.asset_id = aa.asset_id
              and rsp.current_flag = TRUE
      join ANALYTICS.PUBLIC.MARKET_REGION_XWALK m
          on m.market_id = rsp.rental_branch_id
      group by market_id
          , m.market_name;;
  }
  dimension: market_id {
    primary_key: yes
    type: number
    value_format_name: id
    sql: ${TABLE}.market_id ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}.market_name;;
  }

  dimension: oec {
    description: "Total at Branch"
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.total_oec ;;
  }
  dimension: number_of_assets {
    description: "Total at Branch"
    type: number
    sql: ${TABLE}.assets ;;
  }
  measure: total_number_of_assets {
    description: "Use to roll up OEC values to district, region, company"
    type: sum
    sql: ${number_of_assets} ;;
  }
  measure: total_oec {
    description: "Use to roll up OEC values to district, region, company"
    type: sum
    value_format_name: usd_0
    sql: zeroifnull(${oec}) ;;
  }
}
