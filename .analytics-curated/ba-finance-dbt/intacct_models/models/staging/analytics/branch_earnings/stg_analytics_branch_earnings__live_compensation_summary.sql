with source as (

    select * from {{ source('analytics_branch_earnings', 'live_compensation_summary') }}

),

renamed as (

    select
        -- strings
        intacct as intacct_department_id,
        gl_code,
        finalized, 
        payroll_name,
        pay_period_profile,

        -- numerics
        hours_cost,
        hours_calc,

        -- dates
        pay_date,
        pay_period_start,
        pay_period_end,

        -- timestamps
        _es_update_timestamp

    from source

)

select * from renamed
