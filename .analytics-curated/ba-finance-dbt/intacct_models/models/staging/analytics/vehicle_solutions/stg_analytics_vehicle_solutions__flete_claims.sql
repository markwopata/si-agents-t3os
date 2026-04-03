select
    fc.claim_id,
    fc.status,
    fc.detailed_status,
    fc.vehicle,
    fc.reservation,
    fc.deductible,
    fc.deductible_other,
    fc.mop,
    fc.mop_amount,
    fc.mop_other,
    fc.total_paid,
    fc.total_transactions,
    fc.estimated_cost,
    fc.date_last_edited_est,
    fc.platform,
    fc.fleet_name,
    fc.file_name,
    fc._es_update_timestamp
from {{ ref('base_analytics_vehicle_solutions__flete_claims') }} as fc
where fc.file_name not ilike '*.xlsx'
qualify row_number()
        over (
            partition by fc.claim_id, fc.vehicle, fc.reservation
            order by fc._es_update_timestamp desc, fc.date_last_edited_est desc, fc.file_name desc
        )
    = 1
