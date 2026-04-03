view: unavailable_oec_pulse {
  derived_table: {
    # datagroup_trigger: 6AM_update , 400days trailing
    sql:with detail as (select ai.generateddate
                ,ai.make
                , ai.class
                , ai.unavailablecount
                , ai.unavailableoec
                ,ai.totalcount
                , ai.totaloec
                , a.rental_branch_id
from ES_WAREHOUSE.SCD.PULLING_INVENTORY_EVENTS ai
inner join ES_WAREHOUSE.PUBLIC.assets a on ai.asset_id = a.asset_id
          left join ES_WAREHOUSE.PUBLIC.assets_aggregate aa on aa.asset_id = a.asset_id
          inner join ES_WAREHOUSE.PUBLIC.markets m on a.rental_branch_id=m.market_id
 and a.rental_branch_id is not null --this branch logic is what was originally be used here and result differ from rsp in the PIE table
),region_selection as (
            select
                distinct region_name as region
            from
                analytics.public.market_region_xwalk
            where
                {% condition region_name_filter %} region_name {% endcondition %}
            )
            , region_selection_count as (
            select
                count(distinct(region)) as total_regions_selected
            from
                region_selection
            )
            , assigned_region as (
            select
                IFF(split_part(DEFAULT_COST_CENTERS_FULL_PATH,'/',2) = 'Corp', 'Midwest',
                  IFF(split_part(DEFAULT_COST_CENTERS_FULL_PATH,'/',2) = 'R2 Mountain West', 'Mountain West',
                    IFF(
                        split_part(split_part(DEFAULT_COST_CENTERS_FULL_PATH,'/',2), ' ',2) = ''
                        ,'Midwest'
                        ,split_part(split_part(DEFAULT_COST_CENTERS_FULL_PATH,'/',2), ' ',2)
                        )
                  )
                ) as region
            from
                analytics.payroll.company_directory
            where
                lower(work_email) = lower('justin.ingold@equipmentshare.com')
            )
 select
          to_date(generateddate) generated_date,
          rental_branch_id,
          mrx.market_name as market,
          mrx.region_name as region,
          case when right(mrx.market_name, 9) = 'Hard Down' then true else false end as hard_down,
          make,
          class,
          sum(unavailablecount) as unavailablecount,
          sum(unavailableoec) as unavailableoec,
          sum(totalcount) as totalcount,
          sum(totaloec) as totaloec,
          IFF(
            IFF(total_regions_selected = 1, rs.region, ar.region) = mrx.region_name,
            TRUE,
            FALSE
          ) AS is_selected_region
        from detail d
        left join analytics.public.market_region_xwalk mrx
        on d.rental_branch_id = mrx.market_id
        cross join region_selection_count rsc
        left join region_selection rs on rsc.total_regions_selected = 1
        cross join assigned_region ar
        group by
          generated_date,
          rental_branch_id,
          mrx.market_name,
          mrx.region_name,
          hard_down,
          make,
          class,
          is_selected_region
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
  dimension: market {
    type: string
    sql: ${TABLE}."MARKET" ;;
  }
  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }
  dimension: is_selected_region {
    type: yesno
    sql: ${TABLE}.is_selected_region ;;
  }
  dimension: selected_region_name {
    type: string
    sql: case when ${is_selected_region} = 'Yes' then 'Highlighted' else ' ' end ;;
  }


  dimension: class {
    type: string
    sql: ${TABLE}."CLASS" ;;
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
    sql: ${unavailable_asset_count}/${total_asset_count} ;;
    value_format_name: percent_1
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

  dimension: goal_text {
    type: string
    sql: 'Goal:' ;;
  }

  filter: region_name_filter {
    type: string
  }

  set: detail {
    fields: [generated_date_date, market_region_xwalk.market_name, make, unavailable_asset_count, total_asset_count, unavailable_asset_oec, total_asset_oec, unavailable_oec_percent_no_html]
  }

}
