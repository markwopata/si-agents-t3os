SELECT 
    employee.employee_key
    , employee.employee_id
    , employee.first_name
    , employee.nickname
    , employee.last_name
    , employee.work_email
    , employee.work_phone
    , employee.personal_email
    , employee.home_phone
    , employee.employee_type
    , employee.employee_status
    , employee.employee_title
    , employee.position_effective_date
    , employee.date_hired
    , employee.date_rehired
    , employee.date_terminated
    , employee.is_on_leave
    , employee.location
    , employee.default_cost_centers_full_path
    , employee.greenhouse_application_id
    , employee.market_key
    , employee.account_id
    , employee.pay_calc
    , employee.ee_state
    , employee.doc_uname
    , employee.tax_location
    , employee.labor_distribution_profile
    , employee.worker_type

    , manager.first_name as manager_first_name
    , manager.nickname as manager_nickname
    , manager.last_name as manager_last_name
    , manager.work_email as manager_email
    , manager.employee_status as manager_employee_status

    , skip.first_name as skip_manager_first_name
    , skip.nickname as skip_manager_nickname
    , skip.last_name as skip_manager_last_name
    , skip.work_email as skip_manager_email
    , skip.employee_status as skip_manager_employee_status
    
    , employee._created_recordtimestamp
    , employee._updated_recordtimestamp

FROM {{ ref('dim_employees') }} employee
join {{ ref('dim_employees') }} manager
on employee.manager_employee_key = manager.employee_key
join {{ ref('dim_employees') }} skip
on manager.manager_employee_key = skip.employee_key
