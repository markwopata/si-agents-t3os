with source as (

    select * from {{ source('es_warehouse_scd', 'scd_asset_inventory') }}

),

renamed as (

    select

        -- ids
        scd_asset_inventory_id,
        asset_id,
        inventory_branch_id,

        -- booleans
        current_flag,

        -- timestamps
        date_start,
        date_end,

    from source

)

select * from renamed
