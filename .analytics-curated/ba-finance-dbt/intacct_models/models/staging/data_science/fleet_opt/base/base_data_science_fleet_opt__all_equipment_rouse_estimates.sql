with source as (

    select * from {{ source('data_science_fleet_opt', 'all_equipment_rouse_estimates') }}

),

renamed as (

    select

        -- ids
        asset_id,

        -- strings
        -- numerics

        cost_with_attachments,
        net_book_value,
        predictions_retail,
        predictions_retail_lower_25,
        predictions_retail_upper_75,
        rouse_retail,
        four_pct_commission_bound,
        predictions_wholesale,
        predictions_wholesale_lower_25,
        predictions_wholesale_upper_75,

        rouse_wholesale as orderly_liquidation_value,
        predictions_wholesale * 1.1 as buyout_price,

        predictions_auction_lower_25,
        predictions_auction,
        predictions_auction_upper_75,
        rouse_auction,
        five_pct_commission_bound,
        lower_sale_cutoff,

        -- booleans
        -- dates
        -- timestamps
        date_created

    from source

)

select * from renamed
