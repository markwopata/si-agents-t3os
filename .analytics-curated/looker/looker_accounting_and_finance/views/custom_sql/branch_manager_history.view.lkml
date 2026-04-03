view: branch_manager_history {
  derived_table: {
    sql: WITH RECURSIVE DepartmentHierarchy AS (
  -- Anchor: top-level departments (Regions or roots)
  SELECT
    d.RECORDNO         AS department_recordno,
    d.DEPARTMENTID     AS market_id,
    d.TITLE            AS market_name,
    d.STATUS           AS sage_status,
    d.DEPARTMENT_TYPE,
    d.PARENTKEY        AS parent_id,
    CAST(NULL AS VARCHAR) AS region,
    CAST(NULL AS VARCHAR) AS district,
    1                  AS level,
    d.TITLE            AS path
  FROM ANALYTICS.INTACCT.DEPARTMENT d
  WHERE d.PARENTKEY IS NULL
    AND d.STATUS != 'inactive'

  UNION ALL

  -- Recursive members (build tree)
  SELECT
    d1.RECORDNO,
    d1.DEPARTMENTID,
    d1.TITLE,
    d1.STATUS,
    d1.DEPARTMENT_TYPE,
    d1.PARENTKEY,
    CASE WHEN d1.DEPARTMENT_TYPE = 'Region' THEN d1.TITLE ELSE dh.region END,
    CASE WHEN d1.DEPARTMENT_TYPE = 'District' THEN d1.TITLE ELSE dh.district END,
    dh.level + 1,
    dh.path || '/' || d1.TITLE
  FROM ANALYTICS.INTACCT.DEPARTMENT d1
  JOIN DepartmentHierarchy dh
    ON d1.PARENTKEY = dh.department_recordno
  WHERE d1.STATUS != 'inactive'
),

-- 1) Pull only the latest row per person by POSITION_EFFECTIVE_DATE
current_job_per_user AS (
  SELECT
    cd.*,
    ROW_NUMBER() OVER (
      PARTITION BY cd.EMPLOYEE_ID
      ORDER BY cd.POSITION_EFFECTIVE_DATE DESC NULLS LAST
    ) AS rn
  FROM ANALYTICS.PAYROLL.COMPANY_DIRECTORY cd
  QUALIFY rn = 1
),

-- 2) Filter that latest row down to just your manager titles
Employees AS (
  SELECT
    cu.EMPLOYEE_ID,
    cu.FIRST_NAME || ' ' || cu.LAST_NAME AS employee_name,
    cu.EMPLOYEE_TITLE,
    cu.EMPLOYEE_STATUS,
    cu.MARKET_ID,
    COALESCE(
      GREATEST(CAST(cu.DATE_REHIRED AS DATE), CAST(cu.DATE_HIRED AS DATE)),
      CAST(cu.DATE_REHIRED AS DATE),
      CAST(cu.DATE_HIRED AS DATE)
    ) AS effective_hire_date,
    CASE
      WHEN cu.DATE_TERMINATED
         > COALESCE(
             GREATEST(CAST(cu.DATE_REHIRED AS DATE), CAST(cu.DATE_HIRED AS DATE)),
             CAST(cu.DATE_REHIRED AS DATE),
             CAST(cu.DATE_HIRED AS DATE)
           )
      THEN CAST(cu.DATE_TERMINATED AS DATE)
      ELSE NULL
    END AS final_date_terminated,
    cu.DIRECT_MANAGER_NAME        AS direct_manager_name,
    cu.DIRECT_MANAGER_EMPLOYEE_ID AS direct_manager_employee_id
  FROM current_job_per_user cu
  WHERE cu.EMPLOYEE_TITLE ILIKE '%General%Manager%'
     OR cu.EMPLOYEE_TITLE ILIKE '%District%Manager%'
     OR cu.EMPLOYEE_TITLE ILIKE '%Region%Manager%'
),

-- 3) Attach every branch to its (current) managers
EmployeeDepartments AS (
  SELECT
    dh.department_recordno,
    dh.market_id,
    dh.market_name,
    dh.department_type,
    dh.region,
    dh.district,
    dh.level,
    dh.path,
    e.EMPLOYEE_ID,
    e.employee_name,
    e.EMPLOYEE_TITLE,
    e.EMPLOYEE_STATUS,
    e.effective_hire_date,
    e.final_date_terminated,
    e.direct_manager_name,
    e.direct_manager_employee_id
  FROM DepartmentHierarchy dh
  LEFT JOIN Employees e
    ON TRY_TO_NUMBER(dh.market_id) = e.MARKET_ID
)

-- 4) Final output, including each direct manager’s key, name, status and title
SELECT
  ed.department_recordno    AS id,
  ed.market_id,
  ed.market_name,
  ed.department_type,
  ed.region,
  ed.district,
  ed.level,
  ed.path,
  ed.EMPLOYEE_ID            AS employee_id,
  ed.employee_name,
  ed.employee_title,
  ed.employee_status,
  ed.effective_hire_date,
  ed.final_date_terminated,
  ed.direct_manager_employee_id AS manager_employee_id,
  ed.direct_manager_name        AS manager_name,
  mgr.EMPLOYEE_STATUS           AS manager_status,
  mgr.EMPLOYEE_TITLE            AS manager_title
FROM EmployeeDepartments ed
LEFT JOIN ANALYTICS.PAYROLL.COMPANY_DIRECTORY mgr
  ON mgr.EMPLOYEE_ID = ed.direct_manager_employee_id
ORDER BY
  ed.path,
  ed.employee_title,
  ed.employee_name
 ;;
  }

dimension: market_id {
  type: string
  label: "Market ID"
  sql: ${TABLE}.market_id ;;
}

dimension: market_name {
  type: string
  label: "Market Name"
  sql: ${TABLE}.market_name ;;
}

dimension: region {
  type: string
  label: "Region"
  sql: ${TABLE}.region ;;
}

dimension: district {
  type: string
  label: "District"
  sql: ${TABLE}.district ;;
}

dimension: level {
  type: number
  label: "Hierarchy Level"
  sql: ${TABLE}.level ;;
}

dimension: path {
  type: string
  label: "Full Path"
  sql: ${TABLE}.path ;;
}

dimension: employee_name {
  type: string
  label: "Employee Name"
  sql: ${TABLE}.employee_name ;;
}

dimension: employee_title {
  type: string
  label: "Employee Title"
  sql: ${TABLE}.employee_title ;;
}

dimension: employee_status {
  type: string
  label: "Employee Status"
  sql: ${TABLE}.employee_status ;;
}

dimension: effective_hire_date {
  type: date
  label: "Effective Hire Date"
  sql: ${TABLE}.effective_hire_date ;;
}

dimension: final_date_terminated {
  type: date
  label: "Final Termination Date"
  sql: ${TABLE}.final_date_terminated ;;
}

dimension: manager_name {
  type: string
  label: "Direct Manager Name"
  sql: ${TABLE}.manager_name ;;
}

dimension: manager_title {
  type: string
  label: "Direct Manager Title"
  sql: ${TABLE}.manager_title ;;
}

  dimension: employee_id {
    type: number
    label: "Employee ID"
    sql: ${TABLE}.employee_id ;;
  }

  dimension: manager_employee_id {
    type: number
    label: "Direct Manager Employee ID"
    sql: ${TABLE}.manager_employee_id ;;
  }

  dimension: department_type {
    type: string
    label: "Department Type"
    sql: ${TABLE}.department_type ;;
  }

  dimension: manager_status {
    type: string
    label: "Direct Manager Status"
    sql: ${TABLE}.manager_status ;;
  }
}
