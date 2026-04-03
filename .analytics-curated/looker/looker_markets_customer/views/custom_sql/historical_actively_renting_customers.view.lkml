
view: historical_actively_renting_customers {
  derived_table: {
    sql: WITH combo AS (
      select *
      FROM analytics.bi_ops.historical_arc where market_name IS NOT NULL
      UNION
      SELECT *
      FROM analytics.bi_ops.current_arc where market_name IS NOT NULL)

      , date_series AS (
          SELECT DATEADD(day, '-' || ROW_NUMBER() OVER (ORDER BY NULL), DATEADD(day, '+1', CONVERT_TIMEZONE('UTC', 'America/Chicago', CURRENT_TIMESTAMP())::DATE)) AS date
          FROM TABLE (GENERATOR(rowcount => (365 * 4))) QUALIFY date >= '2022-01-01' AND date < CONVERT_TIMEZONE('UTC', 'America/Chicago', CURRENT_DATE())
      )

      , each_market AS (
      SELECT  market_id, market_name, district, region, region_name, market_type, MIN(date) as first_date
      FROM combo
      GROUP BY market_id, market_name, district, region, region_name, market_type
      )

      , empty_days AS (
      select *, 0 as arc
      FROM date_series ds
      JOIN each_market em ON em.first_date <= ds.date
      ORDER BY market_id, date ASC
      )



      , daily_arc AS (
      SELECT date, market_id, market_name, district, region, region_name, market_type, COUNT(DISTINCT company_id) as actively_renting_customers
      FROM combo
      GROUP BY date, market_id, market_name, district, region, region_name, market_type
      )

      --, daily_and_empty AS (
      SELECT COALESCE(da.date, em.date) as date,
              COALESCE(da.market_id, em.market_id) as market_id,
              COALESCE(da.market_name, em.market_name) as market_name,
              COALESCE(da.district, em.district) as district,
              COALESCE(da.region, em.region) as region,
              COALESCE(da.region_name, em.region_name) as region_name,
              COALESCE(da.market_type, em.market_type) as market_type,
              first_date,
              COALESCE(actively_renting_customers, arc) as actively_renting_customers
      FROM daily_arc da
      FULL OUTER JOIN empty_days em ON em.date = da.date AND em.market_id = da.market_id AND em.market_name = da.market_name AND em.district = da.district AND em.region = da.region AND em.region_name = da.region_name AND em.market_type = da.market_type ;;
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
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
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
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: first_date {
    type: date
    hidden:  yes
    sql: ${TABLE}."FIRST_DATE" ;;
  }

  dimension: actively_renting_customers {
    type: number
    sql: ${TABLE}."ACTIVELY_RENTING_CUSTOMERS" ;;
  }

  measure: arc {
    type: sum
    sql: ${actively_renting_customers}) ;;
  }


  measure: avg_actively_renting_customers {
    type: number
    sql:  SUM(${actively_renting_customers})/COUNT(DISTINCT ${date_date}) ;;
    value_format_name: decimal_1
  }


  measure: max_actively_renting_customers {
    type: max
    sql:  ${actively_renting_customers} ;;

  }


  measure: median_actively_renting_customers {
    type: median
    sql:  ${actively_renting_customers} ;;

  }

  set: detail {
    fields: [
        date_date,
  market_id,
  market_name,
  district,
  region,
  region_name,
  market_type,
  first_date,
  actively_renting_customers
    ]
  }
}
