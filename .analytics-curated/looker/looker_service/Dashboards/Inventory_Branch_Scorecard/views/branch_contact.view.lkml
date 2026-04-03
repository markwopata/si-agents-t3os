view: branch_contact {
  derived_table: {
    sql:
select cd.market_id,
       xw.MARKET_NAME,
       concat(first_name, ' ', Last_name) as employee_name,
       employee_title,
       DATEDIFF('months', POSITION_EFFECTIVE_DATE, current_date()) as months_in_role,
       case
           when EMPLOYEE_TITLE ilike '%General%Manager%' then 3
           when EMPLOYEE_TITLE ilike '%Service%Manager%' then 4
           when EMPLOYEE_TITLE ilike '%Part%Manager%' then 1
           when EMPLOYEE_TITLE ilike '%Part%Assistant%' then 2
       end as priority_list,
       WORK_PHONE,
       work_email
from "ANALYTICS"."PAYROLL"."COMPANY_DIRECTORY" as cd
    join ANALYTICS.PUBLIC.MARKET_REGION_XWALK as xw on cd.MARKET_ID = xw.MARKET_ID
where DATE_TRUNC('month', CURRENT_DATE()) = DATE_TRUNC('month', LAST_UPDATED_DATE::date)
  and employee_status ilike any ('Active', 'External Payroll', 'Leave with Pay', 'Leave withoutout Pay', 'Work Comp Leave')
  and employee_title ilike any ('%part%','%manager%')
  and EMPLOYEE_TITLE not ilike ('%account%')
  and employee_id is not null
  and LAST_UPDATED_DATE is not null
--   and cd.market_id = 78646
QUALIFY ROW_NUMBER() OVER(PARTITION BY cd.market_id ORDER BY priority_list asc, POSITION_EFFECTIVE_DATE asc) = 1 -- qualifier to get the most recent manager in the order provided by priority_list

;;
  }
  dimension: market_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: employee_name {
    type: string
    sql: ${TABLE}."EMPLOYEE_NAME" ;;
  }
  dimension: employee_title {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }
  dimension: work_phone {
    type: number
    value_format: "(000) 000-0000"
    sql: ${TABLE}."WORK_PHONE" ;;
  }
  dimension: work_email {
    type: string
    sql: ${TABLE}."WORK_EMAIL" ;;
  }
}
