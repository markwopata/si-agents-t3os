# Be careful when making tiles based on the data in the analytics.public.utilization_rankings table.
# The table has actual point-in-time aggregate values and to display them on the Y axis on a tile, they have to be a measure.
# In making them a measure, they can inadvertantly get aggregated together if you don't include date_recorded *time* since it's
# the most granular level.
# Basically, don't try to do stuff like show revenue_31_days by month. Always do it by date_recorded time.
#
# Shortcut story: https://app.shortcut.com/businessanalytics/story/63117/add-company-rank-on-the-utilization-metrics
#
# 10/20/21 - Jack G. - Known issue: I changed the snowflake task to run every 3 hours and to also include markets that don't have assets.
#                                   I did this to hopefully get ahead of the time when they add assets so that we don't have as many holes
#                                   in the data. We'll still have gaps for markets when they're new. Might deal with this using table calcs?

view: utilization_rankings {
  derived_table: {
    sql:
    with current_rank as (select market_id,
                             fin_util_rank,
                             fin_util,
                             unit_util_rank,
                             unit_util,
                             oec_on_rent_perc_rank,
                             oec_on_rent_perc
                      from analytics.public.utilization_rankings
                          qualify row_number() over (partition by market_id order by date_recorded desc) = 1
                          )
    select ur.id,
           ur.date_recorded,
           ur.market_id,
           ur.market_name,
           ur.total_assets,
           ur.total_oec,
           ur.total_units_on_rent,
           ur.total_oec_on_rent,
           ur.unit_util,
           ur.unit_util_rank,
           ur.oec_on_rent_perc,
           ur.oec_on_rent_perc_rank,
           ur.revenue_31_days,
           ur.fin_util,
           ur.fin_util_rank,
           ur.snowflake_task,
           row_number() over (partition by ur.market_id, ur.date_recorded::date order by ur.date_recorded desc) as record_rank_by_date,
           current_rank.fin_util_rank                                                                           as current_fin_util_rank,
           current_rank.unit_util_rank                                                                          as current_unit_util_rank,
           current_rank.oec_on_rent_perc_rank                                                                   as current_oec_on_rent_perc_rank,
           current_rank.fin_util                                                                                as current_fin_util,
           current_rank.unit_util                                                                               as current_unit_util,
           current_rank.oec_on_rent_perc                                                                        as current_oec_on_rent_perc

    from analytics.public.utilization_rankings ur
             inner join current_rank on current_rank.MARKET_ID = ur.market_id
    ;;
  }

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
  }

  dimension_group: date_recorded {
    type: time
    drill_fields: [detail*]
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: convert_timezone('UTC', 'America/Chicago', ${TABLE}."DATE_RECORDED") ;;
  }

# These 6 are added as dimensions so that I can concatenate their values in with the market name.
# This allows you to use one of the market name dimensions and see the corresponding current values
# in the legend on the tile.
  dimension: current_fin_util_rank {
    type: number
    sql: ${TABLE}."CURRENT_FIN_UTIL_RANK" ;;
  }

  dimension: current_unit_util_rank {
    type: number
    sql: ${TABLE}."CURRENT_UNIT_UTIL_RANK" ;;
  }

  dimension: current_oec_on_rent_perc_rank {
    type: number
    sql: ${TABLE}."CURRENT_OEC_ON_RENT_PERC_RANK" ;;
  }

  dimension: current_fin_util {
    type: number
    sql: ${TABLE}."CURRENT_FIN_UTIL" ;;
  }

  dimension: current_unit_util {
    type: number
    sql: ${TABLE}."CURRENT_UNIT_UTIL" ;;
  }

  dimension: current_oec_on_rent_perc {
    type: number
    sql: ${TABLE}."CURRENT_OEC_ON_RENT_PERC" ;;
  }

  dimension: fin_util {
    type: number
    drill_fields: [detail*]
    sql: ${TABLE}."FIN_UTIL" ;;
  }

  dimension: fin_util_rank {
    type: number
    drill_fields: [detail*]
    sql: ${TABLE}."FIN_UTIL_RANK" ;;
  }

  dimension: market_id {
    type: number
    drill_fields: [detail*]
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    drill_fields: [detail*]
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: market_name_fin_util {
    type: string
    html: {{rendered_value}} - #{{current_fin_util_rank._rendered_value}} - {{current_fin_util._rendered_value | times: 100 | round: 2}}%;;
    drill_fields: [detail*]
    # sql: ${market_name};; # Using xwalk because this table has differing versions of market names, causing them to show up as separate markets
    sql: ${market_region_xwalk.market_name} ;;
  }

  dimension: market_name_unit_util {
    type: string
    html: {{rendered_value}} - #{{current_unit_util_rank._rendered_value}} - {{current_unit_util._rendered_value | times: 100 | round: 2}}%;;
    drill_fields: [detail*]
    # sql: ${market_name};; # Using xwalk because this table has differing versions of market names, causing them to show up as separate markets
    sql: ${market_region_xwalk.market_name} ;;
  }

  dimension: market_name_oec_perc {
    type: string
    html: {{rendered_value}} - #{{current_oec_on_rent_perc_rank._rendered_value}} - {{current_oec_on_rent_perc._rendered_value | times: 100 | round: 2}}%;;
    drill_fields: [detail*]
    # sql: ${market_name};; # Using xwalk because this table has differing versions of market names, causing them to show up as separate markets
    sql: ${market_region_xwalk.market_name} ;;
  }

  dimension: oec_on_rent_perc {
    type: number
    drill_fields: [detail*]
    sql: ${TABLE}."OEC_ON_RENT_PERC" ;;
  }

  dimension: oec_on_rent_perc_rank {
    type: number
    drill_fields: [detail*]
    sql: ${TABLE}."OEC_ON_RENT_PERC_RANK" ;;
  }

  dimension: revenue_31_days {
    type: number
    drill_fields: [detail*]
    sql: ${TABLE}."REVENUE_31_DAYS" ;;
  }

  dimension: snowflake_task {
    type: string
    sql: ${TABLE}."SNOWFLAKE_TASK" ;;
  }

  dimension: total_assets {
    type: number
    drill_fields: [detail*]
    sql: ${TABLE}."TOTAL_ASSETS" ;;
  }

  dimension: total_oec {
    type: number
    drill_fields: [detail*]
    sql: ${TABLE}."TOTAL_OEC" ;;
  }

  dimension: total_oec_on_rent {
    type: number
    drill_fields: [detail*]
    sql: ${TABLE}."TOTAL_OEC_ON_RENT" ;;
  }

  dimension: total_units_on_rent {
    type: number
    drill_fields: [detail*]
    sql: ${TABLE}."TOTAL_UNITS_ON_RENT" ;;
  }

  dimension: unit_util {
    type: number
    drill_fields: [detail*]
    sql: ${TABLE}."UNIT_UTIL" ;;
  }

  dimension: unit_util_rank {
    type: number
    drill_fields: [detail*]
    sql: ${TABLE}."UNIT_UTIL_RANK" ;;
  }

  dimension: record_rank_by_date {
    description: "Rank over market and date where 1 is the last/newest record for that day and market."
    type: number
    sql: ${TABLE}."RECORD_RANK_BY_DATE" ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: financial_utilization {
    type: number
    drill_fields: [detail*]
    sql: ${total_revenue_31_days} * 365 / 31 / nullif(${total_oec_measure}, 0) ;;
    }

  measure: oec_on_rent_percent {
    type: number
    drill_fields: [detail*]
    sql: ${total_oec_on_rent_measure} / nullif(${total_oec_measure}, 0) ;;
  }

  measure: unit_utilization {
    type: number
    drill_fields: [detail*]
    sql: ${total_units_on_rent_measure} / nullif(${total_assets_measure}, 0) ;;
  }

  measure: total_assets_measure {
    type: sum
    drill_fields: [detail*]
    sql: ${total_assets} ;;
  }

  measure: total_oec_measure {
    type: sum
    drill_fields: [detail*]
    sql: ${total_oec} ;;
  }

  measure: total_revenue_31_days {
    type: sum
    drill_fields: [detail*]
    sql: ${revenue_31_days} ;;
  }

  measure: total_oec_on_rent_measure {
    type: sum
    drill_fields: [detail*]
    sql: ${total_oec_on_rent} ;;
  }

  measure: total_units_on_rent_measure {
    type: sum
    drill_fields: [detail*]
    sql: ${total_units_on_rent} ;;
  }

  measure: fin_util_rank_measure {
    label: "Financial Utilization Rank"
    html: Rank #{{rendered_value}}<br>Fin. Util.: {{financial_utilization._rendered_value | times: 100 | round: 2}}% ;;
    type: average
    value_format_name: decimal_0
    drill_fields: [detail*]
    sql: ${fin_util_rank} ;;
  }

  measure: oec_on_rent_perc_rank_measure {
    label: "OEC On Rent % Rank"
    html: Rank #{{rendered_value}}<br>OEC On Rent: {{oec_on_rent_percent._rendered_value | times: 100 | round: 2}}% ;;
    type: average
    value_format_name: decimal_0
    drill_fields: [detail*]
    sql: ${oec_on_rent_perc_rank} ;;
  }

  measure: unit_utilization_rank {
    label: "Unit Utilization Rank"
    html: Rank #{{rendered_value}}<br>Unit Util: {{unit_utilization._rendered_value | times: 100 | round: 2}}% ;;
    type: average
    value_format_name: decimal_0
    drill_fields: [detail*]
    sql: ${unit_util_rank} ;;
  }



  set: detail {
    fields: [date_recorded_time, market_name, total_assets, total_oec, total_oec_on_rent, financial_utilization, fin_util_rank_measure, unit_utilization, unit_util_rank, oec_on_rent_percent, oec_on_rent_perc_rank]
  }

  }
