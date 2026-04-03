view: paycor_hours_new {
  derived_table: {
    sql: SELECT PRT.PAY_PERIOD_DATES_PRIOR AS PAY_PERIOD_DATES_PRIOR, PRT.PAY_PERIOD_DATES_CURRENT AS PAY_PERIOD_DATES_CURRENT,
    X.REGION_NAME AS REGION_NAME, X.DISTRICT AS DISTRICT, X.MARKET_NAME AS MARKET_NAME, PRT.PAY_PERIOD_FILTER AS PAY_PERIOD_FILTER, PRT.EARNING_CODE AS EARNING_CODE,
     PRT.EMPLOYEE_FIRST_NAME AS FIRST_NAME, PRT.EMPLOYEE_LAST_NAME AS LAST_NAME, PRT.SUB_DEPT_NAME AS SUB_DEPT_NAME, MD.MARKET_TYPE AS DEPT_NAME, PRT.HOURS AS HOURS
FROM ANALYTICS.PAYROLL.PRTEST_DETAIL AS PRT
INNER JOIN ANALYTICS.PAYROLL.DEPT_MAPPING_MKT_DIRECTORY AS MMD
ON PRT.DEPT_NAME = MMD.DEPT_NAME
INNER JOIN ANALYTICS.MARKET_DATA.MARKET_DIRECTORY AS MD
ON (MMD.DEPT_MAPPING = UPPER(MD.MARKET_TYPE)) AND (PRT.LOC_NAME = MD.PAYCOR_NAME) AND MD.MARKET_TYPE IS NOT NULL
INNER JOIN ANALYTICS.PUBLIC.MARKET_REGION_XWALK AS X
ON MD.MARKET_ID = X.MARKET_ID
WHERE PRT.PAY_PERIOD_FILTER IN ('Current','Prior')
AND PRT.HOURS <> 0
AND PRT.LOC_NAME NOT IN ('COR','TOF','REM','TWH')
AND MD.MARKET_TYPE IS NOT NULL                           ;;
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

  dimension: hours {
    type: number
    sql: ${TABLE}.HOURS ;;
  }

  dimension: earning_code {
    type: string
    sql: ${TABLE}.EARNING_CODE ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}.FIRST_NAME ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}.LAST_NAME ;;
  }

  dimension: employee_name {
    type: string
    sql: CONCAT(${first_name}, ' ', ${last_name})   ;;
  }

  dimension: department_name {
    type: string
    sql: ${TABLE}.DEPT_NAME ;;
  }

  dimension: sub_department_name {
    type: string
    sql: ${TABLE}.SUB_DEPT_NAME ;;
  }

  dimension: pay_period_filter {
    type: string
    sql: ${TABLE}.PAY_PERIOD_FILTER ;;
  }

  measure: total_hours_prior {
    type: sum
    filters: [pay_period_filter: "Prior"]
    sql: ${TABLE}.HOURS ;;
    value_format: "#,##0.#0"
  }

  measure: regular_hours_prior {
    type: sum
    filters: [earning_code: "Reg",pay_period_filter: "Prior"]
    sql:  ${TABLE}.HOURS;;
    value_format: "#,##0.#0"
  }

  measure: overtime_hours_prior {
    type: sum
    filters: [earning_code : "OT, 9-Double T",pay_period_filter: "Prior"]
    sql:  ${TABLE}.HOURS;;
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
      url: "https://equipmentshare.looker.com/looks/192?f[paycor_hours_new.market_name]={{_filters['paycor_hours_new.market_name']  | url_encode }}
      &f[paycor_hours_new.region_name]={{_filters['paycor_hours_new.region_name']  | url_encode }}
      &f[paycor_hours_new.district]={{_filters['paycor_hours_new.district']  | url_encode }}
      &f[paycor_hours_new.department_name]={{_filters['paycor_hours_new.department_name']  | url_encode }}
      &f[paycor_hours_new.sub_department_name]={{_filters['paycor_hours_new.sub_department_name']  | url_encode }}
      &f[paycor_hours_new.pay_period_filter]={{'Prior'  | url_encode }}&toggle=det"
    }
  }

  measure: total_hours_current {
    type: sum
    filters: [pay_period_filter: "Current"]
    sql: ${TABLE}.HOURS ;;
    value_format: "#,##0.#0"
  }

  measure: regular_hours_current {
    type: sum
    filters: [earning_code: "Reg",pay_period_filter: "Current"]
    sql:  ${TABLE}.HOURS;;
    value_format: "#,##0.#0"
  }

  measure: overtime_hours_current {
    type: sum
    filters: [earning_code : "OT, 9-Double T",pay_period_filter: "Current"]
    sql:  ${TABLE}.HOURS;;
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
      url: "https://equipmentshare.looker.com/looks/193?f[paycor_hours_new.market_name]={{ _filters['paycor_hours_new.market_name'] | url_encode }}
      &f[paycor_hours_new.region_name]={{_filters['paycor_hours_new.region_name']  | url_encode }}
      &f[paycor_hours_new.district]={{_filters['paycor_hours_new.district']  | url_encode }}
      &f[paycor_hours_new.department_name]={{_filters['paycor_hours_new.department_name']  | url_encode }}
      &f[paycor_hours_new.sub_department_name]={{_filters['paycor_hours_new.sub_department_name']  | url_encode }}
      &f[paycor_hours_new.pay_period_filter]={{'Current'  | url_encode }}&toggle=det"
    }
  }
  }
