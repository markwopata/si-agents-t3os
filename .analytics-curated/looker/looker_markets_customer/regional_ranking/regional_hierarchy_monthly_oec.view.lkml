
view: regional_hierarchy_monthly_oec {
  derived_table: {
    sql: with asset_info as (
      select GENERATED_DAY,
             sc.ASSET_ID,
             ap.OEC,
             sc.RENTAL_BRANCH_ID,
             xw.REGION_NAME,
             xw.DISTRICT,
             xw.MARKET_NAME,
             xw.MARKET_TYPE,
             case when right(xw.market_name, 9) = 'Hard Down' then true else false end as hard_down,
             'Current' as timeframe
      from analytics.bi_ops.asset_status_and_rsp_daily_snapshot sc
      left join ANALYTICS.ASSET_DETAILS.ASSET_PHYSICAL ap on sc.ASSET_ID = ap.ASSET_ID
      left join analytics.public.market_region_xwalk xw on sc.rental_branch_id = xw.market_id
      where GENERATED_DAY = (select max(GENERATED_DAY) from analytics.bi_ops.asset_status_and_rsp_daily_snapshot)
      AND xw.division_name = 'Equipment Rental'

      UNION ALL

      select GENERATED_DAY,
             sc.ASSET_ID,
             ap.OEC,
             sc.RENTAL_BRANCH_ID,
             xw.REGION_NAME,
             xw.DISTRICT,
             xw.MARKET_NAME,
             xw.MARKET_TYPE,
             case when right(xw.market_name, 9) = 'Hard Down' then true else false end as hard_down,
             'Previous' as timeframe
      from analytics.bi_ops.asset_status_and_rsp_daily_snapshot sc
      left join ANALYTICS.ASSET_DETAILS.ASSET_PHYSICAL ap on sc.ASSET_ID = ap.ASSET_ID
      left join analytics.public.market_region_xwalk xw on sc.rental_branch_id = xw.market_id
      where GENERATED_DAY = last_day(DATEADD(month,-1,current_date))
      AND xw.division_name = 'Equipment Rental'
      )
      select date_trunc(month, GENERATED_DAY) as month,
             RENTAL_BRANCH_ID,
             ai.REGION_NAME,
             ai.DISTRICT,
             ai.MARKET_NAME,
             ai.MARKET_TYPE,
             ai.HARD_DOWN,
             sum(OEC) as total_oec,
             TIMEFRAME,
             IS_CURRENT_MONTHS_OPEN_GREATER_THAN_TWELVE
      from asset_info ai
      left join (select market_id, market_name, state, region, region_name, is_current_months_open_greater_than_twelve from analytics.public.v_market_t3_analytics
      group by market_id, market_name, state, region, region_name, is_current_months_open_greater_than_twelve) vmt
            on vmt.market_id = ai.RENTAL_BRANCH_ID
      where ai.REGION_NAME is not null -- Adding this in here because there are rental branches that aren't in xwalk like Landmarks or Onsites
      group by month,
               RENTAL_BRANCH_ID,
               ai.REGION_NAME,
               ai.DISTRICT,
               ai.MARKET_NAME,
               ai.MARKET_TYPE,
               ai.HARD_DOWN,
               TIMEFRAME,
               IS_CURRENT_MONTHS_OPEN_GREATER_THAN_TWELVE;;
  }

  measure: count {
    type: count
  }

  dimension: month {
    type: date
    sql: ${TABLE}."MONTH" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."RENTAL_BRANCH_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: months_open_over_12 {
    type: yesno
    sql: ${TABLE}."IS_CURRENT_MONTHS_OPEN_GREATER_THAN_TWELVE" ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: hard_down {
    type: yesno
    sql: ${TABLE}."HARD_DOWN" ;;
  }

  dimension: total_oec {
    type: number
    sql: ${TABLE}."TOTAL_OEC" ;;
  }

  dimension: timeframe {
    type: string
    sql: ${TABLE}."TIMEFRAME" ;;
  }

  measure: current_month_oec {
    type: sum
    sql: ${total_oec} ;;
    filters: [timeframe: "Current"]
    value_format_name: usd_0
  }

  measure: last_month_oec {
    type: sum
    sql: ${total_oec} ;;
    filters: [timeframe: "Previous"]
    value_format_name: usd_0
  }
}