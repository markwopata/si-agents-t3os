with greenhouse_data as (

    select * from {{ ref('stg_analytics_employee_data__employee_disc_greenhouse') }}

),

data as (
    select
        cd.employee_id,
        coalesce(cd.greenhouse_application_id, gd.application_id)
            as greenhouse_application_id,
        gd.candidate_id,
        'https://app.greenhouse.io/people/'
        || gd.candidate_id
        || '?application_id='
        || coalesce(cd.greenhouse_application_id, gd.application_id)
        || '#application' as greenhouse_link
    from {{ ref("stg_analytics_payroll__company_directory") }} as cd
        left join greenhouse_data as gd
            on
                cd.personal_email
                = gd.work_email
                or cd.work_email
                = gd.work_email
)

select
    employee_id,
    greenhouse_application_id,
    candidate_id,
    greenhouse_link
from data
qualify
    row_number() over (partition by employee_id order by candidate_id desc) = 1
