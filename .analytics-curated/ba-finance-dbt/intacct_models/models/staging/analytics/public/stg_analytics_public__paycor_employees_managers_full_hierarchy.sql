with source as (
      select * from {{ source('analytics_public', 'paycor_employees_managers_full_hierarchy') }}
),
renamed as (
    select
        -- ids
        employee_number as employee_id
        , manager_employee_number::int as manager_employee_id

        -- strings
        , first_name
        , last_name
        , full_employee_name
        , employee_title
        , work_location
        , manager
        , manager_first_name
        , manager_last_name
        , full_manager_name
        , report_type
        
    from source
)
select * from renamed
