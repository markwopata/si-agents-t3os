with source as (
    select * from {{ source('analytics_credit_card', 'citi_airline_ticket_detail') }}
),

renamed as (
    select

        -- ids
        transaction_id,

        -- ints
        sequence_num as sequence_number,

        -- numerics
        total_fare,

        -- strings 
        -- Just in case we get 'None' back from the etl
        iff(ticket_num = 'None', null, ticket_num) as ticket_number,
        source_file,
        iff(passenger_name = 'None', null, passenger_name) as passenger_name,
        iff(maintenance_code = 'None', null, maintenance_code) as maintenance_code,
        iff(issuing_carrier = 'None', null, issuing_carrier) as issuing_carrier,
        iff(travel_agency_name = 'None', null, travel_agency_name) as travel_agency_name,
        iff(travel_agency_code = 'None', null, travel_agency_code) as travel_agency_code,
        iff(customer_code = 'None', null, customer_code) as customer_code,

        -- timestamps
        issue_date,
        _es_update_timestamp

    from source
)

select * from renamed
qualify row_number() over (partition by transaction_id order by source_file desc) = 1
