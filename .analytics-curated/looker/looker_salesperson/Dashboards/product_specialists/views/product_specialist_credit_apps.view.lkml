view: product_specialist_credit_apps {
  derived_table: {
    sql:   WITH product_specialist_list AS (
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
                                                         WHEN (cd.market_id IS NULL AND
                                                               SPLIT_PART(cd.default_cost_centers_full_path, '\/', 2) = mrx.district) THEN 1
                                                         WHEN (cd.market_id IS NULL AND
                                                               REGEXP_SUBSTR(SPLIT_PART(cd.default_cost_centers_full_path, '\/', 2), '\\d+')::number =
                                                               mrx.region) THEN 1
                                                         ELSE 0 END = 1
                                       WHERE commission_type IN ('ITL', 'P&P') QUALIFY record_count = 1),
       co_first_order          AS (
                                      SELECT u.company_id,
                                             o.order_id,
                                             o.date_created,
                                             ROW_NUMBER() OVER (PARTITION BY u.company_id ORDER BY o.date_created) AS row_num
                                        FROM es_warehouse.public.users u
                                                 LEFT JOIN es_warehouse.public.orders o
                                                 ON u.user_id = o.user_id QUALIFY row_num = 1)
SELECT ca.*,
       fo.order_id as first_order_id,
       fo.date_created as first_order_date_created
  FROM analytics.public.credit_apps ca
           LEFT JOIN co_first_order fo
           ON ca.company_id = fo.company_id
 WHERE ca.salesperson_user_id IN (
                                     SELECT user_id
                                       FROM product_specialist_list)
;;
}

dimension: app_status {
  type: string
  sql: ${TABLE}."APP_STATUS" ;;
}

dimension: company_id {
  type: number
  sql: ${TABLE}."COMPANY_ID" ;;
  value_format_name: id
}

dimension: company_name {
  type: string
  sql: ${TABLE}."COMPANY_NAME" ;;
}

dimension: credit_score {
  type: number
  sql: ${TABLE}."CREDIT_SCORE" ;;
}

dimension: credit_specialist {
  type: string
  sql: ${TABLE}."CREDIT_SPECIALIST" ;;
}

dimension_group: date_completed {
  type: time
  timeframes: [
    raw,
    date,
    week,
    month,
    quarter,
    year
  ]
  convert_tz: no
  datatype: date
  sql: ${TABLE}."DATE_COMPLETED" ;;
}

dimension_group: date_received {
  type: time
  timeframes: [
    raw,
    date,
    week,
    month,
    quarter,
    year
  ]
  convert_tz: no
  datatype: date
  sql: ${TABLE}."DATE_RECEIVED" ;;
}

dimension: duns {
  type: string
  sql: ${TABLE}."DUNS" ;;
}

dimension: es_admin_setup {
  type: yesno
  sql: ${TABLE}."ES_ADMIN_SETUP" ;;
}

dimension: fein {
  type: string
  sql: ${TABLE}."FEIN" ;;
}

dimension: government_entity {
  type: yesno
  sql: ${TABLE}."GOVERNMENT_ENTITY" ;;
}

dimension: linked_to_intacct {
  type: yesno
  sql: ${TABLE}."LINKED_TO_INTACCT" ;;
}

dimension: market_id {
  type: number
  sql: ${TABLE}."MARKET_ID" ;;
  value_format_name: id
}

dimension: market_name {
  type: string
  sql: ${TABLE}."MARKET_NAME" ;;
}

dimension: naics_1 {
  type: number
  sql: ${TABLE}."NAICS_1" ;;
  value_format_name: id
}

dimension: naics_2 {
  type: number
  sql: ${TABLE}."NAICS_2" ;;
  value_format_name: id
}

dimension: notes {
  type: string
  sql: ${TABLE}."NOTES" ;;
}

dimension: ofac {
  type: string
  sql: ${TABLE}."OFAC" ;;
}

dimension: ra_required {
  type: yesno
  sql: ${TABLE}."RA_REQUIRED" ;;
}

dimension: row_number {
  type: number
  sql: ${TABLE}."ROW_NUMBER" ;;
  primary_key: yes
}

dimension: salesperson {
  type: string
  sql: ${TABLE}."SALESPERSON" ;;
}

dimension: salesperson_user_id {
  type: number
  sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  value_format_name: id
}

dimension: sic {
  type: number
  sql: ${TABLE}."SIC" ;;
  value_format_name: id
}

dimension: tin {
  type: number
  sql: ${TABLE}."TIN" ;;
  value_format_name: id
}

dimension: first_order_id {
  type: number
  sql: ${TABLE}."FIRST_ORDER_ID" ;;
  value_format_name: id
}

dimension_group: first_order_date_created {
  type: time
  timeframes: [
    raw,
    date,
    week,
    month,
    quarter,
    year
  ]
  convert_tz: no
  datatype: date
  sql: ${TABLE}."FIRST_ORDER_DATE_CREATED" ;;
}

dimension: is_received_date_last_month {
  type: yesno
  sql: (date_trunc(month,current_date()) - interval '1 month') = date_trunc(month,${date_received_raw}::DATE) ;;
}

dimension: is_received_date_current_month {
  type: yesno
  sql: date_trunc(month,current_date()) =  date_trunc(month,${date_received_raw}::DATE) ;;
}

measure: new_apps_count_current_month {
  type: count
  filters: [is_received_date_current_month: "Yes"]
  drill_fields: [company_id, company_name, market_name, salesperson, date_received_date, first_order_id, first_order_date_created_date]
}

measure: new_apps_count_last_month {
  type: count
  filters: [is_received_date_last_month: "Yes"]
  drill_fields: [company_id, company_name, market_name, salesperson, date_received_date, first_order_id, first_order_date_created_date]

}

measure: count {
  type: count
  drill_fields: [company_name, market_name]
}
}
