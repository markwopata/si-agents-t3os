view: unavailable_history_hard_soft_down {
 derived_table: {
  # datagroup_trigger: 6AM_update , 400days trailing
  sql:with get_past_days as
      (
        select
          dateadd(
          day,
          '-' || row_number() over (order by null),
          dateadd(day, '+1', current_date())
          ) as generateddate
          from table (generator(rowcount => 500))
        ),
        pulling_inventory_events as (
        select
        convert_timezone('America/Chicago',d.generateddate::date) as generateddate,
        convert_timezone('America/Chicago',ai.date_start) as eventdate,
        --ai.scd_asset_rental_stautus_id,
        ai.asset_id,
        ai.asset_inventory_status,
        --asrb.rental_branch_id,
        sar.rental_branch_id,
         aa.make,
         aa.model,
        case when asset_inventory_status in ('Soft Down', 'Hard Down') then 1 else 0 end as unavailablecount,
        case when asset_inventory_status in ('Soft Down', 'Hard Down') then aa.oec else 0 end as unavailableoec,
        case when asset_inventory_status is not null then 1 else 0 end as totalcount,
        case when asset_inventory_status is not null then aa.oec else 0 end as totaloec
        from
          ES_WAREHOUSE.SCD.scd_asset_inventory_status ai
          inner join get_past_days d on convert_timezone('America/Chicago',d.generateddate::date) <= coalesce(convert_timezone('America/Chicago',ai.date_end),'9999-12-31')
              and convert_timezone('America/Chicago',d.generateddate::date) >= convert_timezone('America/Chicago',ai.date_start::date)
          inner join ES_WAREHOUSE.SCD.SCD_ASSET_RSP sar on convert_timezone('America/Chicago',d.generateddate::date) <= coalesce(convert_timezone('America/Chicago',sar.date_end),'9999-12-31')
              and convert_timezone('America/Chicago',d.generateddate::date) >= convert_timezone('America/Chicago',sar.date_start::date)
              and ai.asset_id = sar.asset_id
          inner join ES_WAREHOUSE.PUBLIC.assets a on ai.asset_id = a.asset_id
          left join ES_WAREHOUSE.PUBLIC.assets_aggregate aa on aa.asset_id = a.asset_id
          inner join ES_WAREHOUSE.PUBLIC.markets m on coalesce((a.rental_branch_id),(a.inventory_branch_id))=(m.market_id)
        where
          ai.asset_inventory_status is not null
          and m.company_id = 1854
          AND a.asset_type_id = 1
          and a.rental_branch_id is not null
        ),
        ranking_inventory_events as (
        select
          *,
          rank ()
          over (
          partition by
            generateddate, asset_id
          order by
            eventdate desc
          ) as ranking
        from
          pulling_inventory_events
          )
 select
          to_date(generateddate) generated_date,
          rental_branch_id,
          make,
          sum(unavailablecount) as unavailablecount,
          sum(unavailableoec) as unavailableoec,
          sum(totalcount) as totalcount,
          sum(totaloec) as totaloec
        from ranking_inventory_events
        where ranking=1
        group by
          generated_date,
          rental_branch_id,
          make
          order by generated_date
       ;;
}

measure: count {
  type: count
  drill_fields: [detail*]
}

dimension_group: generated_date {
  type: time
  timeframes: [date,week,month,year]
  sql: ${TABLE}."GENERATED_DATE" ;;
}

dimension: rental_branch_id {
  type: string
  sql: ${TABLE}."RENTAL_BRANCH_ID" ;;
}

dimension: make {
  type: string
  sql: ${TABLE}."MAKE" ;;
}

dimension: unavailablecount {
  type: number
  sql: ${TABLE}."UNAVAILABLECOUNT" ;;
}

dimension: unavailableoec {
  type: number
  sql: ${TABLE}."UNAVAILABLEOEC" ;;
}

dimension: totalcount {
  type: number
  sql: ${TABLE}."TOTALCOUNT" ;;
}

dimension: totaloec {
  type: number
  sql: ${TABLE}."TOTALOEC" ;;
}

measure: unavailable_asset_count {
  type: sum
  sql: ${unavailablecount} ;;
}

measure: total_asset_count {
  type: sum
  sql: ${totalcount} ;;
}

measure: unavailable_percent {
  type: number
  sql: ${unavailable_asset_count}/${total_asset_count} * 100 ;;
  value_format: "0.0\%"
}

measure: unavailable_asset_oec {
  type: sum
  sql: ${unavailableoec} ;;
  value_format: "$#,##0"
}

measure: total_asset_oec {
  type: sum
  sql: ${totaloec} ;;
  value_format: "$#,##0"
}
measure: days_in_period {
  type: count_distinct
  sql: ${generated_date_date} ;;
}
measure: avg_unavailable_oec_dollars{
  type:  number
  sql: ${unavailable_asset_oec}/${days_in_period} ;;
  value_format: "$#,##0"
}
measure: avg_total_oec_dollars {
  type: number
  sql: ${total_asset_oec}/${days_in_period} ;;
  value_format: "$#,##0"
}
measure: unavailable_oec_percent {
  type: number
  link: {label: "Service Unavailable OEC Trend Table"
    url:"https://equipmentshare.looker.com/looks/742"}
  sql: case when ${unavailable_asset_oec} = 0 or ${total_asset_oec} = 0 then 0 else ${unavailable_asset_oec}/${total_asset_oec} end ;;
  html: {{unavailable_oec_percent._rendered_value}} | {{avg_unavailable_oec_dollars._rendered_value}} Avg Unavailable OEC of {{avg_total_oec_dollars._rendered_value}} Avg Total OEC;;
  value_format_name: percent_1
  drill_fields: [detail*]
}

measure: unavailable_oec_percent_no_html {
  label: "Service Unavailable OEC %"
  type: number
  sql: case when ${unavailable_asset_oec} = 0 or ${total_asset_oec} = 0 then 0 else ${unavailable_asset_oec}/${total_asset_oec} end ;;
  value_format_name: percent_1
  drill_fields: [detail*]
}

measure: unavailable_oec_percent_radial_graph {
  type: number
  sql: ${unavailable_asset_oec}/${total_asset_oec} * 100 ;;
  value_format: "0.0\%"
  drill_fields: [detail*]
}

dimension: goal_text {
  type: string
  sql: 'Goal:' ;;
}


set: detail {
  fields: [generated_date_date, market_region_xwalk.market_name, make, unavailable_asset_count, total_asset_count, unavailable_asset_oec, total_asset_oec, unavailable_oec_percent_no_html]
}

}
