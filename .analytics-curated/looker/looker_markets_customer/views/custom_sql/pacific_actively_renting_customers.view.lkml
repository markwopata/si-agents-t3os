
view: pacific_actively_renting_customers {
  derived_table: {
    sql: WITH date_series AS (
            SELECT
              dateadd(day, '-' || row_number() over (ORDER BY  null), dateadd(day, '+1', CONVERT_TIMEZONE('UTC', 'America/Chicago', CURRENT_TIMESTAMP())::DATE)) AS date
            FROM table (generator(rowcount => (365*3)))
            )

          SELECT
              ds.date
            , o.market_id
            , mrx.market_name
            , mrx.district
            , mrx.region
            , mrx.region_name
            , mrx.market_type
            , COUNT(DISTINCT ea.asset_id) AS assets_on_rent
            , c.company_id
            , c.name as company_name
            , ROUND(SUM(CASE WHEN r.rental_status_id in (9,5,3,7,4,6) THEN COALESCE(aa.oec, 0) ELSE 0 end),2) AS OEC_on_rent
            , 1 as one_flag
             FROM date_series ds
             LEFT JOIN es_warehouse.public.equipment_assignments ea ON ea.start_date <= ds.date and COALESCE(ea.end_date, (current_date())) >= ds.date
             LEFT JOIN es_warehouse.public.rentals r ON r.rental_id = ea.rental_id
             LEFT JOIN es_warehouse.public.orders o ON r.order_id = o.order_id
             LEFT JOIN es_warehouse.public.users u ON u.user_id = o.user_id
             LEFT JOIN es_warehouse.public.companies c ON c.company_id = u.company_id
             LEFT JOIN es_warehouse.public.assets_aggregate aa ON aa.asset_id = ea.asset_id
             LEFT JOIN es_warehouse.public.order_salespersons os ON os.order_id = o.order_id
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

            ORDER BY date, market_id ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension_group: date {
    type: time
    sql: ${TABLE}."DATE" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  measure: actively_renting_customers {
    type: count_distinct
    sql: ${company_id} ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: region {
    type: number
    sql: ${TABLE}."REGION" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: assets_on_rent {
    type: number
    sql: ${TABLE}."ASSETS_ON_RENT" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: oec_on_rent {
    type: number
    sql: ${TABLE}."OEC_ON_RENT" ;;
  }

  dimension: one_flag {
    type: number
    sql: ${TABLE}."ONE_FLAG" ;;
  }

  set: detail {
    fields: [
  market_id,
  market_name,
  district,
  region,
  region_name,
  market_type,
  assets_on_rent,
  company_id,
  company_name,
  oec_on_rent,
  one_flag
    ]
  }
}
