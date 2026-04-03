view: concur_user_permissions {
  derived_table: {
    sql:
WITH current_job_per_user AS (
  SELECT *,
    ROW_NUMBER() OVER (
      PARTITION BY WORK_EMAIL
      ORDER BY POSITION_EFFECTIVE_DATE DESC NULLS LAST
    ) AS RN
  FROM ANALYTICS.PAYROLL.COMPANY_DIRECTORY
  QUALIFY RN = 1
)

SELECT
    cd.EMPLOYEE_ID,
    er.EMPLOYEE_NAME,
    cd.EMPLOYEE_TITLE AS WORKDAY_TITLE,
    cd.DIRECT_MANAGER_NAME AS MANAGER_NAME,
    cd.DEFAULT_COST_CENTERS_FULL_PATH AS EMPLOYEE_COST_CENTER_FULL_PATH,
    CASE
        WHEN SPLIT_PART(cd.DEFAULT_COST_CENTERS_FULL_PATH, '/', -1) = 'Administrative'
        THEN SPLIT_PART(cd.DEFAULT_COST_CENTERS_FULL_PATH, '/', -2)
        ELSE SPLIT_PART(cd.DEFAULT_COST_CENTERS_FULL_PATH, '/', -1)
    END AS COST_CENTER_NAME,
    er.ROLE AS EMPLOYEE_ROLE,
COALESCE(
  GREATEST(CAST(DATE_REHIRED AS DATE), CAST(DATE_HIRED AS DATE)),
  CAST(DATE_REHIRED AS DATE),
  CAST(DATE_HIRED AS DATE)
)                                                                     AS EFFECTIVE_HIRE_DATE,
    CAST(
        CASE
            WHEN DATE_TERMINATED > GREATEST(CAST(DATE_REHIRED AS DATE), CAST(DATE_HIRED AS DATE))
            THEN DATE_TERMINATED
            ELSE NULL
        END AS DATE
    ) AS FINAL_DATE_TERMINATED,
    CAST(er.TERMINATION_DATE AS DATE) AS CONCUR_TERMINATION_DATE,
    CAST(er.LAST_LOGIN_DATE AS DATE) AS LAST_LOGIN_DATE,
    cd.EMPLOYEE_STATUS,
    er.EMPLOYEE_EMAIL,
    CASE
        WHEN er.ACTIVE = 'Y' THEN 'Active'
        WHEN er.ACTIVE = 'N' THEN 'Inactive'
        ELSE NULL
    END AS CONCUR_STATUS
FROM ANALYTICS.CONCUR.EMPLOYEE_ROLES er
LEFT JOIN current_job_per_user cd
  ON LOWER(cd.WORK_EMAIL) = LOWER(er.EMPLOYEE_EMAIL)
            ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

 dimension: employee_id {
  type: string
  sql: ${TABLE}.EMPLOYEE_ID ;;
}

dimension: employee_name {
  type: string
  sql: ${TABLE}.EMPLOYEE_NAME ;;
}

dimension: workday_title {
  type: string
  sql: ${TABLE}.WORKDAY_TITLE ;;
}

dimension: manager_name {
  type: string
  sql: ${TABLE}.MANAGER_NAME ;;
}

dimension: employee_cost_center_full_path {
  type: string
  sql: ${TABLE}.EMPLOYEE_COST_CENTER_FULL_PATH ;;
}

dimension: cost_center_name {
  type: string
  sql: ${TABLE}.COST_CENTER_NAME ;;
}

dimension: employee_role {
  type: string
  sql: ${TABLE}.EMPLOYEE_ROLE ;;
}

dimension: effective_hire_date {
  type: date
  sql: ${TABLE}.EFFECTIVE_HIRE_DATE ;;
}

dimension: final_date_terminated {
  type: date
  sql: ${TABLE}.FINAL_DATE_TERMINATED ;;
}

dimension: concur_termination_date {
  type: date
  sql: ${TABLE}.CONCUR_TERMINATION_DATE ;;
}

dimension: last_login_date {
  type: date
  sql: ${TABLE}.LAST_LOGIN_DATE ;;
}

dimension: employee_status {
  type: string
  sql: ${TABLE}.EMPLOYEE_STATUS ;;
}

dimension: employee_email {
  type: string
  sql: ${TABLE}.EMPLOYEE_EMAIL ;;
}

dimension: concur_status {
  type: string
  sql: ${TABLE}.CONCUR_STATUS ;;
}

set: detail {
  fields: [
    employee_id,
    employee_name,
    workday_title,
    manager_name,
    employee_cost_center_full_path,
    cost_center_name,
    employee_role,
    effective_hire_date,
    final_date_terminated,
    concur_termination_date,
    last_login_date,
    employee_status,
    employee_email,
    concur_status
  ]
}
}
