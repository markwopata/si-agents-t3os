view: first_day_breakdowns_by_market_30_days_table {
  derived_table: {
    sql:
      WITH region_selection AS (
  SELECT DISTINCT region
  FROM analytics.public.market_region_xwalk
  WHERE {% condition region_name %} region_name {% endcondition %}
),
region_selection_count AS (
  SELECT COUNT(region) AS total_regions_selected
  FROM region_selection
),
region_selection_scalar AS (
  SELECT region AS selected_region
  FROM region_selection
  LIMIT 1
),
assigned_district AS (
  SELECT
    IFF(
      CASE
        WHEN SPLIT_PART(DEFAULT_COST_CENTERS_FULL_PATH, '/', 3) NOT IN ('Corporate', 'T3', 'National', '') THEN
          LEFT(SPLIT_PART(DEFAULT_COST_CENTERS_FULL_PATH, '/', 3), 1) = rss.selected_region
        ELSE FALSE
      END,
      SPLIT_PART(DEFAULT_COST_CENTERS_FULL_PATH, '/', 3),
      CONCAT(rss.selected_region, '-', '1')
    ) AS district
  FROM analytics.payroll.company_directory cd
  CROSS JOIN region_selection_scalar rss
  WHERE LOWER(cd.work_email) = 'ronny.robinson@equipmentshare.com'
)



SELECT
  fd.*,
  xw.market_name,
  CASE
    WHEN RIGHT(xw.market_name, 9) = 'Hard Down' THEN TRUE
    ELSE FALSE
  END AS hard_down,
  xw.district,
  xw.region_name,
  vmt.is_current_months_open_greater_than_twelve,
  IFF(
  xw.district = ar.district,
  TRUE,
  FALSE
) AS is_selected_district

FROM analytics.bi_ops.first_day_breakdowns_by_market_30_days fd
JOIN analytics.public.market_region_xwalk xw ON fd.market_id = xw.market_id
LEFT JOIN (
  SELECT market_id, market_name, state, region, region_name, is_current_months_open_greater_than_twelve
  FROM analytics.public.v_market_t3_analytics
  GROUP BY market_id, market_name, state, region, region_name, is_current_months_open_greater_than_twelve
) vmt ON vmt.market_id = fd.market_id
CROSS JOIN region_selection_count rsc
LEFT JOIN region_selection rs ON rsc.total_regions_selected = 1
CROSS JOIN assigned_district ar
;;
  }


  dimension: completed_dropoffs_30 {
    type: number
    sql: ${TABLE}."COMPLETED_DROPOFFS_30" ;;
  }
  dimension_group: delivery {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DELIVERY_DATE" ;;
  }
  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }
  dimension: market {
    type: string
    sql: ${TABLE}."MARKET" ;;
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }
  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }
  dimension: is_selected_district {
    type: yesno
    sql: ${TABLE}.is_selected_district ;;
  }
  dimension: region_name {
    type: string
    sql: ${TABLE}.region_name ;;
  }
  dimension: wos_within_24_hrs_30_day_count {
    type: number
    sql: ${TABLE}."WOS_WITHIN_24HRS_30_DAY_COUNT" ;;
  }
  measure: count {
    type: count
  }
  filter: region_name_filter {
    type: string
  }
}
