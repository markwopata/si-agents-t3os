view: abl_category {
  derived_table: {
    sql:
    with all_assets as (
    select DISTINCT aa.ASSET_ID
         , aa.EQUIPMENT_CLASS_ID
         , aa.CLASS
         , aa.MAKE
         , c.EQUIPMENTGROUP
         , aa.OEC
         , pct.OLV_NBV
         , pct.ASSET_COUNT
    from ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
             left join ANALYTICS.GS.ROUSE_EG_TO_CLASS c
                       on aa.EQUIPMENT_CLASS_ID = c.EQUIPMENT_CLASS_ID
             left join ANALYTICS.GS.ROUSE_EQUIPMENT_GROUP_OLV_PCT pct
                       on c.EQUIPMENTGROUP = pct.EQUIPMENT_GROUP
                           and upper(aa.MAKE) = upper(pct.MAKE)
--     where aa.YEAR >= 2021
--       and aa.COMPANY_ID = 1854
--     and aa.MAKE not in ('Diesel Laptops')
)
, add_category as (
    select *
         , case
               when OLV_NBV is null then 'E - Exclude Credibility'
               when OLV_NBV > .94 then 'A - Excellent'
               when OLV_NBV <= .94 and OLV_NBV > .85 then 'B - Good'
               when OLV_NBV <= .85 then 'C - Bad'
        end                    as calc_olv_category
         , case
               when MAKE = 'SANY' then 'D - Exclude Vendor'
               when asset_count < 25 then 'E - Exclude Credibility'
               else 'None' end as override_category
         , case
               when override_category = 'None' then calc_olv_category
               else override_category
        end                    as abl_category
    from all_assets
)
select distinct asset_id , abl_category  From add_category
    ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}.ASSET_ID ;;
  }

  dimension: abl_category {
    label: "ABL Category"
    type: string
    sql: ${TABLE}.ABL_CATEGORY ;;
  }
}
