view: paycor_track_hours {
  derived_table: {
    sql: SELECT PRT.PAY_PERIOD_DATES_PRIOR AS PAY_PERIOD_DATES_PRIOR,
PRT.PAY_PERIOD_DATES_CURRENT AS PAY_PERIOD_DATES_CURRENT,
X.REGION_NAME AS REGION_NAME, X.DISTRICT AS DISTRICT, X.MARKET_NAME AS MARKET_NAME,
PRT.PAY_PERIOD AS PAY_PERIOD,
PRT.FULL_NAME AS EMPLOYEE_NAME,
PRT.SUB_DEPT_NAME AS SUB_DEPT_NAME, MD.MARKET_TYPE AS DEPT_NAME,
PRT.ALL_OT_HOURS AS OT_HOURS, PRT.REGULAR_HOURS AS REGULAR_HOURS, PRT.TOTAL_HOURS AS TOTAL_HOURS
FROM ANALYTICS.PAYROLL.PAYCOR_TRACK_HOURS AS PRT
INNER JOIN ANALYTICS.PAYROLL.DEPT_MAPPING_MKT_DIRECTORY AS MMD
ON PRT.DEPT_NAME = MMD.DEPT_NAME
INNER JOIN ANALYTICS.MARKET_DATA.MARKET_DIRECTORY AS MD
ON (MMD.DEPT_MAPPING = UPPER(MD.MARKET_TYPE)) AND (PRT.LOC_NAME = MD.PAYCOR_NAME) AND MD.MARKET_TYPE IS NOT NULL
INNER JOIN ANALYTICS.PUBLIC.MARKET_REGION_XWALK AS X
ON MD.MARKET_ID = X.MARKET_ID
WHERE PRT.PAY_PERIOD IN ('Current','Prior')
AND PRT.TOTAL_HOURS <> 0
AND PRT.LOC_NAME NOT IN ('COR','TOF','REM','TWH')
AND MD.MARKET_TYPE IS NOT NULL                          ;;
  }



  dimension: pay_period_dates_prior {
    type: string
    sql: ${TABLE}.PAY_PERIOD_DATES_PRIOR ;;
  }

  dimension: pay_period_dates_current {
    type: string
    sql: ${TABLE}.PAY_PERIOD_DATES_CURRENT ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}.REGION_NAME ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}.DISTRICT ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}.MARKET_NAME ;;
  }

  dimension: ot_hours {
    type: number
    sql: ${TABLE}.OT_HOURS ;;
  }

  dimension: regular_hours {
    type: number
    sql: ${TABLE}.REGULAR_HOURS ;;
  }

  dimension: total_hours {
    type: number
    sql: ${TABLE}.TOTAL_HOURS ;;
  }

  dimension: employee_name {
    type: string
    sql: ${TABLE}.EMPLOYEE_NAME    ;;
  }

  dimension: department_name {
    type: string
    sql: ${TABLE}.DEPT_NAME ;;
  }

  dimension: sub_department_name {
    type: string
    sql: ${TABLE}.SUB_DEPT_NAME ;;
  }

  dimension: pay_period {
    type: string
    sql: ${TABLE}.PAY_PERIOD ;;
  }

  measure: total_hours_prior {
    type: sum
    filters: [pay_period: "Prior"]
    sql: ${TABLE}.TOTAL_HOURS ;;
    value_format: "#,##0.#0"
  }

  measure: regular_hours_prior {
    type: sum
    filters: [pay_period: "Prior"]
    sql:  ${TABLE}.REGULAR_HOURS;;
    value_format: "#,##0.#0"
  }

  measure: overtime_hours_prior {
    type: sum
    filters: [pay_period: "Prior"]
    sql:  ${TABLE}.OT_HOURS;;
    value_format: "#,##0.#0"
  }

  measure: pct_ot_total_prior {
    type: number
    sql:case when ${total_hours_prior} = 0 and ${overtime_hours_prior} > 0 then 1
        when ${total_hours_prior} = 0 and ${overtime_hours_prior} = 0 then 0
       else ${overtime_hours_prior} / ${total_hours_prior} end ;;
    value_format: "#,##0.#0%"
    link: {
      label: "Prior Period Payroll Hours by Employee"
      url: "https://equipmentshare.looker.com/looks/217?f[paycor_track_hours.market_name]={{ paycor_track_hours.market_name._filterable_value  | url_encode }}
      &f[paycor_track_hours.pay_period]={{'Prior'  | url_encode }}&toggle=det"
    }
  }

  measure: total_hours_current {
    type: sum
    filters: [pay_period: "Current"]
    sql: ${TABLE}.TOTAL_HOURS ;;
    value_format: "#,##0.#0"
  }

  measure: regular_hours_current {
    type: sum
    filters: [pay_period: "Current"]
    sql:  ${TABLE}.REGULAR_HOURS;;
    value_format: "#,##0.#0"
  }

  measure: overtime_hours_current {
    type: sum
    filters: [pay_period: "Current"]
    sql:  ${TABLE}.OT_HOURS;;
    value_format: "#,##0.#0"
  }

  measure: pct_ot_total_current {
    type: number
    sql: case when ${total_hours_current} = 0 and ${overtime_hours_current} > 0 then 1
        when ${total_hours_current} = 0 and ${overtime_hours_current} = 0 then 0
       else ${overtime_hours_current} / ${total_hours_current} end ;;
    value_format: "#,##0.#0%"
    link: {
      label: "Current Period Payroll Hours by Employee"
      url: "https://equipmentshare.looker.com/looks/218?f[paycor_track_hours.market_name]={{ paycor_track_hours.market_name._filterable_value  | url_encode }}
      &f[paycor_track_hours.pay_period]={{'Current'  | url_encode }}&toggle=det"
    }
  }
}
