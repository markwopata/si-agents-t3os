{{
    config(
        schema='credit_card'
    )
}}

select
    concat(atd.transaction_id, '-', atd.ticket_number, '-', coalesce(atl.trip_leg_number, '000'))
        as transaction_leg_number,
    atd.transaction_id,
    atd.ticket_number,
    atl.trip_leg_number,
    atd.sequence_number as ticket_sequence_number,
    atd.total_fare,
    atd.source_file as ticket_source_file,
    atd.passenger_name as ticket_passenger_name,
    atd.maintenance_code as ticket_maintenance_code,
    atd.issuing_carrier as ticket_issuing_carrier,
    atd.travel_agency_name as ticket_travel_agency_name,
    atd.travel_agency_code as ticket_travel_agency_code,
    atd.customer_code as ticket_customer_code,
    atd.issue_date as ticket_issue_date,
    atd._es_update_timestamp as ticket_update_timestamp,
    atl.sequence_number as trip_leg_sequence_number,
    atl.coupon_number as trip_leg_coupon_number,
    atl.flight_number as trip_leg_flight_number,
    atl.source_file as trip_leg_source_file,
    atl.ticket_number as trip_leg_ticket_number,
    atl.maintenance_code as trip_leg_maintenance_code,
    atl.city_of_origin as trip_leg_city_of_origin,
    atl.city_of_destination as trip_leg_city_of_destination,
    atl.carrier_code as trip_leg_carrier_code,
    atl.service_class as trip_leg_service_class,
    atl.stop_over_indicator as trip_leg_stop_over_indicator,
    atl.fare_base_code as trip_leg_fare_base_code,
    atl.conjunction_ticket as trip_leg_conjunction_ticket,
    atl.travel_date as trip_leg_travel_date,
    atl.departure_time as trip_leg_departure_time,
    atl.arrival_time as trip_leg_arrival_time,
    atl._es_update_timestamp as trip_leg_update_timestamp
from {{ ref("stg_analytics_credit_card__citi_airline_ticket_detail") }} as atd
    left join {{ ref("stg_analytics_credit_card__citi_airline_trip_leg_detail") }} as atl
        on atd.transaction_id = atl.transaction_id
