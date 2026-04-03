view: rpo_quote_asset_details {
  derived_table: {
    sql:
with afk_nbv as(
select afk.ADMIN_ASSET_ID
     , sum(afk.NBV_ESTIMATED_BOOK_VALUE) as nbv_estimated_book_value
 from analytics.assets.ASSET4000_LAS_ASSETS as afk
 left join ANALYTICS.ASSETS.INT_ASSETS as aa
    on afk.ADMIN_ASSET_ID = aa.ASSET_ID
 where afk.SOURCE = 'Asset4000'
    and afk.ASSET_ACCOUNT != 1508 -- Telematics
    and dateadd(month,1,date_trunc(month,afk.depreciation_date)) = date_trunc(month,current_date)
group by all)

, estimated_nbv as(
SELECT ASSET_ID
     , COALESCE(OEC - LEAST(OEC *
                                CASE
                                    WHEN ASSET_TYPE IN ('vehicle', 'trailer')
                                        THEN .9 / (7 * 12) -- vehicle salvage = 10%, equip = 20%
                                    ELSE .8 / (10 * 12) END *
                                GREATEST(0,
                                         DATEDIFF(MONTH,
                                                  IFF(ASSET_TYPE = 'equipment', date_from_parts(
                                                          year(FIRST_RENTAL),
                                                          month(FIRST_RENTAL),
                                                          15),
                                                      COALESCE(date_from_parts(year(PURCHASE_DATE),
                                                                               month(PURCHASE_DATE),
                                                                               15),
                                                               date_from_parts(year(DATE_CREATED),
                                                                               month(DATE_CREATED),
                                                                               15))),
                                                  date_from_parts(year(current_date::DATE), month(current_date::DATE), 15))
                                    ),
                              /*Salvage Value*/OEC * CASE
                                                            WHEN ASSET_TYPE IN ('vehicle', 'trailer')
                                                                THEN .9
                                                            ELSE .8 END) *
                          CASE
                              WHEN FIRST_RENTAL IS NULL AND ASSET_TYPE = 'equipment' THEN 0
                              ELSE 1 END,
                 OEC)                                                     AS NBV
 from ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE)

, po_li_data as(
select asset_id
     , attachments
 from ES_WAREHOUSE.PUBLIC.COMPANY_PURCHASE_ORDER_LINE_ITEMS
 qualify rank() over (partition by ASSET_ID order by _ES_UPDATE_TIMESTAMP desc) = 1)

, benchmark_rate as(
select branch_id
     , equipment_class_id
     , ceil(sum(price_per_month)) as benchmark_rental_rate
 from es_warehouse.public.branch_rental_rates
 where rate_type_id = 2
  and active = TRUE
 group by all)

select ia.asset_id
     , ia.make
     , ia.model
     , ia.serial_number
     , ia.oec
     , coalesce(afk.nbv_estimated_book_value,en.nbv) as nbv
     , poli.attachments
     , br.benchmark_rental_rate
 from analytics.assets.int_assets ia
 left join afk_nbv afk on ia.asset_id = afk.admin_asset_id
 left join estimated_nbv en on ia.asset_id = en.asset_id
 left join po_li_data poli on ia.asset_id = poli.asset_id
 left join benchmark_rate br on ia.equipment_class_id = br.equipment_class_id and ia.market_id = br.branch_id
      ;;
  }

  dimension: asset_id {
    label: "AssetID"
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }

  dimension: oec {
    label: "OEC"
    type: number
    value_format_name: decimal_2
    sql: ${TABLE}."OEC" ;;
  }

  dimension: nbv {
    label: "NBV"
    type: number
    value_format_name: decimal_2
    sql: ${TABLE}."NBV" ;;
  }

  dimension: attachments {
    type: string
    sql: ${TABLE}."ATTACHMENTS" ;;
  }

  dimension: benchmark_rental_rate {
    type: number
    value_format_name: decimal_2
    sql: ${TABLE}."BENCHMARK_RENTAL_RATE" ;;
  }
}
