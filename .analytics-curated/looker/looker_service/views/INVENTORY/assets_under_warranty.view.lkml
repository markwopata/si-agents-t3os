view: assets_under_warranty {
  ##Non-structural
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

, admin_assignments as (
    select make_id
        , make
        , warranty_admin
    from ANALYTICS.WARRANTIES.WARRANTY_ADMIN_ASSIGNMENTS waa
    where current_flag = 1
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

      --, warranty_final as (
          SELECT DISTINCT eppa.asset_id
        , eppa.serial_number
        , eppa.Make
        , eppa.Model
        , eppa.year
        , ad.delivery_date::DATE as warranty_start_date
        , DATEADD(month, (MAX(TIME_VALUE) OVER (PARTITION BY eppa.ASSET_ID )), ad.delivery_date::DATE) as Warranty_End_Date_prep
        , iff(Warranty_End_Date_prep > coalesce(over_hour_limit, '2099-12-31'), over_hour_limit, Warranty_End_Date_prep) as warranty_end_date
        , DATEADD(month, (MIN(TIME_VALUE) OVER (PARTITION BY eppa.ASSET_ID )), ad.delivery_date::DATE) as shortest_Warranty_End_Date_prep
        , iff(shortest_Warranty_End_Date_prep > coalesce(over_hour_limit, '2099-12-31'), over_hour_limit, shortest_Warranty_End_Date_prep) as shortest_warranty_end_date
        , MAX(TIME_VALUE) OVER (PARTITION BY eppa.ASSET_ID ) AS Max_Warranty_Duration
        , MIN(TIME_VALUE) OVER (PARTITION BY eppa.ASSET_ID ) AS Min_Warranty_Duration
        , eppa.OEC
        , listagg(distinct w.description, ', ') over (partition by eppa.asset_id) as warranties
        , listagg(wd.description, ', ') over (partition by eppa.asset_id) as warranty_items
        , iff(current_date <= warranty_end_date and coalesce(es.asset_id, own.asset_id) is not null, TRUE, FALSE) as under_warranty
        , coalesce(aa.warranty_admin, 'Jennifer Bradstreet') as warranty_admin
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
    left join es
        on es.asset_id = eppa.asset_id
            and es.date_start < current_date
            and es.date_end >= current_date
    left join own
        on own.asset_id = eppa.asset_id
            and own.start_date < current_date
            and own.end_date >= current_date
    left join admin_assignments aa
        on aa.make_id = eppa.equipment_make_id
    WHERE eppa.year >= 2018
        AND eppa.equipment_model_id not in (select equipment_model_id from ANALYTICS.WARRANTIES.UNWARRANTABLE_MODELS)
        and ad.delivery_date is not null  --sure to give us a warranty end date
       ;;
  }
  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.asset_id ;;
    primary_key: yes
  }

  dimension: warranties {
    type: string
    sql: ${TABLE}.warranties ;;
  }

  dimension: warranty_items {
    type: string
    sql: ${TABLE}.warranty_items ;;
  }

  dimension: max_warranty_duration_mth {
    type: number
    sql: ${TABLE}.max_warranty_duration ;;
  }

  dimension_group: delivery_date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.warranty_start_date ;;
  }

  dimension_group: max_warranty_end_date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.warranty_end_date ;;
  }

  dimension: days_till_warranty_ends {
    type: number
    sql: datediff(day, current_date, ${max_warranty_end_date_date}) ;;
  }

  dimension: currently_under_warranty {
    type: yesno
    sql: ${TABLE}.under_warranty ;;
  }

  dimension: warranty_admin {
    type: string
    sql: ${TABLE}.warranty_admin ;;
  }
}
