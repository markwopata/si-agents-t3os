view: active_employee_orgchart {
  derived_table: {
    sql: WITH DIRECTREPORTS (MANAGERID, EMPLOYEEID, EMPLOYEENAME, TITLE, DEPTID, LEVEL)
      AS
      (
      -- Top Level Employees
          SELECT
              CASE WHEN e.DIRECT_MANAGER_EMPLOYEE_ID = e.EMPLOYEE_ID THEN '-' ELSE e.DIRECT_MANAGER_EMPLOYEE_ID END AS "MANAGER_EMPLOYEE_NUMBER",
              e.EMPLOYEE_ID as EMPLOYEE_NUMBER,
              concat(e.first_name,' ',e.last_name) as EMPLOYEE,
              e.EMPLOYEE_TITLE,
              split_part(e.default_cost_centers_full_path,'/',3) as DEPARTMENT_NAME,
              0 AS LEVEL
          FROM "analytics"."payroll"."company_directory" AS e
          WHERE e.MANAGER_EMPLOYEE_NUMBER = e.EMPLOYEE_NUMBER AND e.ACTIVE = true
          UNION ALL
      -- Subordinate Employees
          SELECT
              e.DIRECT_MANAGER_EMPLOYEE_ID as MANAGER_EMPLOYEE_NUMBER,
              e.EMPLOYEE_ID as EMPLOYEE_NUMBER,
              concat(e.first_name,' ',e.last_name) as EMPLOYEE,
              e.EMPLOYEE_TITLE,
              split_part(e.default_cost_centers_full_path,'/',3) as DEPARTMENT_NAME,
              LEVEL + 1
          FROM "analytics"."payroll"."company_directory" AS e
          JOIN DIRECTREPORTS AS d
              ON e.MANAGER_EMPLOYEE_NUMBER = d.EMPLOYEEID
          WHERE e.MANAGER_EMPLOYEE_NUMBER != e.EMPLOYEE_NUMBER AND e.ACTIVE = true
      )
      -- Executes the CTE
      SELECT MANAGERID, EMPLOYEEID, EMPLOYEENAME, TITLE, DEPTID, LEVEL
      FROM DIRECTREPORTS
      --WHERE DeptID = 'Information Services' OR Level = 0
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: managerid {
    type: string
    sql: ${TABLE}."MANAGERID" ;;
  }

  dimension: employeeid {
    type: string
    sql: ${TABLE}."EMPLOYEEID" ;;
  }

  dimension: employeename {
    type: string
    sql: ${TABLE}."EMPLOYEENAME" ;;
  }

  dimension: title {
    type: string
    sql: ${TABLE}."TITLE" ;;
  }

  dimension: deptid {
    type: string
    sql: ${TABLE}."DEPTID" ;;
  }

  dimension: level {
    type: number
    sql: ${TABLE}."LEVEL" ;;
  }

  set: detail {
    fields: [
      managerid,
      employeeid,
      employeename,
      title,
      deptid,
      level
    ]
  }
}
