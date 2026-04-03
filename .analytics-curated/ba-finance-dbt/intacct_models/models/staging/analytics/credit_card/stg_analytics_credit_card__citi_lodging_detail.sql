with source as (
    select * from {{ source('analytics_credit_card', 'citi_lodging_detail') }}
),

renamed as (
    select
        -- ids
        transaction_id,

        -- ints
        sequence_number,
        customer_service_toll_free_800_num,
        property_phone_num,

        -- numerics
        total_room_nights,
        room_rate_amount,
        total_room_tax,

        -- strings 
        -- Just in case we get 'None' back from the etl
        source_file,
        iff(maintenance_code = 'None', null, maintenance_code) as maintenance_code,
        iff(folio_num = 'None', null, folio_num) as folio_num,

        -- timestamps
        arrival_date,
        departure_date,
        approval_date,
        _es_update_timestamp

    from source
)

select * from renamed
qualify row_number() over (partition by transaction_id order by source_file desc) = 1
