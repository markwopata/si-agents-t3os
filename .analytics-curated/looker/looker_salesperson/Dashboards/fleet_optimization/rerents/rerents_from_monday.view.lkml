view: rerents_from_monday {
    derived_table: {
      sql:
      SELECT
        rr.rerent_request_id,
        rr.rerent_asset_id,
        rr.rerent_asset,
        rr.rerent_vendor,
        rr.rerent_customer,
        rr.rerent_asset_operating_hours,
        rr.rerent_swap_availability,
        rr.rerent_no_swap_reason,
        rr.rerent_requestor_email,
        rr.rerent_request_status,
        ds.dt_date AS rerent_start_date,
        rr.rerent_duration_customer,
        dce.dt_date AS rerent_customer_end_date,
        rr.rerent_duration_vendor,
        dve.dt_date AS rerent_vendor_end_date,
        rr.rerent_vendor_monthly_rate,
        rr.rerent_es_monthly_rate,
        round(rr.rerent_net_profit,2) as rerent_net_profit,
        rr.rerent_is_losing_money AS monthly_rate_net_loss,
        m.market_id,
        m.market_name,
        m.market_district,
        m.market_region,
        m.market_region_name,
        m.market_state,
        m.market_type
      FROM fleet_optimization.gold.dim_rerents rr
      JOIN fleet_optimization.gold.dim_markets_fleet_opt m
        ON rr.rerent_market_key = m.market_key
      JOIN fleet_optimization.gold.dim_dates_fleet_opt ds
        ON rr.rerent_start_date_key = ds.dt_key
      JOIN fleet_optimization.gold.dim_dates_fleet_opt dce
        ON rr.rerent_customer_end_date_key = dce.dt_key
      JOIN fleet_optimization.gold.dim_dates_fleet_opt dve
        ON rr.rerent_vendor_end_date_key = dve.dt_key
      WHERE rr.rerent_request_status not ilike '%Denied%'
    ;;
    }

  dimension: rerent_request_id {
    type: string
    sql: ${TABLE}.rerent_request_id ;;
  }

  dimension: rerent_asset_id {
    type: string
    sql: ${TABLE}.rerent_asset_id ;;
  }

  dimension: rerent_asset {
    type: string
    sql: ${TABLE}.rerent_asset ;;
  }

  dimension: rerent_vendor {
    type: string
    sql: ${TABLE}.rerent_vendor ;;
  }

  dimension: rerent_customer {
    type: string
    sql: ${TABLE}.rerent_customer ;;
  }

  dimension: rerent_asset_operating_hours {
    type: number
    sql: ${TABLE}.rerent_asset_operating_hours ;;
  }

  dimension: rerent_swap_availability {
    type: string
    sql: ${TABLE}.rerent_swap_availability ;;
  }

  dimension: rerent_no_swap_reason {
    type: string
    sql: ${TABLE}.rerent_no_swap_reason ;;
  }

  dimension: rerent_requestor_email {
    type: string
    sql: ${TABLE}.rerent_requestor_email ;;
  }

  dimension: rerent_request_status {
    type: string
    sql: ${TABLE}.rerent_request_status ;;
  }

  dimension_group: rerent_start_date {
    type: time
    timeframes: [raw, date, week, month, year]
    sql: ${TABLE}.rerent_start_date ;;
  }

  dimension: rerent_duration_customer {
    type: number
    sql: ${TABLE}.rerent_duration_customer ;;
  }

  dimension: rerent_customer_end_date {
    type: date
    sql: ${TABLE}.rerent_customer_end_date ;;
  }

  dimension: rerent_duration_vendor {
    type: number
    sql: ${TABLE}.rerent_duration_vendor ;;
  }

  dimension: rerent_vendor_end_date {
    type: date
    sql: ${TABLE}.rerent_vendor_end_date ;;
  }

  dimension: rerent_vendor_monthly_rate {
    type: number
    sql: ${TABLE}.rerent_vendor_monthly_rate ;;
  }

  dimension: rerent_es_monthly_rate {
    type: number
    sql: ${TABLE}.rerent_es_monthly_rate ;;
  }

  dimension: rerent_monthly_net_profit {
    type: number
    sql: ${TABLE}.rerent_net_profit ;;
  }

  dimension: monthly_rate_net_loss {
    type: yesno
    sql: ${TABLE}.monthly_rate_net_loss ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}.market_id ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}.market_name ;;
  }

  dimension: market_district {
    type: string
    sql: ${TABLE}.market_district ;;
  }

  dimension: market_region {
    type: string
    sql: ${TABLE}.market_region ;;
  }

  dimension: market_region_name {
    type: string
    sql: ${TABLE}.market_region_name ;;
  }

  dimension: market_state {
    type: string
    sql: ${TABLE}.market_state ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}.market_type ;;
  }

  dimension: estimated_profit_margin {
    type: number
    sql: ${rerent_monthly_net_profit} / NULLIF(${rerent_vendor_monthly_rate}, 0);;
    value_format_name: percent_2
  }

  dimension: profit_margin_band {
    type: string
    sql: CASE
          WHEN ${estimated_profit_margin} < 0 THEN 'Loss'
          WHEN ${estimated_profit_margin} < 0.1 THEN 'Low (<10%)'
          WHEN ${estimated_profit_margin} < 0.2 THEN 'Medium (10-20%)'
          ELSE 'High (>20%)'
        END ;;
  }

  measure: count {
    type: count
  }

  measure: total_net_profit {
    type: sum
    sql: ${rerent_monthly_net_profit} ;;
    value_format_name: usd
  }

  measure: average_estimated_profit_margin {
    type:average
    sql: ${estimated_profit_margin};;
    value_format_name: percent_2
  }

  measure: losing_rerents {
    type: count
    filters: [monthly_rate_net_loss: "yes"]
  }

  measure: missed_swaps_no_reason {
    type: sum
    sql: CASE
         WHEN ${rerent_swap_availability} = 'Yes' AND ${rerent_no_swap_reason} = 'No Reason Provided'
         THEN 1 ELSE 0
       END ;;
  }

  measure: avg_duration_customer {
    type: average
    sql: ${rerent_duration_customer} ;;
    value_format_name: decimal_1
  }

}
