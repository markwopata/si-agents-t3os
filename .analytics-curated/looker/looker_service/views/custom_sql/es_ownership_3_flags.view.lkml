view: es_ownership_3_flags {
  derived_table: {
    sql:with equipmentshare_owned as
          (SELECT aa.*
              FROM ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
              LEFT JOIN ES_WAREHOUSE.PUBLIC.ASSETS a
                  ON aa.asset_ID = a.asset_ID
              WHERE aa.COMPANY_ID IN (
                    select company_id
                    from ANALYTICS.PUBLIC.ES_COMPANIES
                    where owned = true)
    )
      select distinct aa.asset_id,
             case
                 WHEN aa.asset_id in (select distinct asset_ID
                                          from ES_WAREHOUSE.PUBLIC.PAYOUT_PROGRAM_ASSIGNMENTS
                                          where PAYOUT_PROGRAM_ID IN (
                                                  11 --Advantage Max Premium (Indirectly Billed maintenance agreement)
                                                , 8 --Flex 50 (Paid maintenance)
                                                , 38 --Crockett Partners II (Indirectly Billed maintenance agreement)
                                                , 12 -- Flex 55 (Paid maintenance)
                                                , 71 -- Own Equipment Fund (Andrew Cowherd Requested 03/20/25)
                                                , 104 -- Own Sale Pending Payment (Andrew Cowherd Requested 03/20/25)
                                          )
                                              AND CURRENT_TIMESTAMP < COALESCE(END_DATE, '2099-12-31')) then 'Contractor Internally Billed Maintenance' --4751
                 WHEN aa.asset_id in (SELECT DISTINCT AA.asset_id
                                        FROM ES_WAREHOUSE.PUBLIC.V_PAYOUT_PROGRAMS VPP
                                                 JOIN ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE AA
                                                      ON VPP.ASSET_ID = AA.ASSET_ID
                                        WHERE CURRENT_TIMESTAMP >= VPP.START_DATE
                                          AND CURRENT_TIMESTAMP < COALESCE(VPP.END_DATE, '2099-12-31')) or aa.company_id in (6954,55524) then 'Contractor Direct Billed Maintenance'
                 when eso.company_id is not null then 'ES'
                 else 'Customer'
                 end as es_owned
      from ES_WAREHOUSE.public.assets_aggregate as aa
      left join equipmentshare_owned as eso
         on eso.asset_id = aa.asset_id

      ;;
  }


  dimension: asset_id {
    type: string
    sql: ${TABLE}.asset_id ;;
  }

  dimension: es_owned {
    type:  string
    sql:  ${TABLE}.es_owned ;;
  }

  measure: count_of_es_owned {
    type: count
  }
}
