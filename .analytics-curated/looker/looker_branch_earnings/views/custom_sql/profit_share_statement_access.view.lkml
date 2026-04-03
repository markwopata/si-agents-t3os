view: profit_share_statement_access {
  derived_table: {
    sql: WITH RECURSIVE
    directory AS (
        SELECT cd.first_name,
               cd.last_name,
               cd.employee_title,
               cd.employee_id,
               cd.work_email,
               IFF(cd.employee_id = 103, NULL, cd.direct_manager_employee_id) AS manager_id,
               m.work_email                                                   AS manager_email
        FROM analytics.payroll.company_directory cd
                 INNER JOIN analytics.payroll.company_directory m
                            ON cd.direct_manager_employee_id = m.employee_id
        --WHERE cd.date_terminated IS NULL
        ),
    managers AS (
        SELECT ''                                    AS manager_list,
               (case when EMPLOYEE_ID = '4380' then 'Troy'
                   else first_name end) || ' ' || LAST_NAME as name,
--                CONCAT_WS(' ', first_name_concat,
--                    last_name) AS name,
               employee_title,
               employee_id,
               work_email,
               manager_id,
               manager_email
        FROM directory
        WHERE employee_id = 103
        UNION ALL
        SELECT CONCAT_WS(',', emp.manager_email, man.manager_list) AS manager_list,
--                CONCAT_WS(' ', emp.first_name, emp.last_name)       AS name,
              (case when emp.EMPLOYEE_ID = '4380' then 'Troy'
                   else emp.first_name end) || ' ' || emp.LAST_NAME as name,
               emp.employee_title,
               emp.employee_id,
               emp.work_email,
               emp.manager_id,
               emp.manager_email
        FROM directory emp
                 INNER JOIN managers man
                            ON emp.manager_id = man.employee_id)
SELECT STRTOK_TO_ARRAY(manager_list, ',') AS manager_array,
       m.name,
       m.employee_title,
       m.employee_id,
       u.user_id,
       m.work_email,
       m.manager_id
FROM managers m
         INNER JOIN es_warehouse.public.users u
                    ON m.employee_id = TRY_TO_NUMBER(u.employee_id)
where u.company_id = 1854;;
  }

  dimension: name {
    label: "Employee Name"
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: employee_title {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }

  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
    value_format_name: id
    primary_key: yes
  }

  dimension: user_id {
    label: "Employee User ID"
    type: number
    sql: ${TABLE}."USER_ID" ;;
    value_format_name: id
  }

  dimension: work_email {
    label: "Employee Work Email"
    type: string
    sql: ${TABLE}."WORK_EMAIL" ;;
  }

  dimension: manager_id {
    label: "Direct Manager Employee ID"
    type: number
    sql: ${TABLE}."MANAGER_ID";;
    value_format_name: id
  }

  dimension: manager_array {
    label: "Manager List"
    type: string
    sql: ${TABLE}."MANAGER_ARRAY"::VARIANT ;;
  }
}
