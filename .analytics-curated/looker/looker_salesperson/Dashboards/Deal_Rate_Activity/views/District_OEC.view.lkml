view: district_oec {
  derived_table: {
    sql:
with assets as (select aa.ASSET_ID,
    aa.EQUIPMENT_CLASS_ID,
    aa.INVENTORY_BRANCH_ID,
    aa.RENTAL_BRANCH_ID,
    rr.DISTRICT,
    rr.REGION_NAME,
    aa.OEC
    from ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
    left join ANALYTICS.RATE_ACHIEVEMENT.RATE_REGIONS rr on aa.INVENTORY_BRANCH_ID = rr.MARKET_ID
    left join ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES ec on aa.EQUIPMENT_CLASS_ID = ec.EQUIPMENT_CLASS_ID
    where aa.COMPANY_ID in (select COMPANY_ID
    FROM ES_WAREHOUSE.public.companies
    WHERE name regexp 'IES\\d+ .*'-- captures all IES# company_ids
    OR COMPANY_ID = 420 -- Demo Units
    OR COMPANY_ID = 62875 -- ES Owned special events - still owned by us
    OR COMPANY_ID in (1854, 1855) -- ES Owned
    OR COMPANY_ID = 61036 -- ES Owned - Trekker Temporary Holding
    --CONTRACTOR OWNED/OWN PROGRAM
    OR COMPANY_ID IN (SELECT DISTINCT AA.COMPANY_ID
    FROM ES_WAREHOUSE.PUBLIC.V_PAYOUT_PROGRAMS VPP
    JOIN ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE AA ON VPP.ASSET_ID = AA.ASSET_ID
    WHERE CURRENT_TIMESTAMP >= VPP.START_DATE
    AND CURRENT_TIMESTAMP < COALESCE(VPP.END_DATE, '2099-12-31')))
    and (ec.BUSINESS_SEGMENT_ID = 1 or ec.BUSINESS_SEGMENT_ID is null)
    and rr.MARKET_ID in (select MARKET_REGION_XWALK.MARKET_ID from ANALYTICS.PUBLIC.MARKET_REGION_XWALK
    where MARKET_REGION_XWALK.MARKET_NAME like '%Core%')
    ),
time_ut as (select rr.DISTRICT,
    aa.EQUIPMENT_CLASS_ID,
    sum(case when ON_RENT then aa.OEC else 0 end) on_rent_oec,
    sum(aa.OEC)                                   in_fleet_oec,
    round(on_rent_oec / in_fleet_oec, 4) as       time_utilization
    from ANALYTICS.PUBLIC.HISTORICAL_UTILIZATION hu
    join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa on hu.ASSET_ID = aa.ASSET_ID
    left join ANALYTICS.RATE_ACHIEVEMENT.RATE_REGIONS rr on hu.MARKET_ID = rr.MARKET_ID
    where datediff(day, DTE, current_date) < 90
    and rr.region is not null
    and hu.asset_id not in (select asset_id
    from es_warehouse.public.v_payout_programs
    where dte between start_date and coalesce(end_date, '2999-12-31'))
    group by rr.DISTRICT, aa.EQUIPMENT_CLASS_ID
    having in_fleet_oec > 0),

district_oec_ as (select DISTRICT, REGION_NAME, round(sum(OEC)) as district_oec from assets group by 1, 2),

district_class_oec as (select DISTRICT, REGION_NAME, EQUIPMENT_CLASS_ID, round(sum(oec)) as district_class_oec
    from assets
    group by 1, 2, 3),

district_tu_oec as (select a.DISTRICT, REGION_NAME, round(sum(OEC)) as district_tu_oec
    from assets a
    left join time_ut tu
    on a.DISTRICT = tu.DISTRICT and a.EQUIPMENT_CLASS_ID = tu.EQUIPMENT_CLASS_ID
    where tu.time_utilization < .55
    group by 1, 2),

deal_rates as (select dr.*, rr.REGION_NAME
    from ANALYTICS.RATE_ACHIEVEMENT.DISCOUNT_RATES dr
    join (select distinct DISTRICT, REGION_NAME from ANALYTICS.RATE_ACHIEVEMENT.RATE_REGIONS) rr
    on dr.DISTRICT = rr.DISTRICT
    where dr.ACTIVE),

district_detail as (select dco.DISTRICT,
    dco.REGION_NAME,
    dco.EQUIPMENT_CLASS_ID,
    dco.district_class_oec,
    do.district_oec,
    dr.ACTIVE
    from district_class_oec dco
    left join district_oec_ do on dco.DISTRICT = do.DISTRICT
    left join deal_rates dr on dr.DISTRICT = dco.DISTRICT and
    dr.EQUIPMENT_CLASS_ID = dco.EQUIPMENT_CLASS_ID
    order by PRICE_PER_MONTH),

district_tu_detail as (select dco.DISTRICT,
    dco.REGION_NAME,
    dco.EQUIPMENT_CLASS_ID,
    dco.district_class_oec,
    dto.district_tu_oec,
    tu.time_utilization,
    tu.time_utilization * dco.district_class_oec as weighted_oec,
    dr.ACTIVE,
    dr.PRICE_PER_MONTH as deal_rate
    from district_class_oec dco
    join district_tu_oec dto on dto.DISTRICT = dco.DISTRICT
    left join deal_rates dr on dr.DISTRICT = dco.DISTRICT and
    dr.EQUIPMENT_CLASS_ID = dco.EQUIPMENT_CLASS_ID
    left join time_ut tu on dco.DISTRICT = tu.DISTRICT and
    dco.EQUIPMENT_CLASS_ID = tu.EQUIPMENT_CLASS_ID
    where tu.time_utilization < .55)
     ,



district_sum as (select DISTRICT,
    REGION_NAME,
    district_oec,
    sum(case when ACTIVE is not null then district_class_oec else null end) as district_deal_oec,
    district_deal_oec / district_oec                                        as district_percent
    from district_detail
    where DISTRICT is not null
    group by 1, 2, 3
    order by 1),

district_tu_sum as (select dtd.DISTRICT,
    dtd.REGION_NAME,
    --district_oec,
    district_tu_oec,
    sum(case when dtd.ACTIVE is not null then dtd.district_class_oec else null end) as district_deal_oec,
    district_deal_oec / district_tu_oec                                     as district_percent,
    sum(weighted_oec)                   as weighted_oec_total,
    sum(dtd.district_class_oec)         as district_class_oec_total,
    round(sum(weighted_oec) / sum(dtd.district_class_oec), 4)                   as oec_weighted_time_utilization
    from district_tu_detail dtd
    --LEFT JOIN district_detail dd on dtd.district = dd.DISTRICT and dtd.EQUIPMENT_CLASS_ID = dd.EQUIPMENT_CLASS_ID
    where dtd.DISTRICT is not null
    group by 1, 2, 3--, 4
    order by 1)
--      ,


    SELECT ds.*, dts.district_tu_oec, dts.district_deal_oec as district_tu_deal_oec, dts.district_percent as district_tu_percent, weighted_oec_total,district_class_oec_total, dts.oec_weighted_time_utilization FROM district_sum ds
    LEFT JOIN district_tu_sum dts on dts.DISTRICT = ds.DISTRICT

      ;;
  }

  # Define your dimensions and measures here, like this:
  dimension: district {
  primary_key: yes
    type: string
    sql: ${TABLE}.district ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}.region_name ;;
  }

  dimension: oec {
    type: number
    value_format: "#,##0"
    sql: ${TABLE}.district_oec ;;
  }

  dimension: deal_oec {
    type: number
    value_format: "#,##0"
    sql: ${TABLE}.district_deal_oec ;;
  }

  dimension: district_percent {
    type: number
    value_format: "0.00%"
    sql: ${TABLE}.district_percent ;;
  }

  dimension: tu_oec {
    type: number
    value_format: "#,##0"
    sql: ${TABLE}.district_tu_oec ;;
  }

  dimension: tu_deal_oec {
    type: number
    value_format: "#,##0"
    sql: ${TABLE}.district_tu_deal_oec ;;
  }


  dimension: weighted_oec_total {
    type: number
    value_format: "#,##0"
    sql: ${TABLE}.weighted_oec_total ;;
  }

  dimension: district_class_oec_total {
    type: number
    value_format: "#,##0"
    sql: ${TABLE}.district_class_oec_total ;;
  }

  # dimension: district_tu_percent {
  #   type: number
  #   value_format: "0.00%"
  #   sql: ${TABLE}.district_tu_percent ;;
  # }

  # dimension: oec_weighted_time_utilization {
  #   type: number
  #   value_format: "0.00%"
  #   sql: ${TABLE}.oec_weighted_time_utilization ;;
  # }

  measure: total_oec {
    type: sum
    value_format: "$#,##0"
    sql: ${oec} ;;
  }

  measure: total_deal_oec {
    type: sum
    value_format: "$#,##0"
    sql: ${deal_oec} ;;
  }

  # measure: total_district_percent {
  #   type: number
  #   value_format: "0.00%"
  #   sql: ${deal_oec} / ${oec} ;;
  # }

  measure: total_tu_oec {
    type: sum
    value_format: "$#,##0"
    sql: ${tu_oec} ;;
  }

  measure: total_tu_deal_oec {
    type: sum
    value_format: "$#,##0"
    sql: ${tu_deal_oec} ;;
  }

  measure: total_weighted_oec_total {
    type: sum
    value_format: "$#,##0"
    sql: ${weighted_oec_total} ;;
  }

  measure: total_district_class_oec_total {
    type: sum
    value_format: "$#,##0"
    sql: ${district_class_oec_total} ;;
  }


  # measure: total_district_tu_percent {
  #   type: sum
  #   value_format: "0.00%"
  #   sql: ${tu_deal_oec} / ${tu_oec} ;;
  # }
}
