with source as (
    select * from {{ source('analytics_commission', 'company_commission_exceptions') }}
),

renamed as (
    select
        company_exception_id,
        company_id,
        start_date::timestamp_ntz as start_date,
        end_date::timestamp_ntz as end_date,
        exception_type_id,
        override_rate,
        line_item_type_id

    from source
)

select * from renamed
