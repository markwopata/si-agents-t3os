with source as (
    select * from {{ source('analytics_credit_card', 'citi_vehicle_rental_detail') }}
),

renamed as (
    select

        -- ints
        sequence_num as sequence_number,

        -- numerics
        days_rented,
        rental_rate,
        rate_per_mile,
        total_miles,
        maximum_free_miles,
        insurance_charges,
        weekly_rental_rate,
        total_authorized_amount,

        -- strings
        -- Just in case we get 'None' back from the etl
        source_file,
        transaction_id,
        iff(return_location_id = 'None', null, return_location_id) as return_location_id,
        iff(maintenance_code = 'None', null, maintenance_code) as maintenance_code,
        iff(rental_agreement_num = 'None', null, rental_agreement_num) as rental_agreement_number,
        iff(renter_name = 'None', null, renter_name) as renter_name,
        iff(rental_return_city = 'None', null, rental_return_city) as rental_return_city,
        iff(rental_return_state_province = 'None', null, rental_return_state_province) as rental_return_state_province,
        iff(rental_return_country = 'None', null, rental_return_country) as rental_return_country,
        iff(rental_rate_indicator = 'None', null, rental_rate_indicator) as rental_rate_indicator,
        iff(insurance_indicator = 'None', null, insurance_indicator) as insurance_indicator,
        iff(vehicle_check_out_city = 'None', null, vehicle_check_out_city) as vehicle_check_out_city,
        iff(vehicle_check_out_state_province = 'None', null, vehicle_check_out_state_province)
            as vehicle_check_out_state_province,
        iff(
            vehicle_check_out_country = 'None',
            null, vehicle_check_out_country
        ) as vehicle_check_out_country,
        iff(rental_class = 'None', null, rental_class) as rental_class,
        iff(corporate_identifier = 'None', null, corporate_identifier) as corporate_identifier,
        iff(no_show_indicator = 'None', null, no_show_indicator) as no_show_indicator,
        iff(
            customer_service_toll_free_800_num = 'None',
            null,
            customer_service_toll_free_800_num
        ) as customer_service_toll_free_800_number,
        iff(vehicle_return_location = 'None', null, vehicle_return_location) as vehicle_return_location,

        -- timestamps
        rental_return_date,
        check_out_date,
        _es_update_timestamp

    from source
)

select * from renamed
qualify row_number() over (partition by transaction_id order by source_file desc) = 1
