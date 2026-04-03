view: asset_locations_by_lender_v2 {
  parameter: first_date {
    type: date
  }
  parameter: second_date {
    type: date
  }
  derived_table: {
    sql:  select fl.NAME                                                 as lender,
       fs.CURRENT_SCHEDULE_NUMBER                              as schedule,
       lam.DATE as commencement_date,
       aa.ASSET_ID,
       coalesce(aa.vin, aa.SERIAL_NUMBER)                      as serial_number,
       aa.year,
       aa.MAKE,
       aa.MODEL,
       a.description,
--        hours.hours,
       coalesce(l1.NICKNAME,mkt_1.MARKET_NAME,'No branch assignment as of this date.')                as Date1_Rental_Branch,
       coalesce(l2.NICKNAME,mkt_2.market_name,'No branch assignment as of this date.')    as Date2_Rental_Branch,
       iff(Date1_Rental_Branch = Date2_Rental_Branch, 'No', 'Yes') as Changed,
       mkt_1.MARKET_ID                                         as Date1_Market_id,
       mkt_2.MARKET_ID                                         as Date2_Market_id
from ES_WAREHOUSE.PUBLIC.ASSET_PURCHASE_HISTORY aph
         left join
     ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
     on aph.ASSET_ID = aa.ASSET_ID
    left join
    ES_WAREHOUSE.PUBLIC.ASSETS a
    on aph.ASSET_ID = a.ASSET_ID
         left join
     ES_WAREHOUSE.PUBLIC.FINANCIAL_SCHEDULES fs
     on aph.FINANCIAL_SCHEDULE_ID = fs.FINANCIAL_SCHEDULE_ID
         left join
     (select *
      from ANALYTICS.DEBT.LOAN_ATTRIBUTES
      where not GAAP
        and not PENDING
        and RECORD_STOP_DATE like '9999%') LA
     on FS.FINANCIAL_SCHEDULE_ID = la.FINANCIAL_SCHEDULE_ID
         left join (
    select *
    from ANALYTICS.DEBT.LOAN_AMORTIZATION
-- where PMT_SCHEDULE_ID in (1441,2337)
        qualify rank() over (partition by PMT_SCHEDULE_ID order by DATE asc) = 1
) LAM
    on la.PMT_SCHEDULE_ID = lam.PMT_SCHEDULE_ID
         left join
     ES_WAREHOUSE.PUBLIC.FINANCIAL_LENDERS FL
     on fs.ORIGINATING_LENDER_ID = fl.FINANCIAL_LENDER_ID
         left join
     (select *
      from ES_WAREHOUSE.scd.SCD_ASSET_HOURS
      where CURRENT_FLAG = 1) hours
     on aph.ASSET_ID = hours.ASSET_ID
         left join
     (SELECT ham.ASSET_ID,
             ham.MARKET_ID::varchar as MARKET_ID,
             m.NAME                 as MARKET_NAME,
             c.COMPANY_ID,
             c.NAME                 as COMPANY_NAME,
             m.LOCATION_ID
      FROM ANALYTICS.PUBLIC.HISTORICAL_ASSET_MARKET as ham
               JOIN(SELECT MAX(ham2.DATE) as max_date,
                           ham2.ASSET_ID
                    FROM ANALYTICS.PUBLIC.HISTORICAL_ASSET_MARKET as ham2
                    WHERE ham2.DATE <= {% parameter first_date %}
                    GROUP BY ASSET_ID) as sub
                   on ham.DATE = max_date
                       AND ham.ASSET_ID = sub.ASSET_ID
               JOIN ES_WAREHOUSE.PUBLIC.MARKETS as m
                    on ham.MARKET_ID = m.MARKET_ID
               JOIN ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE as aa
                    on ham.ASSET_ID = aa.ASSET_ID
               JOIN ES_WAREHOUSE.PUBLIC.COMPANIES as c
                    on aa.COMPANY_ID = c.COMPANY_ID
      ORDER BY ham.ASSET_ID) mkt_1
     on aph.ASSET_ID = mkt_1.ASSET_ID
         left join
     ES_WAREHOUSE.PUBLIC.LOCATIONS L1
     on mkt_1.LOCATION_ID = l1.LOCATION_ID
---------------------------
         left join
     (SELECT ham.ASSET_ID,
             ham.MARKET_ID::varchar as MARKET_ID,
             m.NAME                 as MARKET_NAME,
             c.COMPANY_ID,
             c.NAME                 as COMPANY_NAME,
             m.LOCATION_ID
      FROM ANALYTICS.PUBLIC.HISTORICAL_ASSET_MARKET as ham
               JOIN(SELECT MAX(ham2.DATE) as max_date,
                           ham2.ASSET_ID
                    FROM ANALYTICS.PUBLIC.HISTORICAL_ASSET_MARKET as ham2
                    WHERE ham2.DATE <= {% parameter second_date %}
                    GROUP BY ASSET_ID) as sub
                   on ham.DATE = max_date
                       AND ham.ASSET_ID = sub.ASSET_ID
               JOIN ES_WAREHOUSE.PUBLIC.MARKETS as m
                    on ham.MARKET_ID = m.MARKET_ID
               JOIN ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE as aa
                    on ham.ASSET_ID = aa.ASSET_ID
               JOIN ES_WAREHOUSE.PUBLIC.COMPANIES as c
                    on aa.COMPANY_ID = c.COMPANY_ID
      ORDER BY ham.ASSET_ID) mkt_2
     on aph.ASSET_ID = mkt_2.ASSET_ID
         left join
     ES_WAREHOUSE.PUBLIC.LOCATIONS L2
     on mkt_2.LOCATION_ID = l2.LOCATION_ID
where aph.FINANCIAL_SCHEDULE_ID is not null
order by fs.CURRENT_SCHEDULE_NUMBER
      ;;
  }
  dimension: lender {
    type: string
    sql: ${TABLE}.lender ;;
  }
  dimension: schedule {
    type: string
    sql: ${TABLE}.schedule ;;
  }
  dimension: commencement_date {
    type: date
    sql: ${TABLE}.commencement_date ;;
  }
  dimension: serial_number {
    type: string
    sql: ${TABLE}.serial_number ;;
  }
  dimension: description {
    type: string
    sql: ${TABLE}.description ;;
  }
  dimension: year {
    type: string
    sql: ${TABLE}.year ;;
  }
  dimension: make {
    type: string
    sql: ${TABLE}.make ;;
  }
  dimension: model {
    type: string
    sql: ${TABLE}.model ;;
  }
  dimension: date1_rental_branch {
    type: string
    sql: ${TABLE}.date1_rental_branch ;;
  }
  dimension: date1_market_id {
    type: string
    sql: ${TABLE}.date1_market_id ;;
  }
  dimension: date2_rental_branch {
    type: string
    sql: ${TABLE}.date2_rental_branch ;;
  }
  dimension: date2_market_id {
    type: string
    sql: ${TABLE}.date2_market_id ;;
  }
  dimension: changed {
    type: string
    sql: ${TABLE}.changed ;;
  }
  dimension: asset_id {
    description: "Asset ID"
    type: number
    sql: ${TABLE}.asset_id ;;
  }

  measure: display_first_date {
    description: "First date entered"
    label: "Location as of first date entered"
    type: date
    label_from_parameter: first_date
    sql:  {% parameter first_date %}
      ;;
  }
  measure: display_second_date {
    description: "Second date entered"
    label: "Location as of second date entered"
    type: date
    label_from_parameter: second_date
    sql:  {% parameter second_date %}
      ;;
  }
}
