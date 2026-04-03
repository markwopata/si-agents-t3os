with source as (
      select * from {{ source('analytics_commission', 'nam_company_assignments') }}
),
renamed as (
    select
        nam_assignment_id,
        nam_user_id::int as nam_user_id,
        director_user_id,
        company_id,
        effective_start_date,
        effective_end_date,
        record_creation_date,
        created_by_email
    from source
)
select * from renamed
