view: annualized_warranty {
derived_table: {
  sql: with own as ( --OWN Program Assignments
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
        , ad.delivery_date::DATE as warranty_start_date
        , DATEADD(month, (MIN(TIME_VALUE) OVER (PARTITION BY eppa.ASSET_ID )), ad.delivery_date::DATE) as Warranty_End_Date_prep
        , iff(Warranty_End_Date_prep > coalesce(over_hour_limit, '2099-12-31'), over_hour_limit, Warranty_End_Date_prep) as warranty_end_date
        , MIN(TIME_VALUE) OVER (PARTITION BY eppa.ASSET_ID ) AS Min_Warranty_Duration
        , listagg(distinct w.description, ', ') over (partition by eppa.ASSET_ID) as warranties
        , listagg(wd.description, ', ') over (partition by eppa.ASSET_ID) as warranties_description
        , make
        , oec
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
    JOIN analytics.PARTS_INVENTORY.asset_delivery_date ad
        ON eppa.asset_ID = ad.asset_ID
    JOIN (
            SELECT Warranty_ID
                , description
                , TIME_VALUE
            FROM ES_WAREHOUSE.PUBLIC.WARRANTY_ITEMS
            where description not ilike '%Structural%' and description not ilike '%EPA%'--use this for the overall warranty pull
            -- description ilike any ('%standard%','%comprehensive%','%general%','%limited%','%full%','%life%','%base%') --use this for standard warranties pull
                AND warranty_id not in
                    (4774, 3320, 3319, 3285, 4173,
                    1774, 1773, 1288, 1246, 1247,
                    1276, 1278, 1277, 1279, 1285,
                    1275, 2035, 1375,
                    900)
                AND DATE_DELETED is null
                AND (TIME_UNIT_ID is null or TIME_UNIT_ID = 20)) wd
        ON w.WARRANTY_ID = wd.WARRANTY_ID
    WHERE eppa.year >= 2018
        AND eppa.equipment_model_id not in (select equipment_model_id from ANALYTICS.WARRANTIES.UNWARRANTABLE_MODELS)
        -- AND eppa.service_branch_id != 1492 --"main branch"
        -- AND eppa.ASSET_TYPE_ID = 1         --equipment
        and ad.delivery_date is not null --sure to give us a warranty end date
)

, generated_dates as (
    SELECT dateadd(month, '-' || row_number() over (order by null), date_trunc(year, dateadd('year', +1, date_trunc('month', current_date())))
        ) as generated_date
        , datediff(day, generated_date, dateadd(month, 1, generated_date)) as days_in_period
    FROM table(generator(rowcount => 1000))
)

, invoices as (
    select generated_date
        , aa.make
        , sum(wi.total_amt) as total_amount
    from generated_dates
    join ANALYTICS.WARRANTIES.WARRANTY_INVOICES wi
        on date_trunc(month, wi.date_created) = generated_date
    left join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
        on aa.asset_id = wi.asset_id
    group by generated_date
        , make
)

, makes_w_warranty as (
    select gd.generated_date
        , gd.days_in_period
        , wf.make
        , sum(zeroifnull(wf.oec)) as total_oec
        , zeroifnull(total_amount) as claimed
        , 365 / gd.days_in_period * total_amount as annualized_claim_total
        , iff(total_oec > 0, annualized_claim_total / total_oec,  0) as percent_of_oec
    from generated_dates gd
    join warranty_final wf
        on wf.warranty_start_date < generated_date
            and wf.warranty_end_date >= generated_date
    left join es
        on es.asset_id = wf.asset_id
            and es.date_start < generated_date
            and es.date_end >= generated_date
    left join own
        on own.asset_id = wf.asset_id
            and own.start_date < generated_date
            and own.end_date >= generated_date
    left join invoices i
        on i.generated_date = gd.generated_date
            and i.make = wf.make
    where coalesce(es.asset_id, own.asset_id) is not null
    group by gd.generated_date, wf.make, gd.days_in_period , total_amount
)

select gd.generated_date
    , gd.days_in_period
    , i.make
    , 0 as total_oec
    , total_amount as claimed
    , 365 / gd.days_in_period * total_amount as annualized_claim_total
    , iff(total_oec > 0, annualized_claim_total / total_oec,  0) as percent_of_oec
from generated_dates gd
join invoices i
    on i.generated_date = gd.generated_date
left join makes_w_warranty mww
    on mww.make = i.make
        and mww.generated_date = gd.generated_date
where mww.make is null

union

select * from makes_w_warranty


     ;;
}

dimension: report_month {
  type: date
  sql: ${TABLE}.generated_date ;;
}

  dimension_group: report_month_expanded {
    type: time
    timeframes: [
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}.generated_date AS TIMESTAMP_NTZ) ;;
  }

  dimension: days_in_period {
    type: number
    sql: ${TABLE}.days_in_period ;;
  }

  measure: combined_period_days {
    type: sum
    sql: ${days_in_period} ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}.make ;;
  }

  dimension: total_oec {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.total_oec ;;
  }

  measure: avg_monthly_oec {
    type: average
    value_format_name: usd_0
    sql: ${total_oec} ;;
  }

  measure: total_monthly_oec {
    type: sum
    value_format_name: usd_0
    sql: ${total_oec} ;;
  }

  dimension: claimed {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.claimed;;
  }

  measure: total_claims {
    type: sum
    value_format_name: usd_0
    sql: ${claimed} ;;
  }

  dimension: annualized_claim_total {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.annualized_claim_total;;
  }

  dimension: percent_of_oec {
    type: number
    value_format_name: percent_1
    sql: ${TABLE}.percent_of_oec;;
  }
}
