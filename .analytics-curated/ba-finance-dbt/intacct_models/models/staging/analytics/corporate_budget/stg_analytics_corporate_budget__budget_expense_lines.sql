with source as (

    select * from {{ source('analytics_corporate_budget', 'budget_expense_lines') }}

),

renamed as (

    select
        -- ids
        _row,

        -- strings
        expense_line_name,
        expense_category,
        gl_account_type,


        -- numerics
        budget_year,
        cost_capture_id,
        gl_mapping,
        expense_line_id,

        -- timestamp
        _fivetran_synced,

    from source

)

select * from renamed
