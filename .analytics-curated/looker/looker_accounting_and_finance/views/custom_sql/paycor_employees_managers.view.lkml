view: paycor_employees_managers {
  derived_table: {
    publish_as_db_view: yes
    sql:
     with all_current_paycor as(
  select
    pem.employee_id::INT as employee_number
    ,pem.first_name
    ,pem.last_name
    ,NULL as rate_type
    ,pem.employee_title
    ,pem.work_email as employee_email
    ,case when(pem.date_rehired is null) then pem.date_hired else pem.date_rehired end as hire_rehire_date
    ,pem.location as work_location
    ,NULL as department_code
    ,NULL as department_name
    ,pem.direct_manager_name as manager
    ,pem.direct_manager_employee_id as manager_employee_number
    ,cd.work_email as manager_email
    ,concat(pem.first_name,' ',pem.last_name) as full_employee_name
    ,cd.first_name as manager_first_name
    ,cd.last_name as manager_last_name
    ,pem.direct_manager_name as full_manager_name
    ,NULL as loc_name
    ,NULL as dept_name
from analytics.payroll.company_directory pem
    left join analytics.payroll.company_directory cd
    on pem.employee_id=cd.employee_id
--left join ANALYTICS.PAYROLL.UKG_PAYCOR_MAPPING upm
--on pem.DEFAULT_COST_CENTERS_FULL_PATH=upm.UKG_DEPARTMENT_CODE
)
    , overrides as(
    select
    pemo.employee_number
    ,pemo.first_name
    ,pemo.last_name
    ,NULL as rate_type
    ,pemo.employee_title
    ,pemo.employee_email
    ,pemo.hire_rehire_date
    ,pemo.work_location
    ,NULL as department_code
    ,NULL as department_name
    ,pemo.manager
    ,pemo.manager_employee_number
    ,pemo.manager_email
    ,pemo.full_employee_name
    ,pemo.manager_first_name
    ,pemo.manager_last_name
    ,pemo.full_manager_name
    ,NULL as loc_name
    ,NULL as dept_name
    from analytics.gs.paycor_employees_managers_overrides pemo
    left join all_current_paycor acp
    on pemo.employee_number=acp.employee_number
    where acp.employee_number is null
    )
, final_union as (
    select *
    from all_current_paycor
    union all
    select *
    from overrides
)
select
fu.*
,cd.default_cost_centers_full_path
from final_union fu
left join ANALYTICS.PAYROLL.COMPANY_DIRECTORY cd
on fu.employee_email=cd.work_email
  ;;
  }

  dimension: employee_email {
    primary_key: yes
    type: string
    sql: ${TABLE}."EMPLOYEE_EMAIL" ;;
  }

  dimension: employee_number {
    type: number
    sql: ${TABLE}."EMPLOYEE_NUMBER" ;;
  }

  dimension: employee_title {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }

  dimension: default_cost_centers_full_path {
    type: string
    sql: ${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH" ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }

  dimension: full_employee_name {
    type: string
    sql: UPPER(TRIM(${TABLE}."FULL_EMPLOYEE_NAME")) ;;
  }

  dimension: full_manager_name {
    type: string
    sql: ${TABLE}."FULL_MANAGER_NAME" ;;
  }

  dimension: hire_rehire_date {
    type: string
    sql: ${TABLE}."HIRE_REHIRE_DATE" ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }

  dimension: manager {
    type: string
    sql: ${TABLE}."MANAGER" ;;
  }

  dimension: manager_email {
    type: string
    sql: ${TABLE}."MANAGER_EMAIL" ;;
  }

  dimension: manager_employee_number {
    type: number
    sql: ${TABLE}."MANAGER_EMPLOYEE_NUMBER" ;;
  }

  dimension: manager_first_name {
    type: string
    sql: ${TABLE}."MANAGER_FIRST_NAME" ;;
  }

  dimension: manager_last_name {
    type: string
    sql: ${TABLE}."MANAGER_LAST_NAME" ;;
  }

  dimension: work_location {
    type: string
    sql: ${TABLE}."WORK_LOCATION" ;;
  }

  dimension: cost_center_lvl_1 {
    type: string
    sql: trim(split_part(${default_cost_centers_full_path},'/',1)) ;;
  }

  dimension: cost_center_lvl_2 {
    type: string
    sql: trim(split_part(${default_cost_centers_full_path},'/',2)) ;;
  }

  dimension: cost_center_lvl_3 {
    type: string
    sql: trim(split_part(${default_cost_centers_full_path},'/',3)) ;;
  }

  dimension: cost_center_lvl_4 {
    type: string
    sql: trim(split_part(${default_cost_centers_full_path},'/',4)) ;;
  }

  dimension: cost_center_lvl_5 {
    type: string
    sql: trim(split_part(${default_cost_centers_full_path},'/',5)) ;;
  }

  dimension: last_cost_center {
    type: string
    sql: coalesce(coalesce(coalesce(coalesce(${cost_center_lvl_5}, ${cost_center_lvl_4}), ${cost_center_lvl_3}), ${cost_center_lvl_2}), ${cost_center_lvl_1});;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      last_name,
      first_name,
      manager_last_name,
      manager_first_name,
      full_employee_name,
      full_manager_name
    ]
  }
}
