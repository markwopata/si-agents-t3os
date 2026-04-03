view: unavailable_oec_district {
    derived_table: {
      sql:
  with es_assets as (select a.ASSET_ID
    from ES_WAREHOUSE.PUBLIC.ASSETS a
    left join ANALYTICS.RATE_ACHIEVEMENT.RATE_REGIONS rr on a.MARKET_ID = rr.MARKET_ID
    left join ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES ec on a.EQUIPMENT_CLASS_ID = ec.EQUIPMENT_CLASS_ID
    WHERE a.COMPANY_ID in (
                select company_id
                from ANALYTICS.PUBLIC.ES_COMPANIES
                where owned = true)

    --CONTRACTOR OWNED/OWN PROGRAM
    OR a.COMPANY_ID IN (SELECT DISTINCT AA.COMPANY_ID
        FROM ES_WAREHOUSE.PUBLIC.V_PAYOUT_PROGRAMS VPP
        JOIN ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE AA
            ON VPP.ASSET_ID = AA.ASSET_ID
        WHERE CURRENT_TIMESTAMP >= VPP.START_DATE
            AND CURRENT_TIMESTAMP < COALESCE(VPP.END_DATE, '2099-12-31')))

        select
           rr.DISTRICT,
           a.EQUIPMENT_CLASS_ID,
           COALESCE(ROUND(sum(unavailableoec) / nullifzero(sum(totaloec)),4),0) AS unavailable_oec_percent
        from ES_WAREHOUSE.SCD.PULLING_INVENTORY_EVENTS i
        left join ES_WAREHOUSE.PUBLIC.ASSETS a on a.ASSET_ID = i.ASSET_ID
        join ANALYTICS.RATE_ACHIEVEMENT.RATE_REGIONS rr on rr.MARKET_ID = i.MARKET_ID
        WHERE datediff(days, i.GENERATEDDATE, current_date) between 1 and 2
        and a.ASSET_ID in (SELECT asset_id from es_assets)
        group by 1,2
        ;;
    }

    dimension: equipment_class_id {
      type: number
      sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
    }

    dimension: district {
      type: string
      sql: ${TABLE}."DISTRICT" ;;
    }

    dimension: unavailable_oec_percent {
      type: number
      sql: ${TABLE}.unavailable_oec_percent ;;
    }
  }
