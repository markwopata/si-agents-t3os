with users as (
    select
        u.user_id,
        u.email_address,
        u.employee_id,
        u.company_id,
        u.is_deleted
    from {{ ref("stg_es_warehouse_public__users") }} as u
    where u.company_id = 1854
),

id_match as (
    select
        u.user_id,
        u.email_address,
        u.employee_id as user_employee_id,
        cd.employee_id as cd_employee_id,
        u.is_deleted,
        'employee_id_match' as join_type
    from users as u
        inner join {{ ref("stg_analytics_payroll__company_directory") }} as cd
            on u.employee_id = cd.employee_id::text
),

email_match as (
    select
        u.user_id,
        u.email_address,
        u.employee_id as user_employee_id,
        cd.employee_id as cd_employee_id,
        u.is_deleted,
        'email_match' as join_type
    from {{ ref("stg_analytics_payroll__company_directory") }} as cd
        left join id_match as im
            on cd.employee_id = im.cd_employee_id
        inner join users as u
            on cd.work_email = u.email_address -- move left to base models
    where im.cd_employee_id is null -- Don't do this match for ones we already have a match
),

combine as (
    select
        em.user_id,
        em.email_address,
        em.user_employee_id,
        em.cd_employee_id,
        em.is_deleted,
        em.join_type
    from email_match as em

    union all

    select
        im.user_id,
        im.email_address,
        im.user_employee_id,
        im.cd_employee_id,
        is_deleted,
        im.join_type
    from id_match as im
)

select
    combine.cd_employee_id as employee_id,
    combine.user_id,
    combine.email_address,
    combine.join_type
from combine
