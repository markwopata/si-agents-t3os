with source as (

    select * from {{ source('analytics_public', 'stat_pl') }}

),

renamed as (

    select

        -- strings
        line_item_type,
        revexp as revenue_expense_categorization,
        stat_acct as statistical_account

    from source

)

select * from renamed
