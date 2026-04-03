with employees as (
    select * from {{ ref('stg_analytics_payroll__company_directory') }}
),

emp_manager_hierarchy as (
    select * from {{ ref('stg_analytics_public__paycor_employees_managers_full_hierarchy' ) }}
)

select
    h.employee_id,
    h.manager_employee_id,
    h.first_name,
    h.last_name,
    h.full_employee_name,
    e.work_email,
    h.employee_title,
    h.manager,
    h.full_manager_name,
    h.report_type
from employees as e
    left join emp_manager_hierarchy as h
        on e.employee_id = h.employee_id
