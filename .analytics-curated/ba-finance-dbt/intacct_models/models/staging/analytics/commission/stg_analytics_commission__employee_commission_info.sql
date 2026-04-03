with source as (
    select * from {{ source('analytics_commission', 'employee_commission_info') }}
),

renamed as (
    select
        employee_commission_info_id::int as employee_commission_info_id,
        user_id::int as user_id,
        commission_type_id,
        guarantee_amount::numeric as guarantee_amount,
        guarantee_start::timestamp_ntz as guarantee_start,
        guarantee_end::timestamp_ntz as guarantee_end,
        commission_start::timestamp_ntz as commission_start,
        commission_end::timestamp_ntz as commission_end,
        comments,
        date_updated,
        iff(user_id is not null and commission_type_id not in (6, 7), true, false) as is_salesperson,
        iff(commission_type_id = 6, true, false) as is_nam,
        iff(commission_type_id = 7, true, false) as is_nam_director

    from source
)

select * from renamed
