view: equipmentshare_assets {
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
      a.ASSET_ID,
      a.EQUIPMENT_CLASS_ID,
      rr.DISTRICT
    from ES_WAREHOUSE.PUBLIC.ASSETS a
    left join ANALYTICS.RATE_ACHIEVEMENT.RATE_REGIONS rr on a.market_id = rr.MARKET_ID
    left join ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES ec on a.EQUIPMENT_CLASS_ID = ec.EQUIPMENT_CLASS_ID
    WHERE a.ASSET_ID in (SELECT asset_id from es_assets)
    ;;
    }

    dimension: asset_id {
      type: number
      value_format: "0"
      sql: ${TABLE}.asset_id ;;
    }

  dimension: equipment_class_id {
    type: number
    value_format: "0"
    sql: ${TABLE}.equipment_class_id ;;
  }

    dimension: district {
      type: string
      sql: ${TABLE}.district ;;
    }

  #   dimension: oec {
  #     type: number
  #     value_format: "$#,##0"
  #     sql: ${TABLE}.oec ;;
  #   }

  # measure: total_oec {
  #   type: number
  #   value_format: "$#,##0"
  #   sql: ${TABLE}.oec ;;
  # }

  measure: distinct_asset_count {
    type: count_distinct
    sql: ${asset_id} ;;
    value_format: "#,##0"   # optional: formats the number as an integer with no decimals
  }
  }
