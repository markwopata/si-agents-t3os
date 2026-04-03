view: eom_oec_by_market {
  derived_table: {
    sql:
-- set report_date = '2024-04-30';

--RENTAL FLEET BREAKDOWN
with asset_level_cte as (
             select
                  afs.date
                  , aa.asset_id
                  --, aa.asset_type
                  --, aa.asset_type_id
                  , aa.category_id
                  , aa.category
                  , aa.equipment_class_id
                  , aa.class
                  , ec.business_segment_id
                  , rm.market_id
                  , m.name market_name
                  , hu.on_rent
                  , sum(afs.oec) as oec
                  , count(*)     as count
                  , datediff(month, rm.market_start_month, current_date()) market_age
                  , CASE WHEN hu.on_rent = true then sum(afs.oec) else 0 end as on_rent_oec

             from es_warehouse.public.assets_aggregate aa

--              join (select $report_date date) as dates

             join analytics.public.asset_financing_snapshots afs
                on aa.asset_id = afs.asset_id
--                 and afs.date = $report_date

             left join ES_WAREHOUSE.PUBLIC.equipment_classes ec
                on aa.equipment_class_id = ec.equipment_class_id

             left join ANALYTICS.GS.REVMODEL_MARKET_ROLLOUT_CONSERVATIVE rm
                 on rm.market_id = coalesce(aa.rental_branch_id, aa.inventory_branch_id)

             left join analytics.market_data.market_data md
                on md.market_id = rm.market_id

             left join es_warehouse.public.markets m
                on m.market_id = rm.market_id

             left join ANALYTICS.PUBLIC.HISTORICAL_UTILIZATION hu
                on hu.dte = afs.date and hu.ASSET_ID = aa.ASSET_ID

             where md.market_type_id = 1
             and md.active = TRUE
             and afs.category in ('Owned Rental OEC', 'Owned Rolling Stock OEC', 'Contractor Owned OEC', 'Operating Lease OEC', 'Payout Program Enrolled OEC',
                 'Payout Program Unpaid OEC')
             and (ec.business_segment_id = 1 or aa.equipment_class_id in
                                            (select distinct equipment_class_id from analytics.public.ideal_core_fleet_vw))
             and aa.category not ilike '%Attachment%'
             and aa.class not ilike '%Attachment%'
             and afs.oec > 0
             and rm.market_name not ilike '%Onsite%'
             and rm.market_name not ilike '%Laydown%'
             and rm.market_name not ilike '%Hard Down%'

             and to_date(afs.date, 'YYYY-MM-DD') = (date_trunc('month',to_date(afs.date, 'YYYY-MM-DD')) + interval '1 month' - interval '1 day')::date

             group by afs.date, aa.asset_id, aa.category,
                      --aa.asset_type,
                      aa.class, ec.business_segment_id , aa.equipment_class_id, rm.market_id, m.name, aa.category_id,
                      --aa.asset_type_id,
                      hu.on_rent, market_age
                 )

,current_assets as (
            select
                 date
                 --, asset_type_id
                 , category_id
                 , category
                 , equipment_class_id
                 , class
                 , market_id
                 , market_name
                 , sum(oec) as oec
                 , sum(count) as asset_count
                 , sum(on_rent_oec) as on_rent_oec

            from asset_level_cte

            group by date,
                     --asset_type_id,
                     category_id, category, equipment_class_id, class, market_id, market_name
)

,total_mrkt_oec as (
            select afs.date,
                   md.market_id
                 , sum(afs.oec) as total_mrkt_oec

            from es_warehouse.public.assets_aggregate aa

--             join (select $report_date date) as dates

            join analytics.public.asset_financing_snapshots afs
                on aa.asset_id = afs.asset_id
--                 and afs.date = $report_date

            left join ES_WAREHOUSE.PUBLIC.equipment_classes ec
                on aa.equipment_class_id = ec.equipment_class_id

            left join analytics.market_data.market_data md
                on md.market_id = coalesce(aa.rental_branch_id, aa.inventory_branch_id)

            left join es_warehouse.public.markets m
                on m.market_id = md.market_id

            where md.market_type_id = 1
            and md.active = TRUE
            and afs.category in ('Owned Rental OEC', 'Owned Rolling Stock OEC', 'Contractor Owned OEC', 'Operating Lease OEC')
            and (ec.business_segment_id = 1 or aa.equipment_class_id in
                                            (select distinct equipment_class_id from analytics.public.ideal_core_fleet_vw))
            and aa.category not ilike '%Attachment%'
            and aa.class not ilike '%Attachment%'
            and m.name not ilike '%Onsite%'
            and m.name not ilike '%Laydown%'
            and m.name not ilike '%Hard Down%'

            group by md.market_id, m.name, afs.date
)


,interim_cte as (
            select
            ca.date
            , ca.market_id
            , ca.market_name
            , ca.category_id
            , ca.category
            , ca.equipment_class_id
            , ca.class
            , ca.oec
            , ca.on_rent_oec
            , ca.asset_count
            , coalesce(cv.oec_percentage, 0) ideal_oec_pct
            , total_mrkt_oec
            , (ca.oec / total_mrkt_oec) current_oec_pct_mkt
            , (ideal_oec_pct * total_mrkt_oec) ideal_oec_dollars_mkt
            , o.avg_oec
            , (ca.on_rent_oec/ca.oec) time_ute_mkt
            , (ideal_oec_pct - current_oec_pct_mkt) variance_to_ideal_pct_mkt
            , sum(ca.oec) OVER (PARTITION BY ca.date, ca.market_id) as oec_total_by_date_and_market
            , ca.oec/oec_total_by_date_and_market as current_oec_percentage_by_date_mkt
            , ideal_oec_pct - current_oec_percentage_by_date_mkt as variance_pct
            , (ideal_oec_dollars_mkt - ca.oec) as variance_dollars
            , round(variance_dollars / o.avg_oec) suggested_count_change_mkt

            , case
                when ideal_oec_pct = 0 AND ca.oec=0 THEN 0
                when ideal_oec_pct =0 AND ca.oec != 0 THEN 1
                ELSE abs((current_oec_percentage_by_date_mkt - ideal_oec_pct))/ideal_oec_pct
                end as percentage_difference_mkt
            , percentage_difference_mkt*ca.oec as weighted_percentage_diff

            from current_assets ca

            left join analytics.public.ideal_core_fleet_vw cv
                on cv.equipment_class_id = ca.equipment_class_id

            left join total_mrkt_oec tm
                on tm.market_id = ca.market_id
                and tm.date = ca.date

            left join ANALYTICS.PUBLIC.AVERAGE_OEC o
                on o.equipment_class_id = ca.equipment_class_id
)

SELECT * FROM interim_cte
-- SELECT * FROM asset_level_cte
-- where EQUIPMENT_CLASS_ID = 4780 --need to figure out why these aren't in the dashboard
-- and market_id = 16833
         order by date desc, MARKET_ID
      ;;
  }



  dimension: p_key {
    type: string
    primary_key: yes
    hidden: yes
    sql: CONCAT(${TABLE}."DATE", ${TABLE}."MARKET_ID", ${TABLE}."EQUIPMENT_CLASS_ID")  ;;
  }

  dimension_group: date {
    type: time
    timeframes: [
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."DATE" ;;
  }

  dimension: equipment_class_id {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: oec {
    type: number
    value_format: "$#,##0"
    sql: ${TABLE}.oec ;;
  }

  # dimension: on_rent_oec {
  #   type: number
  #   value_format: "$#,##0"
  #   sql: ${TABLE}.on_rent_oec ;;
  # }

  dimension: oec_total_by_date_and_market {
    type: number
    value_format: "$#,##0"
    sql: ${TABLE}.oec_total_by_date_and_market ;;
  }

  dimension: percentage_difference {
    type: number
    value_format: "0.00%"
    sql: ${TABLE}.percentage_difference_mkt ;;
  }

  dimension: weighted_percentage_diff {
    type: number
    value_format: "$#,##0"
    sql: ${TABLE}.weighted_percentage_diff ;;
  }

  dimension: ideal_oec_dollars {
    type: number
    value_format: "$#,##0"
    sql: ${TABLE}.ideal_oec_dollars_mkt ;;
  }

  # dimension: time_ute {
  #   type: number
  #   value_format: "0.00%"
  #   sql: ${TABLE}.time_ute_mkt ;;
  # }

  dimension: variance_pct {
    type: number
    value_format: "0.00%"
    sql: ${TABLE}.variance_pct ;;
  }

  dimension: variance_dollars {
    type: number
    value_format: "$#,##0"
    sql: ${TABLE}.variance_dollars ;;
  }

  dimension: current_oec_percentage_by_date_mkt {
    type: number
    value_format: "0.00%"
    sql: ${TABLE}.current_oec_percentage_by_date_mkt ;;
  }

  measure: oec_sum {
    type: sum
    value_format: "$#,##0"
    sql: ${oec} ;;
  }

  # measure: on_rent_oec_sum {
  #   type: sum
  #   value_format: "$#,##0"
  #   sql: ${on_rent_oec} ;;
  # }

  measure: oec_total_by_date_and_market_sum {
    type: max
    value_format: "$#,##0"
    sql: ${oec_total_by_date_and_market} ;;
  }

  measure: weighted_percentage_diff_sum {
    type: sum
    value_format: "$#,##0"
    sql: ${TABLE}.weighted_percentage_diff ;;
  }

}
