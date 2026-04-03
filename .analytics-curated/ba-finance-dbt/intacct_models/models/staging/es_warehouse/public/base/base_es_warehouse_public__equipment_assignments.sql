with source as (

    select * from {{ source('es_warehouse_public', 'equipment_assignments') }}
)

, renamed as (
    
    select

        -- ids
        ea.equipment_assignment_id,
        ea.asset_id,
        ea.rental_id,
        ea.drop_off_delivery_id,
        ea.return_delivery_id,

        -- dates
        ea.start_date,
        coalesce(ea.end_date, '9999-12-31') as end_date,
        ea.date_created,
        ea.date_updated,

        -- timestamps
        ea._es_update_timestamp
    
    from source as ea
)

select * from renamed
