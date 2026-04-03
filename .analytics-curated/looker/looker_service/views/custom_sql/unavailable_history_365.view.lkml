view: unavailable_history_365 {
  derived_table: {
    # datagroup_trigger: 6AM_update , 400days trailing
    sql:
 select
          to_date(generateddate) generated_date,
          market_id,
          make,
          class,
          sum(unavailablecount) as unavailablecount,
          sum(unavailableoec) as unavailableoec,
          sum(totalcount) as totalcount,
          sum(totaloec) as totaloec
        from ES_WAREHOUSE.SCD.PULLING_INVENTORY_EVENTS
        group by
          generated_date,
          market_id,
          make,
          class
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

  dimension: market_id { # in the snowflake dynamic table this is actually coalesce(rental, inventory) just dont want to break looker
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
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
