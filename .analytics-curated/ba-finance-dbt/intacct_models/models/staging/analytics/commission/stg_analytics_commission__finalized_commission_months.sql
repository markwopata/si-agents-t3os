with source as (
    select * from {{ source('analytics_commission', 'finalized_commission_months') }}
),

renamed as (
    select
        pk_id,
        date,
        date_completed,
        completed_by

    from source
)

select * from renamed
