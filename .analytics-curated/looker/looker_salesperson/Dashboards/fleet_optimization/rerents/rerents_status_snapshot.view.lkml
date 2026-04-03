view: rerents_status_snapshot {

 derived_table: {

  sql:       WITH base_rerents AS (
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
        ROUND(rr.rerent_net_profit, 2) AS rerent_net_profit,
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
    WHERE rr.rerent_request_status NOT ILIKE '%Denied%'
),

date_spine AS (
    SELECT
        dt_date AS snapshot_date
    FROM fleet_optimization.gold.dim_dates_fleet_opt
    WHERE dt_date >= DATE '2023-01-01'
      AND dt_date <= CURRENT_DATE
)

SELECT
    b.*,
    d.snapshot_date,
    CASE
        WHEN d.snapshot_date < b.rerent_start_date THEN NULL
        WHEN d.snapshot_date BETWEEN b.rerent_start_date AND b.rerent_customer_end_date THEN 'On Rent'
        WHEN d.snapshot_date > b.rerent_customer_end_date THEN b.rerent_request_status
        ELSE NULL
    END AS snapshot_rerent_request_status
FROM base_rerents b
CROSS JOIN date_spine d
where snapshot_rerent_request_status is not null
ORDER BY b.rerent_request_id, d.snapshot_date ;;


 }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."RERENT_ASSET_ID" ;;
    value_format_name: id
  }
  dimension_group: snapshot_date {
    type: time
    sql: ${TABLE}."SNAPSHOT_DATE" ;;

    timeframes: [date, month, quarter, year]
  }
  dimension: status {

    type: string
    sql: ${TABLE}."SNAPSHOT_RERENT_REQUEST_STATUS" ;;


  }
}
