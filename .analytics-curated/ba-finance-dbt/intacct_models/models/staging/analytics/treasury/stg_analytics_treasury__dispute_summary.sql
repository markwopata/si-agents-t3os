with source as (

    select * from {{ source('analytics_treasury', 'dispute_summary') }}

)

, renamed as (

    select

        -- ids
        dispute_id
        , branch_id
        , created_by_user_id
        , resolved_by_user_id

        -- strings
        , status
        , branch_name as market_name
        , created_by_email
        , resolved_by_email
        , created_by_title
        , resolved_by_title
        , general_manager
        , case
            when round(days_to_resolve, 1) > 14 then 'Over Threshold'
            when round(days_to_resolve, 1) is null then 'Open Dispute'
            else 'Under Threshold'
          end as dispute_category

        -- numerics
        , round(days_to_resolve, 1) as days_to_resolve

        -- dates
        , created_month

        -- timestamps
        , date_created
        , date_resolved

    from source

)

select * from renamed
