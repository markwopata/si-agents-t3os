
view: market_oec_v2 {
  derived_table: {
    sql: WITH date_series AS (
              SELECT
          DATEADD(
              day,
              '-' || ROW_NUMBER() OVER (ORDER BY NULL),
              DATEADD(day, '+1', CONVERT_TIMEZONE('UTC', 'America/Chicago', CURRENT_TIMESTAMP())::DATE)
          ) AS date
      FROM TABLE (GENERATOR(rowcount => (365)))
      )

      , market_oec_assets AS (
              SELECT
                ds.date
              , ai.rental_branch_id AS market_id
              , SUM(COALESCE(aa.oec, 0)) as market_id_OEC
              , COUNT(DISTINCT  ai.asset_id) AS asset_id_count
              FROM date_series ds
              LEFT JOIN analytics.bi_ops.asset_status_and_rsp_daily_snapshot ai ON ds.date >= ai.generated_day and ds.date <= COALESCE(ai.generated_day, CONVERT_TIMEZONE('UTC', 'America/Chicago', CURRENT_TIMESTAMP())::DATE)
              LEFT JOIN es_warehouse.public.assets_aggregate aa ON aa.asset_id = ai.asset_id
              LEFT JOIN analytics.bi_ops.asset_ownership ao ON ao.asset_id = aa.asset_id
              WHERE ds.date >= '2024-11-01'::DATE
              AND (aa.company_id = 142180 OR (ao.ownership in ('ES', 'OWN') AND ao.rentable = TRUE))
              GROUP BY ds.date, ai.rental_branch_id

      )

      , rep_oec_assets AS (
          SELECT ds.date
              , o.market_id
              , COALESCE(os.user_id, o.salesperson_user_id) AS salesperson_user_id
              , COUNT(DISTINCT  ea.asset_id) AS assets_on_rent
              , COUNT(DISTINCT  c.company_id) AS actively_renting_customers
              , SUM(CASE WHEN  r.rental_status_id in (9,5,3,7,4,6) THEN COALESCE(aa.oec, 0) ELSE 0 end) AS OEC_on_rent
               FROM date_series ds
               LEFT JOIN es_warehouse.public.equipment_assignments ea ON ea.start_date <= ds.date and COALESCE(ea.end_date, (CONVERT_TIMEZONE('UTC', 'America/Chicago', CURRENT_TIMESTAMP())::DATE)) >= ds.date
               LEFT JOIN es_warehouse.public.rentals r ON r.rental_id = ea.rental_id
               LEFT JOIN es_warehouse.public.orders o ON r.order_id = o.order_id
               LEFT JOIN es_warehouse.public.users u ON u.user_id = o.user_id
               LEFT JOIN es_warehouse.public.companies c ON c.company_id = u.company_id
               LEFT JOIN es_warehouse.public.assets_aggregate aa ON aa.asset_id = ea.asset_id
               LEFT JOIN es_warehouse.public.order_salespersons os ON os.order_id = o.order_id
                LEFT JOIN analytics.bi_ops.asset_ownership ao ON ao.asset_id = aa.asset_id
               WHERE c.company_id not in (1854,1855,8151,155) AND r.deleted = false AND o.deleted = false AND ((ao.ownership in ('ES', 'OWN') AND ao.rentable = TRUE) OR (aa.company_id = 142180))
                --and date = CONVERT_TIMEZONE('UTC', 'America/Chicago', CURRENT_TIMESTAMP())::DATE
                and date >= '2024-11-01'::DATE
               GROUP BY ds.date , o.market_id, COALESCE(os.user_id, o.salesperson_user_id)
      )

      , rep_oec_assets_rerents_only AS (
          SELECT ds.date
              , o.market_id
              , COALESCE(os.user_id, o.salesperson_user_id) AS salesperson_user_id
              , COUNT(DISTINCT  ea.asset_id) AS rerent_assets_on_rent
              , COUNT(DISTINCT  c.company_id) AS rerent_actively_renting_customers
               FROM date_series ds
               LEFT JOIN es_warehouse.public.equipment_assignments ea ON ea.start_date <= ds.date and COALESCE(ea.end_date, (CONVERT_TIMEZONE('UTC', 'America/Chicago', CURRENT_TIMESTAMP())::DATE)) >= ds.date
               LEFT JOIN es_warehouse.public.rentals r ON r.rental_id = ea.rental_id
               LEFT JOIN es_warehouse.public.orders o ON r.order_id = o.order_id
               LEFT JOIN es_warehouse.public.users u ON u.user_id = o.user_id
               LEFT JOIN es_warehouse.public.companies c ON c.company_id = u.company_id
               LEFT JOIN es_warehouse.public.assets_aggregate aa ON aa.asset_id = ea.asset_id
               LEFT JOIN es_warehouse.public.order_salespersons os ON os.order_id = o.order_id
               LEFT JOIN analytics.bi_ops.asset_ownership ao ON ao.asset_id = aa.asset_id
               WHERE c.company_id not in (1854,1855,8151,155) AND r.deleted = false AND o.deleted = false AND ao.ownership in ('RR') AND ao.rentable = TRUE
               --and date = CONVERT_TIMEZONE('UTC', 'America/Chicago', CURRENT_TIMESTAMP())::DATE
                and date >= '2024-11-01'::DATE
               GROUP BY ds.date , o.market_id, COALESCE(os.user_id, o.salesperson_user_id)
      )

      , rep_market_oec_assets_info AS (
              SELECT
                roa.date
              , roa.market_id
              , roa.salesperson_user_id
              , roa.assets_on_rent
              , COALESCE(roar.rerent_assets_on_rent, 0) as rerent_assets_on_rent
              , roa.actively_renting_customers
              , COALESCE(roar.rerent_actively_renting_customers, 0) as rerent_actively_renting_customers
              , roa.OEC_on_rent
              , moa.market_id_OEC AS total_market_OEC
              , moa.asset_id_count AS total_market_asset_count
              FROM rep_oec_assets roa
              LEFT JOIN market_oec_assets moa ON moa.date = roa.date and moa.market_id = roa.market_id
              LEFT JOIN rep_oec_assets_rerents_only roar ON roar.date = roa.date AND roar.market_id = roa.market_id AND roar.salesperson_user_id = roa.salesperson_user_id
      )

          SELECT rmo.date
              , rmo.market_id
              , m.name as market_name
              , rmo.salesperson_user_id
              , hist.assets_on_rent as v1_aor
              , rmo.assets_on_rent as v2_aor
              , hist.OEC_on_rent as v1_oec
              , rmo.OEC_on_rent as v2_oec
              , hist.total_market_oec AS v1_total_market_oec
              , rmo.total_market_OEC as v2_total_market_oec
              , hist.total_market_asset_count as v1_total_market_asset_count
              , rmo.total_market_asset_count as v2_total_market_asset_count

          FROM rep_market_oec_assets_info rmo
          LEFT JOIN analytics.bi_ops.rep_market_oec_aor_historical hist on hist.date = rmo.date AND hist.salesperson_user_id = rmo.salesperson_user_id and hist.market_id = rmo.market_id
          LEFT JOIN es_warehouse.public.markets m on m.market_id = rmo.market_id
          WHERE rmo.date >= '2024-11-01'::DATE ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: date {
    type: date
    sql: ${TABLE}."DATE" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }


  dimension: salesperson_user_id {
    type: string
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  measure: v1_assets_on_rent {
    type: sum
    sql: ${TABLE}."V1_AOR" ;;
  }

  measure: v2_assets_on_rent {
    type: sum
    sql: ${TABLE}."V2_AOR" ;;
  }

  measure: v1_oec_on_rent {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."V1_OEC" ;;
  }

  measure: v2_oec_on_rent {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."V2_OEC" ;;
  }

  measure: v1_total_market_oec {
    type: max
    value_format_name: usd_0

    sql: ${TABLE}."V1_TOTAL_MARKET_OEC" ;;
  }

  measure: v2_total_market_oec {
    type: max
    value_format_name: usd_0
    sql: ${TABLE}."V2_TOTAL_MARKET_OEC" ;;
  }

  measure: v1_total_market_asset_count {
    type: max
    sql: ${TABLE}."V1_TOTAL_MARKET_ASSET_COUNT" ;;
  }
  measure: v2_total_market_asset_count {
    type: max
    sql: ${TABLE}."V2_TOTAL_MARKET_ASSET_COUNT" ;;
  }

  set: detail {
    fields: [
        date,
  market_id
    ]
  }
}
