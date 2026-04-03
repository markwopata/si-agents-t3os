view: concur_approvers_delegates {
  derived_table: {
    sql: WITH groups AS (SELECT LOWER(APPROVER_ID)                                AS APPROVER_EMAIL,
                       LISTAGG(CONCAT(GROUP_CODE, ' - ', "GROUP"), ', ') AS GROUPS
                FROM ANALYTICS.CONCUR.INVOICE_APPROVERS
                GROUP BY APPROVER_ID)
SELECT em.EMPLOYEE_ID                     AS EMP_ID,
       ad.EMPLOYEE_NAME,
       ad.EMPLOYEE_ID                     AS EMPLOYEE_EMAIL,
       em.EMPLOYEE_TITLE                  AS EMP_TITLE,
       em.DEFAULT_COST_CENTERS_FULL_PATH  AS EMPLOYEE_COST_CENTER_FULL_PATH,
       em.DATE_HIRED                      AS EMP_DATE_HIRED,
       em.DATE_REHIRED                    AS EMP_DATE_REHIRED,
       em.DATE_TERMINATED                 AS EMP_DATE_TERMINATED,
       del.EMPLOYEE_ID                    AS DEL_ID,
       ad.DELEGATE_NAME,
       ad.DELEGATE_EMPLOYEE_ID            AS DEL_EMAIL,
       del.EMPLOYEE_TITLE                 AS DEL_TITLE,
       del.DEFAULT_COST_CENTERS_FULL_PATH AS DEL_COST_CENTER_FULL_PATH,
       del.DATE_HIRED                     AS DEL_DATE_HIRED,
       del.DATE_REHIRED                   AS DEL_DATE_REHIRED,
       del.DATE_TERMINATED                AS DEL_DATE_TERMINATED,
       groups.GROUPS                      AS APPROVER_GROUPS,
       ad.CAN_PREPARE,
       ad.CAN_SUBMIT,
       ad.CAN_APPROVE,
       ad.CAN_RECEIVE_EMAIL,
       ad.CAN_RECEIVE_APPROVAL_EMAIL,
       ad.CAN_APPROVE_TEMPORARILY
FROM ANALYTICS.CONCUR.APPROVER_DELEGATES ad
         LEFT JOIN ANALYTICS.PAYROLL.COMPANY_DIRECTORY em ON LOWER(ad.EMPLOYEE_ID) = em.WORK_EMAIL
         LEFT JOIN ANALYTICS.PAYROLL.COMPANY_DIRECTORY del ON LOWER(ad.DELEGATE_EMPLOYEE_ID) = del.WORK_EMAIL
         LEFT JOIN groups ON LOWER(ad.EMPLOYEE_ID) = groups.APPROVER_EMAIL ;;
  }

  dimension: employee_id {
    type: string
    label: "Employee ID"
    sql: ${TABLE}.EMP_ID ;;
  }

  dimension: employee_name {
    type: string
    label: "Employee Name"
    sql: ${TABLE}.EMPLOYEE_NAME ;;
  }

  dimension: employee_email {
    type: string
    label: "Employee Email"
    sql: ${TABLE}.EMPLOYEE_EMAIL ;;
  }

  dimension: employee_title {
    type: string
    label: "Employee Title"
    sql: ${TABLE}.EMP_TITLE ;;
  }

  dimension: employee_cost_center {
    type: string
    label: "Employee Cost Center"
    sql: ${TABLE}.EMPLOYEE_COST_CENTER_FULL_PATH ;;
  }

  dimension: employee_date_hired {
    type: date
    label: "Employee Hire Date"
    sql: ${TABLE}.EMP_DATE_HIRED ;;
  }

  dimension: employee_date_rehired {
    type: date
    label: "Employee Rehire Date"
    sql: ${TABLE}.EMP_DATE_REHIRED ;;
  }

  dimension: employee_date_terminated{
    type: date
    label: "Employee Term Date"
    sql: ${TABLE}.EMP_DATE_REHIRED ;;
  }

  dimension: delegate_id {
    type: string
    label: "Delegate ID"
    sql: ${TABLE}.DEL_ID ;;
  }

  dimension: delegate_name {
    type: string
    label: "Delegate Name"
    sql: ${TABLE}.DELEGATE_NAME ;;
  }

  dimension: delegate_email {
    type: string
    label: "Delegate Email"
    sql: ${TABLE}.DEL_EMAIL ;;
  }

  dimension: delegate_title {
    type: string
    label: "Delegate Title"
    sql: ${TABLE}.DEL_TITLE ;;
  }

  dimension: delegate_cost_center {
    type: string
    label: "Delegate Cost Center"
    sql: ${TABLE}.DEL_COST_CENTER_FULL_PATH ;;
  }

  dimension: delegate_date_hired {
    type: date
    label: "Delegate Hire Date"
    sql: ${TABLE}.DEL_DATE_HIRED ;;
  }

  dimension: delegate_date_rehired {
    type: date
    label: "Delegate Rehire Date"
    sql: ${TABLE}.DEL_DATE_REHIRED ;;
  }

  dimension: delegate_date_terminated {
    type: date
    label: "Delegate Term Date"
    sql: ${TABLE}.DEL_DATE_TERMINATED ;;
  }

  dimension: approver_groups {
    type: string
    label: "Approver Groups"
    sql: ${TABLE}.APPROVER_GROUPS ;;
  }

  dimension: can_prepare {
    type: string
    label: "Can Prepare"
    sql: ${TABLE}.CAN_PREPARE ;;
  }

  dimension: can_submit {
    type: string
    label: "Can Submit"
    sql: ${TABLE}.CAN_SUBMIT ;;
  }

  dimension: can_approve {
    type: string
    label: "Can Approve"
    sql: ${TABLE}.CAN_APPROVE ;;
  }

  dimension: can_receive_email {
    type: string
    label: "Can Receive Email"
    sql: ${TABLE}.CAN_RECEIVE_EMAIL ;;
  }

  dimension: can_receive_approval_email {
    type: string
    label: "Can Receive Approval Email"
    sql: ${TABLE}.CAN_RECEIVE_APPROVAL_EMAIL ;;
  }

  dimension: can_approve_temporarily {
    type: string
    label: "Can Approve Temporarily"
    sql: ${TABLE}.CAN_APPROVE_TEMPORARILY ;;
  }
}
