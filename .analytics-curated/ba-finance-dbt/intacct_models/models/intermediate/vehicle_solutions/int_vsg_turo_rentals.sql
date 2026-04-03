select
    tr.reservation_id,
    tr.guest,
    tr.trip_status,
    tr.trip_start,
    tr.trip_end,
    tr.trip_days,
    tr.trip_days_original,
    tr.vehicle_name,
    tr.vehicle_model,
    tr.license_plate_state,
    -- Not every turo reservation is in the supabase reservations table. 
    -- Every vehicle plate is also apparently not in the supabase database.
    coalesce(r.vehicle_vin, v.vin) as vin,
    tr.license_plate_number,
    tr.license_plate_unknown_id,
    tr.vehicle_rental_indicator,
    tr.pickup_location,
    tr.return_location,
    tr.check_in_odometer,
    tr.check_out_odometer,
    tr.distance_traveled,
    tr.trip_price,
    tr.boost_price,
    tr.discount_3_day,
    tr.discount_1_week,
    tr.discount_2_week,
    tr.discount_3_week,
    tr.discount_1_month,
    tr.discount_2_month,
    tr.discount_3_month,
    tr.early_bird_discount,
    tr.host_promotional_credit,
    tr.delivery,
    tr.excess_distance,
    tr.extras,
    tr.cancellation_fee,
    tr.additional_usage,
    tr.late_fee,
    tr.improper_return_fee,
    tr.airport_operations_fee,
    tr.tolls_and_tickets,
    tr.on_trip_ev_charging,
    tr.post_trip_ev_charging,
    tr.smoking,
    tr.cleaning,
    tr.fines_paid_to_host,
    tr.gas_reimbursement,
    tr.gas_fee,
    tr.other_fees,
    tr.non_refundable_discount,
    tr.sales_tax,
    tr.total_earnings,
    tr.file_name,
    tr.turo_account_short_code,
    ttb.market_id,
    ttb.vsg_region_id,
    im.market_name,
    tr._es_update_timestamp
from {{ ref('stg_analytics_vehicle_solutions__turo_rentals') }} as tr
    left join {{ ref('seed_vsg_turo_to_branch_mapping') }} as ttb
        on tr.turo_account_short_code = ttb.turo_account_short_code
    left join {{ ref('int_markets') }} as im
        on ttb.market_id = im.market_id
    left join {{ ref('stg_analytics_vsg_postgres__public__vehicles') }} as v
        on tr.license_plate_number = v.license_plate
            and tr.license_plate_state = v.license_plate_state
    -- Not every turo reservation is in the supabase reservations table.
    left join {{ ref('stg_analytics_vsg_postgres__public__reservations') }} as r
        on 'TURO-' || tr.reservation_id = r.platform_id
