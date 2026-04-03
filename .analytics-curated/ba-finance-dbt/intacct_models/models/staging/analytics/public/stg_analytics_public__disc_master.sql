with disc_data as (
    select
        dgu.employee_id,
        dgu.disc_code,
        dm.completed_date
    from {{ ref("base_analytics_public__disc_gh_ukg") }} as dgu
        inner join {{ ref("base_analytics_public__disc_master") }} as dm
            on dgu.disc_code = dm.disc_code

    union

    select
        cd.employee_id,
        dm.disc_code,
        dm.completed_date
    from {{ ref("base_analytics_public__disc_master") }} as dm
        inner join {{ ref("stg_analytics_payroll__company_directory") }} as cd
            on
                dm.email_address = cd.personal_email
                or dm.email_address = cd.work_email
)

select
    dd.employee_id,
    dm.disc_code,
    dm.email_address,
    dm.disc_sent_date,
    dm.completed_date,
    dm.environment_style,
    dm.basic_style,
    dm.blend,
    dm.main_strength,
    dm.applicant,
    dm.status,
    dm.updated_date,
    dm.url_disc
from disc_data as dd
    inner join {{ ref("base_analytics_public__disc_master") }} as dm
        on dd.disc_code = dm.disc_code
qualify
    row_number()
        over (
            partition by dd.employee_id
            order by
                dm.completed_date desc,
                dm.disc_sent_date desc,
                dm.updated_date desc
        )
    = 1
