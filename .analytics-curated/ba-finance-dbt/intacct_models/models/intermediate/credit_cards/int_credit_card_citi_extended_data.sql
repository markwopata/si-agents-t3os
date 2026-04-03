{{
    config(
        schema='credit_card'
    )
}}

select
    -- Daily transactions fields
    dt.employee_id,
    dt.transaction_id,
    (rd.transaction_id is not null) as has_vehicle_rental_detail,
    (ad.transaction_id is not null) as has_airline_detail,
    (ld.transaction_id is not null) as has_lodging_detail,
    dt.first_name,
    dt.last_name,
    dt.full_name,
    dt.mcc,
    dt.card_type,
    dt.status,
    dt.merchant_name,
    dt.employee_title,
    dt.corporate_account_number,
    dt.corporate_account_name,
    dt.worker_type,
    dt.transaction_amount,
    dt.mcc_code,
    dt.is_bypass_verification,
    dt.transaction_date,

    -- Vehicle rental fields (prefixed with vehicle_rental_)
    rd.sequence_number as vehicle_rental_sequence_number,
    rd.days_rented as vehicle_rental_days_rented,
    rd.rental_rate as vehicle_rental_rental_rate,
    rd.rate_per_mile as vehicle_rental_rate_per_mile,
    rd.total_miles as vehicle_rental_total_miles,
    rd.maximum_free_miles as vehicle_rental_maximum_free_miles,
    rd.insurance_charges as vehicle_rental_insurance_charges,
    rd.weekly_rental_rate as vehicle_rental_weekly_rental_rate,
    rd.total_authorized_amount as vehicle_rental_total_authorized_amount,
    rd.source_file as vehicle_rental_source_file,
    rd.return_location_id as vehicle_rental_return_location_id,
    rd.maintenance_code as vehicle_rental_maintenance_code,
    rd.rental_agreement_number as vehicle_rental_rental_agreement_number,
    rd.renter_name as vehicle_rental_renter_name,
    rd.rental_return_city as vehicle_rental_rental_return_city,
    rd.rental_return_state_province as vehicle_rental_rental_return_state_province,
    rd.rental_return_country as vehicle_rental_rental_return_country,
    rd.rental_rate_indicator as vehicle_rental_rental_rate_indicator,
    rd.insurance_indicator as vehicle_rental_insurance_indicator,
    rd.vehicle_check_out_city as vehicle_rental_vehicle_check_out_city,
    rd.vehicle_check_out_state_province as vehicle_rental_vehicle_check_out_state_province,
    rd.vehicle_check_out_country as vehicle_rental_vehicle_check_out_country,
    rd.rental_class as vehicle_rental_rental_class,
    rd.corporate_identifier as vehicle_rental_corporate_identifier,
    rd.no_show_indicator as vehicle_rental_no_show_indicator,
    rd.customer_service_toll_free_800_number as vehicle_rental_customer_service_toll_free_800_number,
    rd.vehicle_return_location as vehicle_rental_vehicle_return_location,
    rd.check_out_date as vehicle_rental_check_out_date,
    rd.rental_return_date as vehicle_rental_rental_return_date,

    ----------------- Estimate days rented logic -----------------
    datediff(day, vehicle_rental_check_out_date, vehicle_rental_rental_return_date)
        as vehicle_rental_days_rented_estimated,
    ---------------------------------------------------------------

    rd._es_update_timestamp as vehicle_rental_es_update_timestamp,

    -- Airline fields (prefixed with airline_)
    ad.sequence_number as airline_sequence_number,
    ad.total_fare as airline_total_fare,
    ad.ticket_number as airline_ticket_number,
    ad.source_file as airline_source_file,
    ad.passenger_name as airline_passenger_name,
    ad.maintenance_code as airline_maintenance_code,
    ad.issuing_carrier as airline_issuing_carrier,
    ad.travel_agency_name as airline_travel_agency_name,
    ad.travel_agency_code as airline_travel_agency_code,
    ad.customer_code as airline_customer_code,
    ad.issue_date as airline_issue_date,
    ad._es_update_timestamp as airline_es_update_timestamp,

    -- Lodging fields (prefixed with lodging_)
    ld.sequence_number as lodging_sequence_number,
    ld.customer_service_toll_free_800_num as lodging_customer_service_toll_free_800_num,
    ld.property_phone_num as lodging_property_phone_num,

    ----------------- Estimate Nights Stayed logic -----------------
    datediff(day, ld.arrival_date, ld.departure_date) as lodging_estimated_nights_stayed_arrival_departure,
    dt.transaction_amount / ld.room_rate_amount as lodging_estimated_nights_stayed_price_based,
    --------------------------------------------------------------

    ld.total_room_nights as lodging_total_room_nights,
    ld.room_rate_amount as lodging_room_rate_amount,
    ld.total_room_tax as lodging_total_room_tax,
    ld.source_file as lodging_source_file,
    ld.maintenance_code as lodging_maintenance_code,
    ld.folio_num as lodging_folio_num,
    ld.arrival_date as lodging_arrival_date,
    ld.departure_date as lodging_departure_date,
    ld.approval_date as lodging_approval_date,
    ld._es_update_timestamp as lodging_es_update_timestamp

from {{ ref("stg_analytics_credit_card__citi_daily_transactions") }} as dt
    left join {{ ref("stg_analytics_credit_card__citi_vehicle_rental_detail") }} as rd
        on dt.transaction_id = rd.transaction_id
    left join {{ ref("stg_analytics_credit_card__citi_airline_ticket_detail") }} as ad
        on dt.transaction_id = ad.transaction_id
    left join {{ ref("stg_analytics_credit_card__citi_lodging_detail") }} as ld
        on dt.transaction_id = ld.transaction_id
