with source as (

    select * from {{ source('analytics_branch_earnings', 'account_categories') }}

),

renamed as (

    select

        -- id
        pk_account_category_id,

        -- strings
        account_category,

        -- numerics
        sort_order

    from source

)

select * from renamed
