view: asset_fin_util {
  derived_table: {
    sql:
--     WITH days_in_service AS (SELECT asset_id,
--                                     CURRENT_DATE() - MIN(date_start)::date AS days_in_service
--                                FROM es_warehouse.scd.scd_asset_inventory_status
--                               WHERE asset_inventory_status = 'Ready To Rent'
--                                 AND date_start < DATEADD('day', -1, CURRENT_DATE())
--                               GROUP BY asset_id),

-- removed prior logic in order to match how branch earnings is calculating days-in-service -Jack G 4/6/22
  WITH days_in_service AS (SELECT asset_id,
                                  CURRENT_DATE() - MIN(date)::date AS days_in_service
                             FROM analytics.public.historical_asset_market
                            WHERE date < DATEADD('day', -1, CURRENT_DATE())
                            GROUP BY asset_id),
       oec             AS (SELECT asset_id,
                                  COALESCE(aph.oec, aph.purchase_price) AS oec
                             FROM es_warehouse.public.asset_purchase_history aph
                            WHERE oec IS NOT NULL AND oec > 0.9),  -- changed from oec > 0 to oec > 0.9 due to and issue with one asset (8039) that was a demo but now is rentable - KC 12/20/23
       revenue         AS (SELECT li.asset_id,
                                  SUM(IFF(li.gl_billing_approved_date >= DATEADD('day', -30, CURRENT_DATE()), li.amount,
                                          0))            AS revenue_30,
                                  SUM(IFF(li.gl_billing_approved_date >= DATEADD('day', -60, CURRENT_DATE()), li.amount,
                                          0))            AS revenue_60,
                                  SUM(IFF(li.gl_billing_approved_date >= DATEADD('day', -90, CURRENT_DATE()), li.amount,
                                          0))            AS revenue_90,
                                  SUM(IFF(li.gl_billing_approved_date >= DATEADD('day', -180, CURRENT_DATE()),
                                          li.amount, 0)) AS revenue_180,
                                  SUM(IFF(li.gl_billing_approved_date >= DATEADD('day', -365, CURRENT_DATE()),
                                          li.amount, 0)) AS revenue_365,
                                  SUM(IFF(li.gl_billing_approved_date >= DATE_TRUNC('month', CURRENT_DATE()), li.amount,
                                          0))            AS current_mtd,
                                  SUM(IFF(li.gl_billing_approved_date >= DATE_TRUNC('year', CURRENT_DATE()), li.amount,
                                          0))            AS current_ytd,
                                  SUM(IFF(li.gl_billing_approved_date >=
                                          DATEADD('month', -1, DATE_TRUNC('month', CURRENT_DATE())) AND
                                          li.gl_billing_approved_date <= DATEADD('month', -1, CURRENT_DATE()),
                                          li.amount, 0)) AS last_month_this_time,
                                  SUM(IFF(li.gl_billing_approved_date >=
                                          DATEADD('year', -1, DATE_TRUNC('year', CURRENT_DATE())) AND
                                          li.gl_billing_approved_date <= DATEADD('year', -1, CURRENT_DATE()), li.amount,
                                          0))            AS last_year_this_time

                             FROM analytics.public.v_line_items li

                            WHERE li.line_item_type_id IN (6, 8, 108, 109) AND li.gl_billing_approved_date >=
                                                                               DATEADD('year', -1, DATE_TRUNC('year', CURRENT_DATE()))
                            GROUP BY li.asset_id)

SELECT a.asset_id,
       dis.days_in_service,
       TRUNC(oec.oec, 2)                                 AS oec,
       TRUNC(revenue_30, 2)                              AS revenue_30,
       TRUNC(revenue_60, 2)                              AS revenue_60,
       TRUNC(revenue_90, 2)                              AS revenue_90,
       TRUNC(revenue_180, 2)                             AS revenue_180,
       TRUNC(revenue_365, 2)                             AS revenue_365,
       TRUNC(current_mtd, 2)                             AS current_mtd,
       TRUNC(current_ytd, 2)                             AS current_ytd,
       TRUNC(last_month_this_time, 2)                    AS last_month_this_time,
       TRUNC(last_year_this_time, 2)                     AS last_year_this_time,
       -- get fraction of oec unless the fraction is >= 1
       LEAST((days_in_service / 30) * oec, oec)          AS adj_oec_30,
       LEAST((days_in_service / 60) * oec, oec)          AS adj_oec_60,
       LEAST((days_in_service / 90) * oec, oec)          AS adj_oec_90,
       LEAST((days_in_service / 180) * oec, oec)         AS adj_oec_180,
       LEAST((days_in_service / 365) * oec, oec)         AS adj_oec_365,
       ROUND((revenue_30 * 365 / 30) / adj_oec_30, 2)    AS fin_util_30,
       ROUND((revenue_60 * 365 / 60) / adj_oec_60, 2)    AS fin_util_60,
       ROUND((revenue_90 * 365 / 90) / adj_oec_90, 2)    AS fin_util_90,
       ROUND((revenue_180 * 365 / 180) / adj_oec_180, 2) AS fin_util_180,
       ROUND(revenue_365 / adj_oec_365, 2)               AS fin_util_365

  FROM es_warehouse.public.assets a
       LEFT JOIN days_in_service dis
                  ON a.asset_id = dis.asset_id
       LEFT JOIN oec
                  ON a.asset_id = oec.asset_id
       LEFT JOIN revenue rev
                  ON a.asset_id = rev.asset_id

 WHERE LEFT(a.serial_number, 2) <> 'RR' and LEFT(a.custom_name, 2) <> 'RR' and a.company_id <> 11606
--a.company_id = 1854 removing this per Andrew Lowe. Jack G 9/16/22

;;
  }

  dimension: asset_id {
    primary_key: yes
    type: number
    value_format_name: id
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: days_in_service {
    type: number
    sql: ${TABLE}."DAYS_IN_SERVICE" ;;
  }

  dimension: oec {
    type: number
    value_format_name: usd
    sql: ${TABLE}."OEC" ;;
  }

  dimension: revenue_30 {
    type: number
    value_format_name: usd_0
    drill_fields: [asset_id, fin_util_30]
    sql: ${TABLE}."REVENUE_30" ;;
  }

  dimension: revenue_60 {
    type: number
    value_format_name: usd_0
    drill_fields: [asset_id, fin_util_60]
    sql: ${TABLE}."REVENUE_60" ;;
  }

  dimension: revenue_90 {
    type: number
    value_format_name: usd_0
    drill_fields: [asset_id, fin_util_90]
    sql: ${TABLE}."REVENUE_90" ;;
  }

  dimension: revenue_180 {
    type: number
    value_format_name: usd_0
    drill_fields: [asset_id, fin_util_180]
    sql: ${TABLE}."REVENUE_180" ;;
  }

  dimension: revenue_365 {
    type: number
    value_format_name: usd_0
    drill_fields: [asset_id, fin_util_365]
    sql: ${TABLE}."REVENUE_365" ;;
  }

  dimension: current_mtd {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}."CURRENT_MTD" ;;
  }

  dimension: current_ytd {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}."CURRENT_YTD" ;;
  }

  dimension: last_month_this_time {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}."LAST_MONTH_THIS_TIME" ;;
  }

  dimension: last_year_this_time {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}."LAST_YEAR_THIS_TIME" ;;
  }

  dimension: adj_oec_30 {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}."ADJ_OEC_30" ;;
  }

  dimension: adj_oec_60 {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}."ADJ_OEC_60" ;;
  }

  dimension: adj_oec_90 {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}."ADJ_OEC_90" ;;
  }

  dimension: adj_oec_180 {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}."ADJ_OEC_180" ;;
  }

  dimension: adj_oec_365 {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}."ADJ_OEC_365" ;;
  }

  dimension: fin_util_30 {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}."FIN_UTIL_30" ;;
  }

  dimension: fin_util_60 {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}."FIN_UTIL_60" ;;
  }

  dimension: fin_util_90 {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}."FIN_UTIL_90" ;;
  }

  dimension: fin_util_180 {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}."FIN_UTIL_180" ;;
  }

  dimension: fin_util_365 {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}."FIN_UTIL_365" ;;
  }

  # - - - - - MEASURES - - - - -

  measure: asset_count {
    type: count_distinct
    drill_fields: [asset_id, asset_type_info.class, fin_util_30, fin_util_60, fin_util_90, fin_util_180, fin_util_365]
    sql: ${asset_id} ;;
  }

  measure: total_rev_30 {
    type: sum
    sql: ${revenue_30} ;;
  }

  measure: total_rev_60 {
    type: sum
    sql: ${revenue_60} ;;
  }

  measure: total_rev_90 {
    type: sum
    sql: ${revenue_90} ;;
  }

  measure: total_rev_180 {
    type: sum
    sql: ${revenue_180} ;;
  }

  measure: total_rev_365 {
    type: sum
    sql: ${revenue_365} ;;
  }

  measure: total_mtd {
    type: sum
    sql: ${current_mtd} ;;
  }

  measure: total_ytd {
    type: sum
    sql: ${current_ytd} ;;
  }

  measure: total_last_month_this_time {
    type: sum
    value_format_name: usd_0
    drill_fields: [asset_id, asset_type_info.equipment_class, asset_type_info.equipment_model, last_month_this_time, current_mtd]
    sql: ${last_month_this_time} ;;
  }

  measure: total_last_year_this_time {
    type: sum
    value_format_name: usd_0
    drill_fields: [asset_id, asset_type_info.equipment_class, asset_type_info.equipment_model, last_year_this_time, current_ytd]
    sql: ${last_year_this_time} ;;
  }

  measure: total_adj_oec_30 {
    type: sum
    value_format_name: usd_0
    drill_fields: [asset_id, asset_type_info.equipment_class, asset_type_info.equipment_model, oec, days_in_service, adj_oec_30, revenue_30, fin_util_30]
    sql: ${adj_oec_30} ;;
  }

  measure: total_adj_oec_60 {
    type: sum
    value_format_name: usd_0
    drill_fields: [asset_id, asset_type_info.equipment_class, asset_type_info.equipment_model, oec, days_in_service, adj_oec_60, revenue_60, fin_util_60]
    sql: ${adj_oec_60} ;;
  }

  measure: total_adj_oec_90 {
    type: sum
    value_format_name: usd_0
    drill_fields: [asset_id, asset_type_info.equipment_class, asset_type_info.equipment_model, oec, days_in_service, adj_oec_90, revenue_90, fin_util_90]
    sql: ${adj_oec_90} ;;
  }

  measure: total_adj_oec_180 {
    type: sum
    value_format_name: usd_0
    drill_fields: [asset_id, asset_type_info.equipment_class, asset_type_info.equipment_model, oec, days_in_service, adj_oec_180, revenue_180, fin_util_180]
    sql: ${adj_oec_180} ;;
  }

  measure: total_adj_oec_365 {
    type: sum
    value_format_name: usd_0
    drill_fields: [asset_id, asset_type_info.equipment_class, asset_type_info.equipment_model, oec, days_in_service, adj_oec_365, revenue_365, fin_util_365]
    sql: ${adj_oec_365} ;;
  }

  measure: avg_fin_util_30 {
    type: average
    value_format_name: percent_2
    drill_fields: [asset_id, asset_type_info.equipment_class, asset_type_info.equipment_model, oec, days_in_service, adj_oec_30, revenue_30, fin_util_30]
    sql: ${fin_util_30} ;;
  }

  measure: avg_fin_util_60 {
    type: average
    value_format_name: percent_2
    drill_fields: [asset_id, asset_type_info.equipment_class, asset_type_info.equipment_model, oec, days_in_service, adj_oec_60, revenue_60, fin_util_60]
    sql: ${fin_util_60} ;;
  }

  measure: avg_fin_util_90 {
    type: average
    value_format_name: percent_2
    drill_fields: [asset_id, asset_type_info.equipment_class, asset_type_info.equipment_model, oec, days_in_service, adj_oec_90, revenue_90, fin_util_90]
    sql: ${fin_util_90} ;;
  }

  measure: avg_fin_util_180 {
    type: average
    value_format_name: percent_2
    drill_fields: [asset_id, asset_type_info.equipment_class, asset_type_info.equipment_model, oec, days_in_service, adj_oec_180, revenue_180, fin_util_180]
    sql: ${fin_util_180} ;;
  }

  measure: avg_fin_util_365 {
    type: average
    value_format_name: percent_2
    drill_fields: [asset_id, asset_type_info.equipment_class, asset_type_info.equipment_model, oec, days_in_service, adj_oec_365, revenue_365, fin_util_365]
    sql: ${fin_util_365} ;;
  }


  set: util_detail {
    fields: [asset_id]
  }



}
