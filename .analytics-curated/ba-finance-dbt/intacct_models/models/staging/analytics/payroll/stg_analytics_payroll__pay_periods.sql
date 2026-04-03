with source as (
      select * from {{ source('analytics_payroll', 'pay_periods') }}
),
renamed as (
    select
        -- ids
        pay_id,

        -- timestamps
        pay_date_from,
        pay_date_to,
        paycheck_date,
        comm_check_date

    from source
)
select * from renamed
