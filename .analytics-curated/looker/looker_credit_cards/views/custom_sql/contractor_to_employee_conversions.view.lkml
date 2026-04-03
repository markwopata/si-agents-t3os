view: contractor_to_employee_conversions {
  derived_table: {
    sql:
    with converted_employees as (select work_email, count(*)
                             from analytics.payroll.company_directory
                             group by work_email
                             having count(*) > 1
                                and work_email is not null
                             order by count(*) desc),
     contingent_worker as (select *
                           from analytics.payroll.company_directory
                           where work_email in (select work_email from converted_employees)
                             and employee_status = 'Terminated')

select cd_a.employee_id                                as employee_id,
       UPPER(cd_a.first_name)                          as first_name,
       UPPER(cd_a.last_name)                           as last_name,
       cd_a.work_email                                 as work_email,
       cd_a.employee_status                            as employee_status,
       cd_a.position_effective_date::date              as position_effective_date,
       cd_a.worker_type                                as worker_type,
       cw.employee_id                                  as prior_employee_id,
       cw.worker_type                                  as prior_worker_type,
       cw.date_terminated::date                        as prior_worker_type_end_date
from analytics.payroll.company_directory cd_a
         left join contingent_worker cw
                   on cd_a.work_email = cw.work_email
where cd_a.work_email in (select work_email from converted_employees)
  and cd_a.employee_status = 'Active'
order by cd_a.position_effective_date desc, cd_a.work_email
    ;;
  }

  dimension: employee_id {
    type: string
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }

  dimension: work_email {
    type: string
    sql: ${TABLE}."WORK_EMAIL" ;;
  }

  dimension: employee_status {
    type: string
    sql: ${TABLE}."EMPLOYEE_STATUS" ;;
  }

  dimension: position_effective_date {
    type: date
    sql: ${TABLE}."POSITION_EFFECTIVE_DATE" ;;
  }

  dimension: worker_type {
    type: string
    sql: ${TABLE}."WORKER_TYPE" ;;
  }

  dimension: prior_employee_id {
    type: string
    sql: ${TABLE}."PRIOR_EMPLOYEE_ID" ;;
  }

  dimension: prior_worker_type {
    type: string
    sql: ${TABLE}."PRIOR_WORKER_TYPE" ;;
  }

  dimension: prior_worker_type_end_date {
    type: date
    sql: ${TABLE}."PRIOR_WORKER_TYPE_END_DATE" ;;
  }
}
