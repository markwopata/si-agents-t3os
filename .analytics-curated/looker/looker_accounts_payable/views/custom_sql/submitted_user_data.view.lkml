view: submitted_user_data {
  derived_table: {
    sql:
      SELECT DISTINCT
          CAST(U.USER_ID AS VARCHAR) AS USER_ID,
          CONCAT(CD.FIRST_NAME, ' ', CD.LAST_NAME) AS SUBMITTED_USER_NAME,
          CD.WORK_EMAIL AS SUBMITTED_USER_EMAIL
      FROM
          ES_WAREHOUSE.PUBLIC.USERS AS U
      LEFT JOIN
          ANALYTICS.PAYROLL.COMPANY_DIRECTORY AS CD ON CAST(U.EMPLOYEE_ID AS VARCHAR) = CAST(CD.EMPLOYEE_ID AS VARCHAR)
      WHERE
          CD.EMPLOYEE_STATUS = 'Active'
    ;;
  }

  dimension: user_id {
    type: string
    sql: ${TABLE}.USER_ID ;;
    }

  dimension: submitted_user_name {
    type: string
    sql: ${TABLE}.SUBMITTED_USER_NAME ;;
    }

  dimension: submitted_user_email {
    type: string
    sql: ${TABLE}.SUBMITTED_USER_EMAIL ;;
    }

}
