with source as (

    select * from {{ source('analytics_corporate_budget', 'approved_budgets') }}

),

renamed as (

    select
        -- ids
        expense_line_id,
        department_id,
        sub_department_id,
        _row,

        -- strings
        department_name,
        expense_line_name,
        sub_department_name,

        -- numerics
        budget_year,
        approved_budget,

        -- timestamp
        _fivetran_synced,

    from source

)

select * from renamed
