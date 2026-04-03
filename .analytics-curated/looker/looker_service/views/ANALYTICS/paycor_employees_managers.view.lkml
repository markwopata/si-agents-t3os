view: paycor_employees_managers {
derived_table: {
  sql: with all_users as(
  select
h.*
,concat(l.street_1, ' ', l.city,', ',s.name) as market_address
,split_part(employee_email,'@',1) as employee_username
,split_part(manager_email,'@',1) as manager_username
from ANALYTICS.PUBLIC.paycor_employees_managers h
left join ANALYTICS.MARKET_DATA.MARKET_DIRECTORY m
on upper(case when h.LOC_NAME = 'PBF' then 'LIT'
else LOC_NAME end)=upper(m.paycor_name)
and upper(case when DEPT_NAME = 'ADM' then 'OPS'
when DEPT_NAME = 'Pu' then 'Pum'
else DEPT_NAME end)=upper(m.MARKET_TYPE)
left join es_warehouse.public.markets m2
on m.market_id=m2.market_id
left join es_warehouse.public.locations l
on m2.location_id=l.location_id
left join es_warehouse.public.states s
on l.state_id=s.state_id
order by m.market_id
)
, managers_only as(
select
manager_email
  ,1 as manager_ind
  from ANALYTICS.PUBLIC.paycor_employees_managers
  group by
  manager_email
  ,manager_ind
)
select
au.*
,case when(mo.manager_ind is null) then 'No' else 'Yes' end as manager_indicator
from all_users au
left join managers_only mo
on au.employee_email=mo.manager_email ;;
}


  dimension: department_code {
    type: number
    sql: ${TABLE}."DEPARTMENT_CODE" ;;
  }

  dimension: department_name {
    type: string
    sql: ${TABLE}."DEPARTMENT_NAME" ;;
  }

  dimension: dept_name {
    type: string
    sql: ${TABLE}."DEPT_NAME" ;;
  }

  dimension: employee_email {
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

  dimension: employee_username {
    type: string
    sql: ${TABLE}."EMPLOYEE_USERNAME";;
  }

  dimension: employee_password {
    type: string
    sql: ${TABLE}."EMPLOYEE_USERNAME";;
  }

  dimension: manager_username {
    type: string
    sql: ${TABLE}."MANAGER_USERNAME";;
  }

  dimension: manager_password {
    type: string
    sql: ${TABLE}."MANAGER_USERNAME";;
  }

  dimension: manager_indicator {
    type: string
    sql: ${TABLE}."MANAGER_INDICATOR" ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }

  dimension: full_employee_name {
    type: string
    sql: ${TABLE}."FULL_EMPLOYEE_NAME" ;;
  }

  dimension: full_manager_name {
    type: string
    sql: ${TABLE}."FULL_MANAGER_NAME" ;;
  }

  dimension_group: hire_rehire {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."HIRE_REHIRE_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }

  dimension: loc_name {
    type: string
    sql: ${TABLE}."LOC_NAME" ;;
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

  dimension: market_address {
    type: string
    sql: ${TABLE}."MARKET_ADDRESS" ;;
  }

  dimension: rate_type {
    type: string
    sql: ${TABLE}."RATE_TYPE" ;;
  }

  dimension: work_location {
    type: string
    sql: ${TABLE}."WORK_LOCATION" ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      first_name,
      loc_name,
      department_name,
      manager_first_name,
      full_manager_name,
      full_employee_name,
      dept_name,
      manager_last_name,
      last_name
    ]
  }
}
