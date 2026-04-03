with source as (
    select * from {{ source('analytics_financial_systems', 'ogitem_to_newitem') }}
)

, renamed as (
    select
        -- ids
        og_item_id as original_item_id,
        new_item_id as item_id
    
    from source

)

select * from renamed
