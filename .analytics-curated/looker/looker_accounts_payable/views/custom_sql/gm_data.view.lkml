view: gm_data {
  derived_table: {
    sql:
      SELECT distinct
          MARKET_ID,
          EMPLOYEE_ID,
          DIRECT_MANAGER_EMPLOYEE_ID,
          CONCAT(FIRST_NAME, ' ', LAST_NAME) AS GENERAL_MANAGER,
          EMPLOYEE_TITLE AS GM_TITLE,
          WORK_EMAIL AS GM_WORK_EMAIL,
          WORK_PHONE AS GM_WORK_PHONE
      FROM ANALYTICS.PAYROLL.COMPANY_DIRECTORY
        WHERE EMPLOYEE_TITLE = 'General Manager'
        AND EMPLOYEE_STATUS = 'Active'
    ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}.MARKET_ID ;;
    }

  dimension: employee_id {
    type: string
    sql: ${TABLE}.EMPLOYEE_ID ;;
    }

  dimension: direct_manager_employee_id {
    type: string
    sql: ${TABLE}.DIRECT_MANAGER_EMPLOYEE_ID ;;
    }

  dimension: general_manager {
    type: string
    sql: ${TABLE}.GENERAL_MANAGER ;;
    }

  dimension: gm_title {
    type: string
    sql: ${TABLE}.GM_TITLE ;;
    }

  dimension: gm_work_email {
    type: string
    sql: ${TABLE}.GM_WORK_EMAIL ;;
    }

  dimension: gm_work_phone {
    type: string
    sql: ${TABLE}.GM_WORK_PHONE ;;
    }

}
