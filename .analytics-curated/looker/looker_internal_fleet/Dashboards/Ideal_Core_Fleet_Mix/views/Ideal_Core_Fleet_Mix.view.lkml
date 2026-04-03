view: ideal_core_fleet_mix {
  sql_table_name: "ANALYTICS"."PUBLIC"."IDEAL_CORE_FLEET_VW" ;;

#   derived_table: {
#     sql:
# with branch_monthly as (
#     select
#         mrx.market_id,
#         mrx.market_name,
#         datediff(months, market_start_month, current_date)+1 months_open,
#         date_trunc(month, gl_date) as month,
#         sum(amt) net_income

#     from analytics.public.branch_earnings_dds_snap snp

#     join analytics.public.market_region_xwalk mrx
#         on snp.mkt_id = mrx.market_id
#         and mrx.market_type = 'Core Solutions'

#     left join analytics.gs.revmodel_market_rollout_conservative rmc
#         on mrx.market_id = rmc.market_id

#     where date_trunc(month, gl_date) >= dateadd(month, -13, current_date)
#         and months_open >= 12
#         and mrx.market_id not in (85717, 85323, 61105, 77478, 57245, 86328, 44836, 44834)
#     group by mrx.market_id, mrx.market_name, months_open, month
#     order by mrx.market_name, month
# )

# ,market_rank as(
#     select
#         market_id,
#         market_name,
#         sum(net_income) ttm_net_income,
#         rank() OVER (order by sum(net_income) desc) as rank
#     from branch_monthly
#     group by market_id, market_name
# )

# ,current_ideal_markets as (
#     select
#         market_id,
#         market_name,
#         ttm_net_income
#     from market_rank
#     where rank <= 20
# )

# ,asset_level_cte as (
#     select
#           md.market_id
#         , aa.asset_type
#         , ec.business_segment_id
#         , aa.category_id
#         , aa.category
#         , aa.equipment_class_id
#         , aa.class
#         , count(aa.asset_id) asset_count
#         , sum(aa.oec) oec
#     from es_warehouse.public.assets_aggregate aa

#     left join ES_WAREHOUSE.PUBLIC.equipment_classes ec
#         on aa.equipment_class_id = ec.equipment_class_id

#     left join ANALYTICS.GS.REVMODEL_MARKET_ROLLOUT_CONSERVATIVE rm
#         on rm.market_id = coalesce(aa.rental_branch_id, aa.inventory_branch_id)

#     left join ANALYTICS.MARKET_DATA.MARKET_DATA md
#         on md.market_id = coalesce(aa.rental_branch_id, aa.inventory_branch_id)

#     where md.market_id in (select distinct market_id from current_ideal_markets)
#         and (ec.business_segment_id = 1 or aa.equipment_class_id in (1740, 1981, 78, 117, 8857, 7873, 8873, 314, 3142))
#         and aa.category not ilike '%Attachment%'
#         and aa.class not ilike '%Attachment'
#         and aa.class not ilike '%Bucket%'
#         and aa.equipment_class_id not in (3424, 3425, 3432, 10400, 5633, 9759, 5699, 3504, 9760, 738, 9519, 9341, 5632, 9336, 3426, 3101, 4958, 210, 4740, 73, 3536, 3437, 10247, 6689, 3439, 11995, 7682, 3417, 11517, 8900)
#         and md.active = TRUE

#     group by aa.category, aa.asset_type, aa.class, ec.business_segment_id, aa.equipment_class_id, aa.category_id,         md.market_id
# )

# ,ideal_mrkt_fleet as (
#     select
#         mr.market_id,
#         mr.market_name,
#         al.equipment_class_id,
#         al.class,
#         sum(al.asset_count) asset_count,
#         sum(al.oec) oec
#         from market_rank mr

#     left join asset_level_cte al
#         on al.market_id = mr.market_id
#     where oec > 0

#     group by mr.market_id, mr.market_name, al.equipment_class_id,  al.class
# )

# ,interim_cte as (
# select equipment_class_id, class, count(distinct(market_id)) mrkt_count, sum(asset_count) asset_count, sum(oec) oec
# from ideal_mrkt_fleet
# group by equipment_class_id, class
# )

# ,filter as (
#     select
#         itc.equipment_class_id,
#         itc.class,
#         itc.asset_count,
#         itc.oec,
#         itc.mrkt_count
#     from interim_cte itc
#     where mrkt_count >= 8
# )

# ,total_oec as (
#     select sum(oec) total_oec
#     from filter
# ),

# final as (select
#     f.equipment_class_id,
#     f.class,
#     f.asset_count,
#     f.oec,
#     f.mrkt_count,
#     (f.oec / t.total_oec) * 100 oec_percentage
# from filter f
# cross join total_oec t)

# SELECT * FROM final
# --order by 1,2,4
#   ;;
#   }

  dimension:  equipment_class_id {
    primary_key: yes
    type: number
    value_format: "0"
    sql:  ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }

  dimension:  class {
    type: number
    sql:  ${TABLE}."CLASS" ;;
  }

  dimension:  asset_count {
    type: number
    value_format: "#,##0"
    sql:  ${TABLE}."ASSET_COUNT" ;;
  }

  dimension:  oec {
    type: number
    value_format: "$#,##0.00"
    sql:  ${TABLE}."OEC" ;;
  }

  dimension:  market_count {
    type: number
    value_format: "#,##0"
    sql:  ${TABLE}."MARKET_COUNT" ;;
  }

  dimension:  oec_percentage {
    type: number
    value_format: "0.00%"
    sql:  ${TABLE}."OEC_PERCENTAGE" ;;
  }

}
