view: product_specialist_list {
  derived_table: {
    sql:
    WITH records AS (
                        SELECT csd.salesperson_user_id                                                                  AS user_id,
                               cd.employee_id,
                               CONCAT(u.first_name, ' ', u.last_name)                                                   AS name,
                               csd.commission_type,
                               cd.employee_title,
                               cd.market_id,
                               CASE WHEN cd.market_id = 1000000 THEN 'Corporate'
                                    WHEN cd.market_id IS NOT NULL THEN mrx.market_name
                                    WHEN cd.market_id IS NULL AND LENGTH(cd.default_cost_centers_full_path) IN (6, 10)
                                        THEN CONCAT('District ', SUBSTR(cd.default_cost_centers_full_path, 4, 3))
                                    WHEN cd.market_id IS NULL AND LENGTH(cd.default_cost_centers_full_path) = 2
                                        THEN CONCAT('Region ', SUBSTR(cd.default_cost_centers_full_path, 2, 1)) END     AS primary_location_name,
                               mrx.market_name,
                               mrx.region,
                               mrx.region_name,
                               mrx.district,
                               mrx.region_district,
                               CONCAT(u.first_name, ' ', u.last_name, ' - ', u.user_id)                                 AS full_name_with_id,
                               csd.guarantee_start_date,
                               csd.guarantee_end_date,
                               csd.commission_start_date,
                               csd.commission_end_date,
                               ROW_NUMBER() OVER (PARTITION BY salesperson_user_id ORDER BY commission_start_date DESC) AS record_count
                          FROM commissions_salesperson_data csd
                                   LEFT JOIN es_warehouse.public.users u
                                   ON csd.salesperson_user_id = u.user_id
                                   LEFT JOIN analytics.payroll.company_directory cd
                                   ON TRY_TO_NUMBER(u.employee_id) = cd.employee_id
                                   LEFT JOIN analytics.public.market_region_xwalk mrx
                                   ON CASE WHEN cd.market_id IS NOT NULL AND cd.market_id = mrx.market_id THEN 1
                                           WHEN (cd.market_id IS NULL AND SPLIT_PART(cd.default_cost_centers_full_path, '\/', 2) = mrx.district) THEN 1
                                           WHEN (cd.market_id IS NULL AND REGEXP_SUBSTR(SPLIT_PART(cd.default_cost_centers_full_path, '\/', 2), '\\d+')::number = mrx.region) THEN 1
                                           ELSE 0 END = 1
                         WHERE commission_type IN ('ITL', 'P&P'))
  SELECT *
    FROM records
   WHERE record_count = 1;;
  }

  dimension: user_id {
    description: "Unique ID for each user that is marked as P&P or ITL on commission spreadsheet"
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: user_name {
    type: string
    sql: ${TABLE}."USER_NAME" ;;
  }

  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
    value_format_name: id
  }

  dimension: commission_type {
    type: string
    sql: ${TABLE}."COMMISSION_TYPE" ;;
  }

  dimension: full_name_with_id {
    type: string
    sql: ${TABLE}."FULL_NAME_WITH_ID" ;;
  }

  dimension: employee_title {
    type: string
    sql: ${TABLE}."EMPLOYEE_TYPE" ;;
  }

  dimension: market_id {
    description: "From Company Directory if exists."
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
    value_format_name: id
  }

  dimension: primary_location_name {
    description: "Market if exists, else Region or District from CD default cost center."
    type: string
    sql: ${TABLE}."PRIMARY_LOCATION_NAME" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: district {
    type: number
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

  dimension: guarantee_start_date {
    description: "Actual date specialist started specialist position"
    type: date
    sql: dateadd(month,1,${TABLE}."GUARANTEE_START_DATE") ;;
  }

  dimension: guarantee_end_date {
    type: date
    sql: dateadd(month,1,${TABLE}."GUARANTEE_END_DATE") ;;
  }

  dimension: commission_start_date {
    description: "Revenue start date, not payroll start date (+1 month)"
    type: date
    sql: dateadd(month,1,${TABLE}."COMMISSION_START_DATE") ;;
  }

  dimension: commission_end_date {
    type: date
    sql: ${TABLE}."COMMISSION_END_DATE" ;;
  }

  measure: location_distinct_count {
    type: count_distinct
    sql: ${primary_location_name} ;;
    description: "Used to toggle location name on Product Specialist dashboard."
  }
  }
