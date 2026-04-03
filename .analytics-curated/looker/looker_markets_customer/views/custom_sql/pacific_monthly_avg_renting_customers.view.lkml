view: pacific_monthly_avg_renting_customers {
  derived_table: {
    sql: WITH date_series AS (
            SELECT
              dateadd(day, '-' || row_number() over (ORDER BY  null), dateadd(day, '+1', CONVERT_TIMEZONE('UTC', 'America/Chicago', CURRENT_TIMESTAMP())::DATE)) AS date
            FROM table (generator(rowcount => (365*3)))
            )
        , market_company_oec_by_date AS (
          SELECT
              ds.date
            , o.market_id
            , mrx.market_name
            , mrx.district
            , mrx.region
            , mrx.region_name
            , mrx.market_type
           -- , COUNT(DISTINCT ea.asset_id) AS assets_on_rent
            , c.company_id
            , c.name as company_name
           -- , ROUND(SUM(CASE WHEN r.rental_status_id in (9,5,3,7,4,6) THEN COALESCE(aa.oec, 0) ELSE 0 end),2) AS OEC_on_rent
            , 1 as one_flag
             FROM date_series ds
             LEFT JOIN es_warehouse.public.equipment_assignments ea ON ea.start_date <= ds.date and COALESCE(ea.end_date, (current_date())) >= ds.date
             LEFT JOIN es_warehouse.public.rentals r ON r.rental_id = ea.rental_id
             LEFT JOIN es_warehouse.public.orders o ON r.order_id = o.order_id
             LEFT JOIN es_warehouse.public.users u ON u.user_id = o.user_id
             LEFT JOIN es_warehouse.public.companies c ON c.company_id = u.company_id
             LEFT JOIN es_warehouse.public.assets_aggregate aa ON aa.asset_id = ea.asset_id
            -- LEFT JOIN es_warehouse.public.order_salespersons os ON os.order_id = o.order_id
             LEFT JOIN analytics.public.market_region_xwalk mrx ON mrx.market_id = o.market_id
             LEFT JOIN analytics.bi_ops.asset_ownership ao ON ao.asset_id = aa.asset_id

      WHERE
      c.company_id not in (1854,1855,8151,155)
      and
      r.deleted = false
      and o.deleted = false and ao.ownership in ('ES', 'OWN') AND ao.rentable = TRUE
      and date >= '2022-01-01'::DATE and date < CONVERT_TIMEZONE('UTC', 'America/Chicago', CURRENT_TIMESTAMP())::DATE
      --and r.rental_status_id in (9,5,3,7,4,6)
      and region_name = 'Pacific'
      GROUP BY
      ds.date
      , o.market_id
      , mrx.market_name
      , mrx.district
      , mrx.region
      , mrx.region_name
      , mrx.market_type
      , c.company_id
      , c.name

      ORDER BY date, market_id)

      , arc_by_date AS (
      SELECT date, market_name, market_id, district, region, region_name,market_type, COUNT(DISTINCT company_id) as daily_actively_renting_customers
      FROM market_company_oec_by_date
      GROUP BY  date, market_name, market_id, district, region, region_name, market_type)

      SELECT date_trunc(month, date) as month, market_name, market_id, district, region, region_name, market_type,ROUND(AVG(daily_actively_renting_customers), 1) as monthly_avg_actively_renting_customers
      FROM arc_by_date
      GROUP BY date_trunc(month, date), market_name, market_id, district, region, region_name, market_type

    ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: month {
    type: date_month
    sql: ${TABLE}."MONTH" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  measure: monthly_avg_actively_renting_customers {
    type: average
    sql: ${TABLE}."MONTHLY_AVG_ACTIVELY_RENTING_CUSTOMERS" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }




  set: detail {
    fields: [
      market_id,
      market_name,
      district
    ]
  }
}
