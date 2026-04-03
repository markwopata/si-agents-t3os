#X# Conversion failed: failed to parse YAML.  Check for pipes on newlines


view: invalid_active_managers {
  derived_table: {
    sql: SELECT bm.employee_id, concat(bm.first_name,' ',bm.last_name) as user_name, bm.active_status as status_budget_manager, dh.active_status as status_dep_head, cd.employee_status, cd.date_terminated, dh.department as head_of_dep, bm.department as budget_manager_dep
      FROM ANALYTICS.CORPORATE_BUDGET.BUDGET_MANAGERS as bm

      left join ANALYTICS.CORPORATE_BUDGET.DEPARTMENT_HEADS as dh on dh.employee_id = bm.employee_id
      left join ANALYTICS.PAYROLL.COMPANY_DIRECTORY as cd on bm.employee_id = cd.employee_id

      where cd.employee_status = 'Terminated' and bm.active_status = 'TRUE'
          or dh.active_status = 'TRUE' and cd.employee_status = 'Terminated' ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }

  dimension: user_name {
    type: string
    sql: ${TABLE}."USER_NAME" ;;
  }

  dimension: status_budget_manager {
    type: yesno
    sql: ${TABLE}."STATUS_BUDGET_MANAGER" ;;
  }

  dimension: status_dep_head {
    type: yesno
    sql: ${TABLE}."STATUS_DEP_HEAD" ;;
  }

  dimension: employee_status {
    type: string
    sql: ${TABLE}."EMPLOYEE_STATUS" ;;
  }

  dimension: date_terminated {
    type: string
    sql: ${TABLE}."DATE_TERMINATED" ;;
  }

  dimension: head_of_dep {
    type: string
    sql: ${TABLE}."HEAD_OF_DEP" ;;
  }

  dimension: budget_manager_dep {
    type: string
    sql: ${TABLE}."BUDGET_MANAGER_DEP" ;;
  }

  set: detail {
    fields: [
        employee_id,
	user_name,
	status_budget_manager,
	status_dep_head,
	employee_status,
	date_terminated,
	head_of_dep,
	budget_manager_dep
    ]
  }
}
