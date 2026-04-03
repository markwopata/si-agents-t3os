with source as (

    select * from {{ source('es_warehouse_inventory', 'weighted_average_cost_snapshots') }}

),

renamed as (

    select
        -- ids
        wac_snapshot_id,
        created_by_id as created_by_user_id,
        transaction_id,
        inventory_location_id,
        product_id,
        modified_by_id as updated_by_user_id,
        
        -- strings
        reason, 
        
        -- numerics
        incoming_cost_per_item,
        total_quantity,
        weighted_average_cost,
        incoming_quantity,

        -- booleans
        is_override,
        is_current, 

        -- timestamps
        date_created,
        _es_update_timestamp,
        _es_load_timestamp,
        date_updated,
        date_archived,
        date_applied

    from source

)

select * from renamed
