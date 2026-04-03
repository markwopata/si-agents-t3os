  view: managers_names {
    derived_table: {
      sql:
      select distinct EMPLOYEE_ID as manager_id,
      case when position(' ',coalesce(NICKNAME,FIRST_NAME)) = 0 then concat(coalesce(NICKNAME,FIRST_NAME), ' ', LAST_NAME)
           else concat(coalesce(NICKNAME,concat(FIRST_NAME, ' ',LAST_NAME))) end as manager_name,
      direct_manager_employee_id
from analytics.PAYROLL.COMPANY_DIRECTORY
               ;;
    }


    dimension: manager_id {
      type: string
      sql: ${TABLE}."MANAGER_ID" ;;
    }

    dimension: manager_name {
      type: string
      sql: ${TABLE}."MANAGER_NAME" ;;
    }

    dimension: direct_manager_employee_id {
      type: number
      sql: ${TABLE}."DIRECT_MANAGER_EMPLOYEE_ID" ;;
    }
    }
