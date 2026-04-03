view: forklift_contest_daily_on_rent {
    derived_table: {
      sql:
with days as (SELECT DATEADD(DAY, SEQ4(), cast('2023-05-01' as date)) AS day
              FROM TABLE (GENERATOR(ROWCOUNT =>100))
              where day <= '2023-05-31'),
     assets as (select aa.ASSET_ID, ec.EQUIPMENT_CLASS_ID, ec.NAME as EQUIPMENT_CLASS
                from ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
                join ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES ec on aa.EQUIPMENT_CLASS_ID = ec.EQUIPMENT_CLASS_ID
                where aa.EQUIPMENT_CLASS_ID in (9103, 7873, 3528, 5013, 7233, 20, 3128, 3132, 3381)
                  and aa.SERIAL_NUMBER not ilike 'rr%' and aa.CUSTOM_NAME not ilike 'rr%'
                and aa.COMPANY_ID in (select COMPANY_ID
                    FROM ES_WAREHOUSE.public.companies
                    WHERE name regexp 'IES\\d+ .*'  -- captures all IES# company_ids
                    OR COMPANY_ID = 420          -- Demo Units
                    OR COMPANY_ID = 62875        -- ES Owned special events - still owned by us
                    OR COMPANY_ID in (1854, 1855) -- ES Owned
                    OR COMPANY_ID = 61036        -- ES Owned - Trekker Temporary Holding
               --CONTRACTOR OWNED/OWN PROGRAM
                    OR COMPANY_ID IN (SELECT DISTINCT AA.COMPANY_ID
                                      FROM ES_WAREHOUSE.PUBLIC.V_PAYOUT_PROGRAMS VPP
                                      JOIN ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE AA
                                          ON VPP.ASSET_ID = AA.ASSET_ID
                                      WHERE CURRENT_TIMESTAMP >= VPP.START_DATE
                                        AND CURRENT_TIMESTAMP < COALESCE(VPP.END_DATE, '2099-12-31')))
                ),
     asset_days as (select *
                    from days
                             cross join assets),
     on_rent as (select ad.day,
                        ad.ASSET_ID,
                        ad.EQUIPMENT_CLASS_ID,
                        ad.EQUIPMENT_CLASS,
                        scd.DATE_START::date                                                                  as date_start,
                        scd.DATE_END::date                                                                    as date_end,
                        case when scd.DATE_START::date <= day and scd.DATE_END::date >= day then 1 else 0 end as on_rent
                 from asset_days ad
                          left join ES_WAREHOUSE.SCD.SCD_ASSET_INVENTORY_STATUS scd on ad.ASSET_ID = scd.ASSET_ID
                 where (-- scd.DATE_START::date >= '2023-05-01' and
                        -- andrew wants to include assets that went on rent before May
                        scd.DATE_END::date >= '2023-05-01')
                   and scd.ASSET_INVENTORY_STATUS = 'On Rent'
                 order by ASSET_ID, day)
select day, EQUIPMENT_CLASS, EQUIPMENT_CLASS_ID, sum(on_rent) as days_on_rent
from on_rent
where day <= current_date
group by 1,2,3
order by 1
          ;;
    }

    dimension: day {
      type: date
      sql: ${TABLE}."DAY" ;;
    }

    dimension: equipment_class {
      type: string
      sql: ${TABLE}."EQUIPMENT_CLASS" ;;
    }

  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }

  dimension: days_on_rent {
    type: number
    sql: ${TABLE}."DAYS_ON_RENT" ;;
  }


  }
