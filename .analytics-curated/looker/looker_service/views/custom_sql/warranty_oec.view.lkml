view: warranty_oec_initial {
  derived_table: {
    sql: --Unaggregated results as an initial step (branches into warranty_oec and warranty_oec_vendor derived tables)
with own as ( --OWN Program Assignments
    select aa.asset_id, vpp.start_date, coalesce(vpp.end_date, '2099-12-31') as end_date
    from ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
    join ES_WAREHOUSE.PUBLIC.V_PAYOUT_PROGRAMS vpp
        on vpp.asset_id = aa.asset_id
    WHERE (aa.ASSET_TYPE_ID = 1  /*equipment*/ or  (aa.equipment_make_id = 11333 and aa.category_id = 514))
)

, es as ( --ES Ownership
    select aa.asset_id, scd.date_start, scd.date_end --all assets owned by es at the end of the year
    from ES_WAREHOUSE.SCD.SCD_ASSET_COMPANY scd
    join ANALYTICS.PUBLIC.ES_COMPANIES esc
        on esc.company_id = scd.company_id
    join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
        on scd.asset_id = aa.asset_id
    where (aa.ASSET_TYPE_ID = 1  /*equipment*/ or  (aa.equipment_make_id = 11333 and aa.category_id = 514))
        and esc.owned = true
)

, warrantable_assets as ( --List of relevant assets, may be useful
    select distinct asset_id
    from own

    union

    select distinct asset_id
    from es
)

, asset_hour_limits as ( --All warrantable assets over on hours
    select aa.asset_id
        , case
            --Allmand Light Towers/Heaters (1000 hours/1 Year)
            when aa.model in ('350 Night-Lite', 'MAXI-LITE II', 'NIGHT-LITE', 'Night-Lite Pro II', 'NLPROii-LD', 'NLV3GR', 'GR-Series') then 1000
            --Allmand Generators
            when aa.model in ('MA185', 'Maxi-Power 150', 'MP25', 'MP65') or aa.make in ('TAKEUCHI' , 'JOHN DEERE' , 'JCB') then 2000
            --Sany Telehandlers
            when aa.model in ('STH1256', 'STH1056', 'STH844', 'STH1056A') or aa.make in ('BOBCAT' , 'ATLAS COPCO') then 3000
            --Genie and JLG ultras, sany excavators and wheel loaders
            when aa.model in ('SX-125 XC', 'S-125', 'SX-150', 'SX-180', '1200SJP', '1350SJP', '1500SJ', '1850SJ', 'SW405K', 'SY135C', 'SY155', 'SY155U', 'SY16', 'SY215', 'SY225C', 'SY235C', 'SY26', 'SY265C LC', 'SY35U', 'SY365C LC', 'SY50', 'SY500', 'SY60C', 'SY75C', 'SY95C') then 5000
            else 1000000000 end as hour_limits
        , min(scd.date_start)::DATE as over_hour_limit
    from ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
    join ES_WAREHOUSE.SCD.SCD_ASSET_HOURS scd
        on scd.asset_id = aa.asset_id
    join warrantable_assets wa
        on wa.asset_id = aa.asset_id
    where hour_limits < scd.hours
    group by aa.asset_id, hour_limits
)

, warranty_final as (
    SELECT DISTINCT eppa.asset_id
        , eppa.make
        , eppa.oec
        , ad.delivery_date::DATE as warranty_start_date
        , DATEADD(month, (MAX(TIME_VALUE) OVER (PARTITION BY eppa.ASSET_ID )), ad.delivery_date::DATE) as Warranty_End_Date_prep
        , DATEADD(month, (MIN(TIME_VALUE) OVER (PARTITION BY eppa.ASSET_ID )), ad.delivery_date::DATE) as Min_Warranty_End_Date_prep
        , iff(Warranty_End_Date_prep > coalesce(over_hour_limit, '2099-12-31'), over_hour_limit, Warranty_End_Date_prep) as warranty_end_date
        , iff(Min_Warranty_End_Date_prep > coalesce(over_hour_limit, '2099-12-31'), over_hour_limit, Min_Warranty_End_Date_prep) as min_warranty_end_date
        , MAX(TIME_VALUE) OVER (PARTITION BY eppa.ASSET_ID ) AS Max_Warranty_Duration
    FROM ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE eppa
    join warrantable_assets wa
        on wa.asset_id = eppa.asset_id
    left join asset_hour_limits ahl
        on ahl.asset_id = eppa.asset_id
    JOIN es_warehouse.public.asset_warranty_xref awx
        On eppa.asset_id = awx.asset_id
    LEFT JOIN es_warehouse.public.equipment_classes ec
        On ec.equipment_class_id = eppa.equipment_class_id
    LEFT JOIN es_warehouse.public.companies c ON c.company_id = eppa.company_id
    JOIN es_warehouse.public.warranties w ON w.warranty_id = awx.warranty_id
    JOIN (
            select ad.asset_id
                , coalesce(ad.delivery_date, min(wo.date_created)) as delivery_date
            from analytics.PARTS_INVENTORY.asset_delivery_date ad
            left join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
                on wo.asset_id = ad.asset_id
            group by ad.asset_id, ad.delivery_date ) ad
        ON eppa.asset_ID = ad.asset_ID
    JOIN (
            SELECT Warranty_ID
                , description
                , TIME_VALUE
            FROM ES_WAREHOUSE.PUBLIC.WARRANTY_ITEMS
            where description not ilike '%Structural%' and description not ilike '%EPA%'--use this for the overall warranty pull
            -- description ilike any ('%standard%','%comprehensive%','%general%','%limited%','%full%','%life%','%base%') --use this for standard warranties pull
                 and warranty_id not in
                    (4173, 1774, 1773, 1288, 1246, 1247,
                    1276, 1278, 1277, 1279, 1285,
                    1275, 2035, 1375,
                    900)
                AND DATE_DELETED is null
                AND (TIME_UNIT_ID is null or TIME_UNIT_ID = 20)) wd
        ON w.WARRANTY_ID = wd.WARRANTY_ID
    WHERE eppa.year >= 2018
        AND eppa.equipment_model_id not in (select equipment_model_id from ANALYTICS.WARRANTIES.UNWARRANTABLE_MODELS)
        and ad.delivery_date is not null  --sure to give us a warranty end date
        and eppa.service_branch_id != 1491 --"main branch"
)

, generated_dates as (
    SELECT
        dateadd(month, '-' || row_number() over (order by null), dateadd('month', +1, date_trunc('month', current_date()))
        ) as generated_date
    FROM table(generator(rowcount => 250))
)

, assets_by_date as (
    select gd.generated_date
        , wf.asset_id
        , wf.make
        , wf.oec
        , wf.oec / wf.max_warranty_duration as oec_by_duration
        , iff(gd.generated_date > wf.min_warranty_end_date, 0, wf.oec) as min_end_date_oec
        , wf.max_warranty_duration
    from generated_dates gd
    left join warranty_final wf
        on wf.warranty_start_date <= gd.generated_date
            and wf.Warranty_End_Date >= gd.generated_date
    left join es
        on es.asset_id = wf.asset_id
            and es.date_start < gd.generated_date
            and es.date_end >= gd.generated_date
    left join own
        on own.asset_id = wf.asset_id
            and own.start_date < gd.generated_date
            and own.end_date >= gd.generated_date
    where gd.generated_date >= '2019-01-01'
        and coalesce(es.asset_id, own.asset_id) is not null
    order by gd.generated_date desc
)

-- , asset_branches as (
    select distinct abd.generated_date
        , abd.asset_id
        , abd.make
        , abd.oec
        , abd.oec_by_duration
        , abd.min_end_date_oec
        , coalesce(rsp.RENTAL_BRANCH_ID, isp.inventory_branch_id) as branch_id
        , concat(generated_date,' / ', branch_id, ' / ', abd.asset_id) as unique_key
    from assets_by_date abd
    join ES_WAREHOUSE.SCD.SCD_ASSET_INVENTORY isp
        on isp.asset_id = abd.asset_id
            and abd.generated_date >= isp.date_start
            and abd.generated_date <= isp.date_end
    left join ES_WAREHOUSE.SCD.SCD_ASSET_RSP rsp
        on rsp.asset_id = abd.asset_id
            and abd.generated_date >= rsp.date_start
            and abd.generated_date <= rsp.date_end
    group by abd.generated_date
        , abd.asset_id
        , abd.make
        , abd.oec
        , abd.oec_by_duration
        , abd.min_end_date_oec
        , branch_id
--)
;;
}

  dimension: primarykey {
    primary_key: yes
    type: string
    sql: ${TABLE}.unique_key ;;
  }

  dimension: asset_id {
    type: string
    sql: ${TABLE}.asset_id ;;
  }

  dimension: branch_id {
    type: string
    sql: ${TABLE}.branch_id ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}.make ;;
  }

  dimension: warranty_oec {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.oec ;;
  }

  dimension: warranty_oec_by_duration {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.oec_by_duration ;;
  }
}

view: warranty_oec {
derived_table: {
  sql: --Asset OEC on warranty by make and month

--select * from asset_branches where generated_date = '2020-11-01' and asset_id = 108395;
--select generated_date, asset_id, branch_id, count(asset_id) as c from asset_branches group by generated_date, asset_id, branch_id order by c desc;
--select generated_date, branch_id, count(asset_id) as c, count(distinct asset_id) as cd from asset_branches group by generated_date, branch_id having c <> cd ;

--, test as (
select generated_date
    , branch_id
    , make
    , round(sum(coalesce(oec,0)),2) as total_warranty_oec
    , round(sum(coalesce(oec_by_duration,0)),2) as total_oec_by_duration
    , round(sum(zeroifnull(min_end_date_oec)),2) as total_min_end_date_oec
    , concat(generated_date,' / ', branch_id, ' / ', make) as unique_key
    , count(asset_id) as count_of_assets
from ${warranty_oec_initial.SQL_TABLE_NAME}
group by generated_date
    , branch_id
    , make
--)
;;
  }

dimension: primarykey {
  primary_key: yes
  type: string
  sql: ${TABLE}.unique_key ;;
}

dimension_group: month {
  type: time
  timeframes: [
    month
  ]
  sql: cast(${TABLE}.generated_date as TIMESTAMP_NTZ) ;;
}

dimension: branch_id {
  type: string
  sql: ${TABLE}.branch_id ;;
}

dimension: make {
  type: string
  sql: ${TABLE}.make ;;
}

dimension: warranty_oec {
  type: number
  value_format_name: usd_0
  sql: ${TABLE}.total_warranty_oec ;;
}

dimension: warranty_oec_by_duration {
  type: number
  value_format_name: usd_0
  sql: ${TABLE}.total_oec_by_duration ;;
}

dimension: count_of_assets {
  type: number
  sql: ${TABLE}.count_of_assets ;;
}

measure: asset_under_warranty {
  type: sum
  sql: ${count_of_assets} ;;
}

measure: total_warranty_oec {
  type: sum_distinct
  value_format_name: usd_0
  sql_distinct_key: ${primarykey} ;;
  sql: ${warranty_oec} ;;
  drill_fields: [
    branch_id
    , make
    , warranty_oec
    , warranty_oec_by_duration
  ]
}

  measure: total_warranty_oec_by_duration {
    type: sum_distinct
    value_format_name: usd_0
    sql_distinct_key: ${primarykey} ;;
    sql: ${warranty_oec_by_duration} ;;
    drill_fields: [
    branch_id
    , make
    , warranty_oec
    , warranty_oec_by_duration
    ]
  }
}

view: warranty_oec_v_oec {
  derived_table: {
    sql: with current_oec_prep as (
    select date_trunc(month, current_date()) as month_join
        , aa.asset_id
        , aa.make
        , aa.oec
        , coalesce(rsp.RENTAL_BRANCH_ID, isp.inventory_branch_id) as branch_id
    from ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
    left join (
        select *
        from ES_WAREHOUSE.SCD.SCD_ASSET_INVENTORY
        where date_trunc(month, current_date()) >= date_start
            and date_trunc(month, current_date()) <= date_end) isp
        on isp.asset_id = aa.asset_id
    left join (
            select *
            from ES_WAREHOUSE.SCD.SCD_ASSET_RSP
            where date_trunc(month, current_date()) >= date_start
                and date_trunc(month, current_date()) <= date_end) rsp
        on rsp.asset_id = aa.asset_id
    where (aa.company_id in (
            select company_id
            from ANALYTICS.PUBLIC.ES_COMPANIES
            where owned = true)
        --CONTRACTOR OWNED/OWN PROGRAM
        OR aa.asset_id in (
            SELECT DISTINCT AA.asset_id
            FROM ES_WAREHOUSE.PUBLIC.V_PAYOUT_PROGRAMS VPP
            JOIN ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE AA
                ON VPP.ASSET_ID = AA.ASSET_ID
            WHERE CURRENT_TIMESTAMP >= VPP.START_DATE
                AND CURRENT_TIMESTAMP < COALESCE(VPP.END_DATE, '2099-12-31'))
        )
        and aa.ASSET_TYPE_ID = 1  /*equipment*/
    )

, current_oec as (
    select month_join
        , branch_id
        , make
        , count(asset_id) as total_assets
        , round(sum(oec),2) as total_oec
        , concat(month_join,' / ', branch_id, ' / ', make) as unique_key
    from current_oec_prep
    group by month_join
        , branch_id
        , make
)

select wo.generated_date
    , wo.branch_id
    , wo.make
    , wo.total_warranty_oec
    , wo.total_min_end_date_oec
    -- , wo.total_oec_by_duration
    , wo.unique_key
    , wo.count_of_assets as assets_under_warranty
    , co.total_oec
    , co.total_assets
from ${warranty_oec.SQL_TABLE_NAME} wo
left join current_oec co
    on co.unique_key = wo.unique_key
where wo.generated_date = date_trunc(month, current_date()) ;;
  }

  dimension: primarykey {
    primary_key: yes
    type: string
    sql: ${TABLE}.unique_key ;;
  }

  dimension_group: month {
    type: time
    timeframes: [
      month
    ]
    sql: cast(${TABLE}.generated_date as TIMESTAMP_NTZ) ;;
  }

  dimension: branch_id {
    type: string
    sql: ${TABLE}.branch_id ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}.make ;;
  }

  dimension: min_date_warranty_oec {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.total_min_end_date_oec ;;
  }

  dimension: warranty_oec {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.total_warranty_oec ;;
  }

  measure: oec_under_warranty {
    type: sum
    value_format_name: usd_0
    sql: ${warranty_oec} ;;
  }

  measure: oec_min_date_warranty {
    type: sum
    value_format_name: usd_0
    sql: ${min_date_warranty_oec} ;;
  }

  dimension: warranty_assets {
    type: number
    sql: ${TABLE}.assets_under_warranty ;;
  }

  measure: under_warranty_assets {
    type: sum
    sql: ${warranty_assets} ;;
  }

  dimension: total_oec {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.total_oec ;;
  }

  measure: oec {
    type: sum
    value_format_name: usd_0
    sql: ${total_oec} ;;
  }

  dimension: assets {
    type: number
    sql: ${TABLE}.total_assets  ;;
  }

  measure: total_assets {
    type: sum
    sql: ${assets} ;;
  }

  parameter: max_rank {
    type: number
  }

  dimension: rank_limit {
    type:  number
    sql:  {% parameter max_rank %} ;;
  }

  measure: total_percent_under_warranty {
    type: number
    value_format_name: percent_0
    sql: ${under_warranty_assets} / ${total_assets};;
    drill_fields: [
      make
      , oec
      , total_assets
      , oec_under_warranty
      , under_warranty_assets
    ]
  }

}

view: warranty_oec_vendor {
  derived_table: {
    sql: with connect_vendor as (
    select generated_date
      , branch_id
      , asset_id
      , a.oec
      , oec_by_duration
      , make
      , vendorid
      , vendor_name
      from ${warranty_oec_initial.SQL_TABLE_NAME} a
    join (
            select vendorid
                , vendor_name
                , mapped_vendor_name
                , vendor_type
                , iff(mapped_vendor_name <> 'Doosan / Bobcat', mapped_vendor_name, 'DOOSAN') as join1
                , iff(join1 = 'DOOSAN', 'BOBCAT', null) as join2
            from "ANALYTICS"."PARTS_INVENTORY"."TOP_VENDOR_MAPPING" v
            where primary_vendor ilike 'yes' and mapped_vendor_name is not null) v
        on upper(join1) = a.make or upper(join2) = a.make
)

--Asset OEC under warranty by date and vendor
      select generated_date
      , branch_id
      , asset_id
      , make
      , vendorid
      , vendor_name
      , round(coalesce(oec,0),2) as total_warranty_oec
      , total_warranty_oec / 12 as monthly_oec
      , round(coalesce(oec_by_duration,0),2) as total_oec_by_duration
      , concat(generated_date,' / ', asset_id, ' / ', make) as unique_key
      from connect_vendor;;
  }

  dimension: primarykey {
    primary_key: yes
    type: string
    sql: ${TABLE}.unique_key ;;
  }

  dimension_group: generateddate {
    type: time
    timeframes: [raw,date,time,week,month,quarter,year]
    sql: cast(${TABLE}.generated_date as TIMESTAMP_NTZ) ;;
  }

  dimension:  last_30_days{
    type: yesno
    sql:  ${generateddate_date} <= current_date AND ${generateddate_date} >= (current_date - INTERVAL '30 days')
      ;;
  }

  dimension: branch_id {
    type: string
    sql: ${TABLE}.branch_id ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}.make ;;
  }

  dimension: vendorid {
    type: string
    sql: ${TABLE}.vendorid ;;
  }

  dimension: warranty_oec {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.total_warranty_oec ;;
  }


  dimension: warranty_oec_by_duration {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.total_oec_by_duration ;;
  }

  measure: total_warranty_oec {
    type: sum_distinct
    sql_distinct_key: ${primarykey} ;;
    sql: ${warranty_oec} ;;
    drill_fields: [
      primarykey
    ]
  }

  dimension: monthly_oec1 {
    type: number
    sql: ${TABLE}.monthly_oec  ;;
  }

  measure: monthly_oec {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}.monthly_oec ;;
  }

  measure: monthly_warranty_oec_30_days {
    type: sum
    value_format_name: usd_0
    filters: [last_30_days: "No"]
    sql: ${monthly_oec1} ;;
  }

  measure: total_warranty_oec_by_duration {
    type: sum_distinct
    sql_distinct_key: ${primarykey} ;;
    sql: ${warranty_oec_by_duration} ;;
    drill_fields: [
      primarykey
    ]
  }

  measure: total_warranty_oec_by_duration_30_days {
    type: sum_distinct
    filters: [last_30_days: "No"]
    sql_distinct_key: ${primarykey} ;;
    sql: ${warranty_oec_by_duration} ;;
    drill_fields: [
      primarykey
    ]
  }
}
