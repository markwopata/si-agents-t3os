with source as (

    select * from {{ source('analytics_employee_data', 'employee_disc_greenhouse') }}

),

renamed as (

    select

        -- ids
        employee_id,
        application_id,
        candidate_id,
        disc_code,

        -- strings
        employee_status,
        work_email,
        first_name,
        last_name,
        candidate_full_name,
        employee_title,
        disc_link,
        greenhouse_link,

        -- dates
        date_hired,
        date_terminated

    from source

)

select * from renamed
