view: employee_details_lookup_data {
  derived_table: {
    sql:
      SELECT distinct
          EMPLOYEE_ID,
          CONCAT(FIRST_NAME, ' ', LAST_NAME) AS FULL_NAME,
          WORK_EMAIL,
          WORK_PHONE
      FROM ANALYTICS.PAYROLL.COMPANY_DIRECTORY
      WHERE EMPLOYEE_STATUS = 'Active'
    ;;
  }

  dimension: employee_id {
    type: string
    sql: ${TABLE}.EMPLOYEE_ID ;;
    }

  dimension: escalation_contact {
    type: string
    sql: ${TABLE}.FULL_NAME ;;
    }

  dimension: escalation_email {
    type: string
    sql: ${TABLE}.WORK_EMAIL ;;
    }

  dimension: escalation_phone {
    type: string
    sql: ${TABLE}.WORK_PHONE ;;
    }

}
