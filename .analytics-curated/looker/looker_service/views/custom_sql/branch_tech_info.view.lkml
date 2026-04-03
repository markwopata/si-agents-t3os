view: branch_tech_info {
  derived_table: {
    sql:
      SELECT DISTINCT
        CONCAT(cd.FIRST_NAME, ' ', cd.LAST_NAME) AS full_name,
        cd.EMPLOYEE_TITLE,
        cd.EMPLOYEE_STATUS,
        cd.DATE_TERMINATED,
        cd.PAY_CALC,
        cd.EMPLOYEE_ID,
        xwalk.MARKET_ID,
        u.USER_ID
      FROM ANALYTICS.PAYROLL.COMPANY_DIRECTORY AS cd
      LEFT JOIN ANALYTICS.PUBLIC.MARKET_REGION_XWALK AS xwalk ON cd.MARKET_ID = xwalk.MARKET_ID
      LEFT JOIN ES_WAREHOUSE.PUBLIC.USERS AS u ON cd.EMPLOYEE_ID::string = u.EMPLOYEE_ID::string
      LEFT JOIN ES_WAREHOUSE.TIME_TRACKING.TIME_ENTRIES AS te ON u.USER_ID = te.USER_ID
      WHERE xwalk.MARKET_ID = 109984 AND cd.EMPLOYEE_STATUS NOT IN ('Terminated', 'Inactive')
      ;;
  }

  dimension: full_name {
    type: string
    sql: ${TABLE}.full_name ;;
  }

  dimension: employee_title {
    type: string
    sql: ${TABLE}.EMPLOYEE_TITLE ;;
  }

  dimension: employee_status {
    type: string
    sql: ${TABLE}.EMPLOYEE_STATUS ;;
  }

  dimension: date_terminated {
    type: date
    sql: ${TABLE}.DATE_TERMINATED ;;
  }

  dimension: pay_calc {
    type: string
    sql: ${TABLE}.PAY_CALC ;;
  }

  dimension: employee_id {
    type: string
    sql: ${TABLE}.EMPLOYEE_ID ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}.MARKET_ID ;;
  }

  dimension: user_id {
    type: string
    sql: ${TABLE}.USER_ID ;;
  }

  # Add more dimensions or measures as needed!
}
