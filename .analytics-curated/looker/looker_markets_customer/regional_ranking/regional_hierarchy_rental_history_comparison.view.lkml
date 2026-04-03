
view: regional_hierarchy_rental_history_comparison {
  derived_table: {
    sql:
      /*select mr.date,
             mr.market_id,
             mr.market_name,
             xw.market_type,
             case when right(xw.market_name, 9) = 'Hard Down' then true else false end as hard_down,
             mr.district,
             mr.region_name,
             mr.assets_on_rent,
             mr.oec_on_rent,
             vmt.IS_CURRENT_MONTHS_OPEN_GREATER_THAN_TWELVE
      from analytics.bi_ops.daily_sp_market_rollup mr
      join analytics.public.market_region_xwalk xw on mr.market_id = xw.market_id
      left join (select market_id, market_name, state, region, region_name, is_current_months_open_greater_than_twelve from analytics.public.v_market_t3_analytics
      group by market_id, market_name, state, region, region_name, is_current_months_open_greater_than_twelve) vmt on vmt.market_id = mr.market_id*/

WITH markets_aor_oec AS (
  SELECT
    date,
    market_id,
    salesperson_user_id,
    rep_name,
    assets_on_rent,
    rerent_assets_on_rent,
    actively_renting_customers,
    rerent_actively_renting_customers,
    oec_on_rent,
    total_market_oec,
    total_market_asset_count,
    NULL AS projected_assets_on_rent,
    NULL AS projected_oec_on_rent
  FROM analytics.bi_ops.market_oec_aor_historical

  UNION ALL

  SELECT
    date,
    market_id,
    salesperson_user_id,
    rep_name,
    assets_on_rent,
    rerent_assets_on_rent,
    actively_renting_customers,
    rerent_actively_renting_customers,
    oec_on_rent,
    total_market_oec,
    total_market_asset_count,
    NULL AS projected_assets_on_rent,
    NULL AS projected_oec_on_rent
  FROM analytics.bi_ops.market_oec_aor_current

  UNION ALL

  SELECT
    date,
    market_id,
    salesperson_user_id,
    rep_name,
    assets_on_rent,
    rerent_assets_on_rent,
    actively_renting_customers,
    rerent_actively_renting_customers,
    oec_on_rent,
    total_market_oec,
    total_market_asset_count,
    projected_assets_on_rent,
    projected_oec_on_rent
  FROM analytics.bi_ops.projected_oec_and_units_on_rent
)



      SELECT
      mao.date
      , mao.market_id
      , mao.salesperson_user_id as primary_sp_user_id
      , mao.rep_name as primary_sp_name
      , xw.market_name
      , xw.market_type
      , case when right(xw.market_name, 9) = 'Hard Down' then true else false end as hard_down
      , xw.district
      , xw.region_name
      , mao.assets_on_rent
      , mao.oec_on_rent
      , mao.projected_assets_on_rent
      , mao.projected_oec_on_rent
      , vmt.IS_CURRENT_MONTHS_OPEN_GREATER_THAN_TWELVE
      , (mao.date = dateadd(day, -1, dateadd(month, 1, date_trunc(month, mao.date)))) OR (mao.date = current_date) as is_last_date


      FROM markets_aor_oec mao
      join analytics.public.market_region_xwalk xw on mao.market_id = xw.market_id
      left join (
        select market_id, is_current_months_open_greater_than_twelve
        from analytics.public.v_market_t3_analytics
        group by market_id, is_current_months_open_greater_than_twelve)
            vmt on vmt.market_id = mao.market_id

    -- using asset ownership where ownership = ES or OWN OR it is CUSTOMER with market_company_id = 1854. Also looking at rentals and tying the primary rep to each rental.  Including House Sales, and converting start/end timestamps of equipment assignments to central time before truncating to a date.
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
    filters: [region: "Industrial"]
  }

  dimension: rental_day {
    type: date
    sql: ${TABLE}."DATE" ;;
  }

  dimension_group: date {
    type: time
    sql:${TABLE}."DATE" ;;
  }

  dimension: is_last_date {
    type: yesno
    sql: ${TABLE}."IS_LAST_DATE" ;;
  }

  dimension: primary_sp_user_id {
    type: string
    sql: ${TABLE}."PRIMARY_SP_USER_ID" ;;
  }

  dimension: primary_sp_user_name {
    type: string
    sql: ${TABLE}."PRIMARY_SP_NAME" ;;
  }
  dimension: region {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
    map_layer_name: es_regions
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: market {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: hard_down {
    type: yesno
    sql: ${TABLE}."HARD_DOWN" ;;
  }

  dimension: months_open_over_12 {
    type: yesno
    sql: ${TABLE}."IS_CURRENT_MONTHS_OPEN_GREATER_THAN_TWELVE" ;;
  }

  dimension: units_on_rent {
    type: number
    sql: ${TABLE}."ASSETS_ON_RENT" ;;
  }

  dimension: oec_on_rent {
    type: number
    sql: ${TABLE}."OEC_ON_RENT" ;;
  }

  dimension: projected_units_on_rent {
    type: number
    sql: ${TABLE}."PROJECTED_ASSETS_ON_RENT" ;;
  }

  dimension: projected_oec_on_rent {
    type: number
    sql: ${TABLE}."PROJECTED_OEC_ON_RENT" ;;
  }

  measure: total_units_on_rent {
    group_label: "Units On Rent"
    label: "Total Units On Rent"
    type: sum
    sql: ${units_on_rent} ;;
  }

  measure: total_oec_on_rent {
    group_label: "OEC On Rent"
    label: "Total OEC On Rent"
    type: sum
    sql: ${oec_on_rent} ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    # value_format_name: usd
  }

  measure: avg_oec_on_rent {
    type: number
    sql:  SUM(${oec_on_rent})/COUNT(DISTINCT ${date_date}) ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    }


  measure: last_day_oec_on_rent {
    type: sum
    sql: case when ${is_last_date} THEN ${oec_on_rent} ELSE NULL END;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }


  dimension: rental_day_formatted {
    group_label: "HTML Formatted Day"
    label: "Date"
    type: date
    sql: ${rental_day} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: current_day {
    type: yesno
    sql: ${rental_day} = current_date ;;
  }

  measure: industrial_total_oec_on_rent {
    group_label: "Region OEC"
    label: "Industrial Total OEC On Rent"
    type: sum
    sql: NULLIFZERO(${oec_on_rent}) ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    # value_format_name: usd
    filters: [region: "Industrial"]
  }

  measure: midwest_total_oec_on_rent {
    group_label: "Region OEC"
    label: "Midwest Total OEC On Rent"
    type: sum
    sql: NULLIFZERO(${oec_on_rent}) ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    # value_format_name: usd
    filters: [region: "Midwest"]
  }

  measure: southwest_total_oec_on_rent {
    group_label: "Region OEC"
    label: "Southwest Total OEC On Rent"
    type: sum
    sql: NULLIFZERO(${oec_on_rent}) ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    # value_format_name: usd
    filters: [region: "Southwest"]
  }

  measure: southeast_total_oec_on_rent {
    group_label: "Region OEC"
    label: "Southeast Total OEC On Rent"
    type: sum
    sql: NULLIFZERO(${oec_on_rent}) ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    # value_format_name: usd
    filters: [region: "Southeast"]
  }

  measure: northeast_total_oec_on_rent {
    group_label: "Region OEC"
    label: "Northeast Total OEC On Rent"
    type: sum
    sql: NULLIFZERO(${oec_on_rent}) ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    # value_format_name: usd
    filters: [region: "Northeast"]
  }

  measure: mountain_west_total_oec_on_rent {
    group_label: "Region OEC"
    label: "Mountain West Total OEC On Rent"
    type: sum
    sql: NULLIFZERO(${oec_on_rent}) ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    # value_format_name: usd
    filters: [region: "Mountain West"]
  }

  measure: pacific_total_oec_on_rent {
    group_label: "Region OEC"
    label: "Pacific Total OEC On Rent"
    type: sum
    sql: NULLIFZERO(${oec_on_rent}) ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
    # value_format_name: usd
    filters: [region: "Pacific"]
  }

  measure: current_total_units_on_rent {
    group_label: "Units On Rent"
    type: sum
    sql: ${units_on_rent} ;;
    filters: [current_day: "Yes"]
  }

  measure: current_day_units_on_rent {
    group_label: "Units On Rent"
    type: number
    sql: NULLIFZERO(${current_total_units_on_rent}) ;;
  }

  measure: current_total_oec_on_rent {
    group_label: "Units On Rent"
    type: sum
    sql: ${oec_on_rent} ;;
    filters: [current_day: "Yes"]
  }

  measure: current_day_oec_on_rent {
    group_label: "OEC On Rent"
    type: number
    sql: NULLIFZERO(${current_total_oec_on_rent}) ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  dimension: seven_days_ago {
    type: yesno
    sql: ${rental_day} = dateadd(days,-6,current_date) ;;
  }

  dimension: thirty_days_ago {
    type: yesno
    sql: ${rental_day} = dateadd(days,-29,current_date) ;;
  }

  dimension: sixty_days_ago {
    type: yesno
    sql: ${rental_day} = dateadd(days,-59,current_date) ;;
  }

  dimension: ninty_days_ago {
    type: yesno
    sql: ${rental_day} = dateadd(days,-89,current_date) ;;
  }

  dimension: is_in_the_last_ninty_days {
    type: yesno
    sql: ${rental_day} BETWEEN dateadd(days,-89,current_date) and current_date() ;;
  }

  measure: seven_days_ago_total_units_on_rent {
    group_label: "Units On Rent"
    type: sum
    sql: ${units_on_rent} ;;
    filters: [seven_days_ago: "Yes"]
    value_format_name: decimal_0
  }

  measure: thirty_days_ago_total_units_on_rent {
    group_label: "Units On Rent"
    type: sum
    sql: ${units_on_rent} ;;
    filters: [thirty_days_ago: "Yes"]
    value_format_name: decimal_0
  }

  measure: sixty_days_ago_total_units_on_rent {
    group_label: "Units On Rent"
    type: sum
    sql: ${units_on_rent} ;;
    filters: [sixty_days_ago: "Yes"]
    value_format_name: decimal_0
  }

  measure: ninty_days_ago_total_units_on_rent {
    group_label: "Units On Rent"
    type: sum
    sql: ${units_on_rent} ;;
    filters: [ninty_days_ago: "Yes"]
    value_format_name: decimal_0
  }

  measure: units_on_rent_today_vs_seven_days_ago {
    group_label: "Units On Rent"
    label: "Units On Rent 7 Days Ago"
    type: number
    sql: ${current_total_units_on_rent} - ${seven_days_ago_total_units_on_rent} ;;
    value_format_name: decimal_0
    html:
    {% if value > 0 %}
    ▲{{seven_days_ago_total_units_on_rent._rendered_value}}
    {% elsif value < 0 %}
    ▼{{seven_days_ago_total_units_on_rent._rendered_value}}
    {% else %}
    {{seven_days_ago_total_units_on_rent._rendered_value}}
    {% endif %}
    ;;
  }
#( ↓ {{_value._rendered_value}} )
# {{seven_days_ago_total_units_on_rent._rendered_value}} ( ↑ {{_value._rendered_value}} )
  measure: units_on_rent_today_vs_thirty_days_ago {
    group_label: "Units On Rent"
    label: "Units On Rent 30 Days Ago"
    type: number
    sql: ${current_total_units_on_rent} - ${thirty_days_ago_total_units_on_rent} ;;
    value_format_name: decimal_0
    html:
    {% if value > 0 %}
      <strong>{{thirty_days_ago_total_units_on_rent._rendered_value}} ( ↑{{ value._rendered_value }} )</strong></font>
    {% elsif value < 0 %}
      <strong>{{thirty_days_ago_total_units_on_rent._rendered_value}} ( ↓{{ value._rendered_value }} )</strong></font>
    {% else %}
      <strong>{{thirty_days_ago_total_units_on_rent._rendered_value}} ( {{ value._rendered_value }} )</strong></font>
    {% endif %}
    ;;
  }

  measure: units_on_rent_today_vs_sixty_days_ago {
    group_label: "Units On Rent"
    label: "Units On Rent 60 Days Ago"
    type: number
    sql: ${current_total_units_on_rent} - ${sixty_days_ago_total_units_on_rent} ;;
    value_format_name: decimal_0
    html:
    {% if value > 0 %}
      <strong>{{sixty_days_ago_total_units_on_rent._rendered_value}} ( ↑{{ value._rendered_value }} )</strong></font>
    {% elsif value < 0 %}
      <strong>{{sixty_days_ago_total_units_on_rent._rendered_value}} ( ↓{{ value._rendered_value }} )</strong></font>
    {% else %}
      <strong>{{sixty_days_ago_total_units_on_rent._rendered_value}} ( {{ value._rendered_value }} )</strong></font>
    {% endif %}
    ;;
  }

  measure: units_on_rent_today_vs_ninty_days_ago {
    group_label: "Units On Rent"
    label: "Units On Rent 90 Days Ago"
    type: number
    sql: ${current_total_units_on_rent} - ${ninty_days_ago_total_units_on_rent} ;;
    value_format_name: decimal_0
    html:
    {% if value > 0 %}
      <strong>{{ninty_days_ago_total_units_on_rent._rendered_value}} ( ↑{{ value._rendered_value }} )</strong></font>
    {% elsif value < 0 %}
      <strong>{{ninty_days_ago_total_units_on_rent._rendered_value}} ( ↓{{ value._rendered_value }} )</strong></font>
    {% else %}
      <strong>{{ninty_days_ago_total_units_on_rent._rendered_value}} ( {{ value._rendered_value }} )</strong></font>
    {% endif %}
    ;;
  }

  measure: sum_projected_units_on_rent {
    type: sum
    sql: ${projected_units_on_rent};;
  }

  measure: total_projected_units_on_rent {
    label: "Scheduled Units on Rent"
    type: number
    sql: case when ${sum_projected_units_on_rent} > 0
              then ${sum_projected_units_on_rent}
              else null
          end;;
  }

  measure: sum_projected_oec_on_rent {
    type: sum
    sql: ${projected_oec_on_rent};;
  }

  measure: total_projected_oec_on_rent {
    label: "Scheduled OEC on Rent"
    type: number
    sql: case when ${sum_projected_oec_on_rent} > 0
    then ${sum_projected_oec_on_rent}
    else null
    end;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  measure: historical_units_on_rent {
    label: "Historical Units on Rent"
    type: number
    sql: case when ${total_units_on_rent} > 0
              then ${total_units_on_rent}
              else null
          end;;
  }

  measure: historical_oec_on_rent {
    label: "Historical OEC on Rent"
    type: number
    sql: case when ${total_oec_on_rent} > 0
          then ${total_oec_on_rent}
          else null
          end;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  set: detail {
    fields: [
        rental_day,
  region,
  district,
  market,
  market_type,
  units_on_rent,
  oec_on_rent
    ]
  }
}
