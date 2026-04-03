view: paycor_track_combined_hours {
  derived_table: {
    sql:   --TIME TRACKING FOR OT DASHBOARD
SELECT  '2/8/2021 - 2/21/2021' AS PAY_PERIOD_DATES_PRIOR , '2/22/2021 - 3/7/2021' AS PAY_PERIOD_DATES_CURRENT,
U.EMPLOYEE_ID AS EMPLOYEE_NUMBER, U.FIRST_NAME AS EMPLOYEE_FIRST_NAME, U.LAST_NAME AS EMPLOYEE_LAST_NAME,
SUM(OVERTIME_HOURS) AS OT_HOURS, SUM(REGULAR_HOURS - OVERTIME_HOURS) AS REGULAR_HOURS, SUM(REGULAR_HOURS) AS TOTAL_HOURS,
CASE WHEN START_DATE::DATE BETWEEN '2/8/2021' AND '2/21/2021' THEN 'Prior'
WHEN START_DATE BETWEEN '2/22/2021' AND '3/7/2021' THEN 'Current' END AS PAY_PERIOD,
PEM.LOC_NAME AS LOC_NAME, PEM.DEPT_NAME AS DEPT_NAME, PEM.FULL_MANAGER_NAME AS MANAGER_NAME
FROM ES_WAREHOUSE.TIME_TRACKING.ENTRY_RECORDS AS TTE
INNER JOIN ES_WAREHOUSE.PUBLIC.USERS AS U
ON TTE.USER_ID = U.USER_ID
INNER JOIN ANALYTICS.PUBLIC.PAYCOR_EMPLOYEES_MANAGERS AS PEM
ON U.EMPLOYEE_ID::VARCHAR = PEM.EMPLOYEE_NUMBER::VARCHAR
WHERE EVENT_TYPE_ID = 1 AND APPROVAL_STATUS = 'Approved'
AND START_DATE::DATE BETWEEN '2/8/2021' AND '3/7/2021'
AND U.COMPANY_ID IN (1854,1855)
AND LOWER(U.EMAIL_ADDRESS) NOT LIKE '%suspended%'
GROUP BY  U.EMPLOYEE_ID, U.FIRST_NAME, U.LAST_NAME,
CASE WHEN START_DATE::DATE BETWEEN '2/8/2021' AND '2/21/2021' THEN 'Prior'
WHEN START_DATE BETWEEN '2/22/2021' AND '3/7/2021' THEN 'Current' END,
PEM.LOC_NAME, PEM.DEPT_NAME, PEM.FULL_MANAGER_NAME
UNION ALL
SELECT '2/8/2021 - 2/21/2021' AS PAY_PERIOD_DATES_PRIOR , '2/22/2021 - 3/7/2021' AS PAY_PERIOD_DATES_CURRENT,
EMPLOYEE_NUMBER AS EMPLOYEE_NUMBER, EMPLOYEE_FIRST_NAME AS EMPLOYEE_FIRST_NAME,
EMPLOYEE_LAST_NAME AS EMPLOYEE_LAST_NAME, CASE WHEN EARNING_CODE IN ('OT','9-Double T') THEN SUM(HOURS) ELSE 0 END AS OT_HOURS,
CASE WHEN EARNING_CODE NOT IN ('OT','9-Double T') THEN SUM(HOURS) ELSE 0 END AS REGULAR_HOURS,
SUM(HOURS) AS TOTAL_HOURS, PAY_PERIOD_FILTER AS PAY_PERIOD, LOC_NAME AS LOC_NAME, DEPT_NAME AS DEPT_NAME,
MANAGER_NAME AS MANAGER_NAME
FROM ANALYTICS.PAYROLL.PRTEST_DETAIL
WHERE PAY_PERIOD_FILTER IN ('Current','Prior')
GROUP BY EMPLOYEE_NUMBER , EMPLOYEE_FIRST_NAME, EMPLOYEE_LAST_NAME, EARNING_CODE, PAY_PERIOD_FILTER,
LOC_NAME, DEPT_NAME, MANAGER_NAME
                       ;;
  }



  dimension: pay_period_dates_prior {
    type: string
    sql: ${TABLE}.PAY_PERIOD_DATES_PRIOR ;;
  }

  dimension: pay_period_dates_current {
    type: string
    sql: ${TABLE}.PAY_PERIOD_DATES_CURRENT ;;
  }

  dimension: employee_number {
    type: string
    sql: ${TABLE}.EMPLOYEE_NUMBER ;;
  }

  dimension: employee_first_name {
    type: string
    sql: ${TABLE}.EMPLOYEE_FIRST_NAME ;;
  }

  dimension: employee_last_name {
    type: string
    sql: ${TABLE}.EMPLOYEE_LAST_NAME ;;
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

  dimension: pay_period {
    type: string
    sql: ${TABLE}.PAY_PERIOD ;;
  }

  dimension: loc_name {
    type: string
    sql: ${TABLE}.LOC_NAME ;;
  }

  dimension: dept_name   {
    type: string
    sql: ${TABLE}.DEPT_NAME ;;
  }

  dimension: manager_name {
    type: string
    sql: ${TABLE}.MANAGER_NAME ;;
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
      url: "https://equipmentshare.looker.com/looks/220?f[market_region_xwalk.market_name]={{ market_region_xwalk.market_name._filterable_value  | url_encode }}
      &f[paycor_track_combined_hours.pay_period]={{'Prior'  | url_encode }}&toggle=det"
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
      url: "https://equipmentshare.looker.com/looks/219?f[market_region_xwalk.market_name]={{ market_region_xwalk.market_name._filterable_value  | url_encode }}
      &f[paycor_track_combined_hours.pay_period]={{'Current'  | url_encode }}&toggle=det"
    }
  }


}
