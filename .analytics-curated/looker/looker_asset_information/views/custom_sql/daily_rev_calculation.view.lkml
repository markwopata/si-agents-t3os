view: daily_rev_calculation {
 derived_table: {
  sql:  with days_on_rent as (
select aa.class
     , aa.equipment_class_id
     , xw.DISTRICT
     , count(*) as days_on_rent
from ANALYTICS.PUBLIC.HISTORICAL_UTILIZATION hu
left join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
                   on hu.ASSET_ID = aa.ASSET_ID
join ANALYTICS.PUBLIC.MARKET_REGION_XWALK xw
              on aa.RENTAL_BRANCH_ID = xw.MARKET_ID
WHERE (aa.COMPANY_ID IN (
                select company_id
                from ANALYTICS.PUBLIC.ES_COMPANIES
                where owned = true)
    --CONTRACTOR OWNED/OWN PROGRAM
    OR aa.COMPANY_ID IN (SELECT DISTINCT AA.COMPANY_ID
        FROM ES_WAREHOUSE.PUBLIC.V_PAYOUT_PROGRAMS VPP
        JOIN ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE AA
            ON VPP.ASSET_ID = AA.ASSET_ID
        WHERE CURRENT_TIMESTAMP >= VPP.START_DATE
            AND CURRENT_TIMESTAMP < COALESCE(VPP.END_DATE, '2099-12-31')))


and hu.ON_RENT = true
and xw.DISTRICT is not null
and hu.DTE >= dateadd('year', -1, current_date())
group by aa.class, aa.equipment_class_id, xw.DISTRICT)
--, test as (
select aa.CLASS
     , aa.EQUIPMENT_CLASS_ID
     , xw.DISTRICT
     , xw._ID_DIST                        as district_id
     , sum(hu.DAY_RATE)                   as revenue
     , nullifzero(sum(hu.PURCHASE_PRICE)) as the_OEC
     , count(*)                           as days_in_fleet -- validate this
     , revenue / days_in_fleet            as daily_revenue         -- projection
     , revenue / the_OEC                  as financial_utilization -- is null when the_OEC is null & when revenue is null
     , dor.days_on_rent / days_in_fleet   as time_utilization
--      , revenue / --number_of_contracts as rental_rate_utilization
from ANALYTICS.PUBLIC.HISTORICAL_UTILIZATION HU
         left join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
                   on hu.ASSET_ID = aa.ASSET_ID
         join ANALYTICS.PUBLIC.MARKET_REGION_XWALK xw
                   on aa.RENTAL_BRANCH_ID = xw.MARKET_ID
         left join days_on_rent dor
                   on xw.DISTRICT = dor.DISTRICT and aa.EQUIPMENT_CLASS_ID = dor.EQUIPMENT_CLASS_ID
WHERE (aa.COMPANY_ID IN (
                select company_id
                from ANALYTICS.PUBLIC.ES_COMPANIES
                where owned = true)
    --CONTRACTOR OWNED/OWN PROGRAM
    OR aa.COMPANY_ID IN (SELECT DISTINCT AA.COMPANY_ID
        FROM ES_WAREHOUSE.PUBLIC.V_PAYOUT_PROGRAMS VPP
        JOIN ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE AA
            ON VPP.ASSET_ID = AA.ASSET_ID
        WHERE CURRENT_TIMESTAMP >= VPP.START_DATE
            AND CURRENT_TIMESTAMP < COALESCE(VPP.END_DATE, '2099-12-31')))
  and xw.DISTRICT is not null
  and hu.DTE >= dateadd('year', -1, current_date())
group by aa.CLASS
       , aa.EQUIPMENT_CLASS_ID
       , xw.DISTRICT
       , dor.days_on_rent
       , xw._ID_DIST
;;
}

  dimension: equipment_class {
    type: number
    sql: ${TABLE}.CLASS ;;
  }

  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}.EQUIPMENT_CLASS_ID ;;
  }

  dimension: district {
    type: number
    sql: ${TABLE}.DISTRICT ;;
  }

  dimension: district_id {
    type: number
    sql: ${TABLE}.DISTRICT_ID ;;
  }

  dimension: daily_revenue {
    type: number
    value_format_name: usd
    sql: ${TABLE}.DAILY_REVENUE ;;
  }

  dimension: time_utilization {
    type: number
    value_format_name: decimal_2
    sql: coalesce(${TABLE}.TIME_UTILIZATION,0) ;;

  }

  }
