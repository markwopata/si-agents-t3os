view: quarterly_ar_slt {
  derived_table: {
    sql: WITH AR_CTE AS (SELECT MONTH::DATE AS QUARTER, TTM_REVENUE, TTM_REVENUE_GROWTH_QTR,
TOTAL_AR, TOTAL_AR_GROWTH_QTR ,  TOTAL_AR_V_REV_GROWTH_QTR ,
CURRENT_AR, CURRENT_AR_GROWTH_QTR , CURRENT_AR_V_REV_GROWTH_QTR,
PD_AR, PD_AR_GROWTH_QTR , PD_AR_V_REV_GROWTH_QTR ,
TOTAL_DSO, CURRENT_DSO, PD_DSO
FROM ANALYTICS.TREASURY.AR_METRICS_DASHBOARD
WHERE BRANCH_ID = 9999
AND QUARTER IN ('2022-12-31','2023-03-31','2023-06-30','2023-09-30')),
COLLECT_CTE AS (
SELECT DATEADD(DAY,-1,DATEADD(QUARTER,1,DATE_TRUNC(QUARTER,MONTH)))::DATE AS QUARTER,
SUM(COLLECTIONS) AS COLLECTIONS, SUM(COLLECTIONS)/91.25 AS COLLECTIONS_PER_DAY
FROM ANALYTICS.TREASURY.AR_METRICS_DASHBOARD
WHERE BRANCH_ID = 9999
AND QUARTER BETWEEN '2022-10-31' AND '2023-09-30'
GROUP BY QUARTER)
SELECT A.*, C.COLLECTIONS, C.COLLECTIONS_PER_DAY
FROM AR_CTE AS A
INNER JOIN COLLECT_CTE AS C ON A.QUARTER = C.QUARTER
                ;;
  }


  dimension: quarter {
    type: string
    sql: ${TABLE}.QUARTER ;;
  }

  measure: ttm_revenue {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}.TTM_REVENUE ;;
  }

  measure: ttm_revenue_growth {
    type: sum
    value_format_name: percent_0
    sql: ${TABLE}.TTM_REVENUE_GROWTH_QTR ;;
  }

  measure: total_ar {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}.TOTAL_AR ;;
  }


  measure: total_ar_growth {
    type: sum
    value_format_name: percent_0
    sql: ${TABLE}.TOTAL_AR_GROWTH_QTR ;;
  }

  measure: total_ar_v_rev_growth {
    type: sum
    value_format_name: percent_0
    sql: ${TABLE}.TOTAL_AR_V_REV_GROWTH_QTR ;;
  }


  measure: current_ar {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}.CURRENT_AR ;;
  }

  measure: current_ar_growth {
    type: sum
    value_format_name: percent_0
    sql: ${TABLE}.CURRENT_AR_GROWTH_QTR ;;
  }

  measure: current_ar_v_rev_growth {
    type: sum
    value_format_name: percent_0
    sql: ${TABLE}.CURRENT_AR_V_REV_GROWTH_QTR ;;
  }

  measure: pd_ar {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}.PD_AR ;;
  }

  measure: pd_ar_growth {
    type: sum
    value_format_name: percent_0
    sql: ${TABLE}.PD_AR_GROWTH_QTR ;;
  }

  measure: pd_ar_v_rev_growth {
    type: sum
    value_format_name: percent_0
    sql: ${TABLE}.PD_AR_V_REV_GROWTH_QTR ;;
  }

  measure: total_dso {
    type: sum
    value_format_name: decimal_0
    sql: ${TABLE}.TOTAL_DSO ;;
  }

  measure: current_dso {
    type: sum
    value_format_name: decimal_0
    sql: ${TABLE}.CURRENT_DSO ;;
  }

  measure: pd_dso {
    type: sum
    value_format_name: decimal_0
    sql: ${TABLE}.PD_DSO ;;
  }


  measure: collections {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}.COLLECTIONS ;;
  }

  measure: collections_per_day {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}.COLLECTIONS_PER_DAY ;;
  }



  }
