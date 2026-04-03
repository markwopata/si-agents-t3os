with source as (
    select * from {{ source('analytics_credit_card', 'citi_airline_trip_leg_detail') }}
),

renamed as (
    select
        -- ids
        transaction_id,

        -- ints
        sequence_num as sequence_number,
        coupon_num as coupon_number,

        -- strings 
        -- Just in case we get 'None' back from the etl
        source_file,
        iff(flight_num = 'None', null, flight_num) as flight_number,
        iff(ticket_num = 'None', null, ticket_num) as ticket_number,
        iff(maintenance_code = 'None', null, maintenance_code) as maintenance_code,
        iff(trip_leg_num = 'None', null, trip_leg_num) as trip_leg_number,
        iff(city_of_origin = 'None', null, city_of_origin) as city_of_origin,
        iff(city_of_destination = 'None', null, city_of_destination) as city_of_destination,
        iff(carrier_code = 'None', null, carrier_code) as carrier_code,
        iff(service_class = 'None', null, service_class) as service_class,
        iff(stop_over_indicator = 'None', null, stop_over_indicator) as stop_over_indicator,
        iff(fare_base_code = 'None', null, fare_base_code) as fare_base_code,
        iff(conjunction_ticket = 'None', null, conjunction_ticket) as conjunction_ticket,

        -- timestamps
        travel_date,
        departure_time,
        arrival_time,
        _es_update_timestamp

    from source
)

select * from renamed
qualify row_number() over (partition by transaction_id, trip_leg_number order by source_file desc) = 1
