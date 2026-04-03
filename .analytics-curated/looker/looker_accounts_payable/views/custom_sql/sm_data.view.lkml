view: sm_data {
  derived_table: {
    sql:
      SELECT distinct
          MARKET_ID,
          CONCAT(FIRST_NAME, ' ', LAST_NAME) AS SERVICE_MANAGER,
          EMPLOYEE_TITLE AS SM_TITLE,
          WORK_EMAIL AS SM_WORK_EMAIL,
          WORK_PHONE AS SM_WORK_PHONE
      FROM ANALYTICS.PAYROLL.COMPANY_DIRECTORY
        WHERE EMPLOYEE_TITLE = 'Service Manager'
        AND EMPLOYEE_STATUS = 'Active'
    ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}.MARKET_ID ;;
    }

  dimension: service_manager {
    type: string
    sql: ${TABLE}.SERVICE_MANAGER ;;
    }

  dimension: sm_title {
    type: string
    sql: ${TABLE}.SM_TITLE ;;
    }

  dimension: sm_work_email {
    type: string
    sql: ${TABLE}.SM_WORK_EMAIL ;;
    }

  dimension: sm_work_phone {
    type: string
    sql: ${TABLE}.SM_WORK_PHONE ;;
    }

}
