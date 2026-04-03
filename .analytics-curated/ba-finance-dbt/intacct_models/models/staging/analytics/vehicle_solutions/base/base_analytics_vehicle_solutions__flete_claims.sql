select
    fc.claim_id,
    fc.status,
    case when fc.detailed_status = 'nan' then null else fc.detailed_status end as detailed_status,
    fc.vehicle,
    case when fc.reservation = 'nan' then null else fc.reservation end as reservation,
    case
        when fc.deductible = 'nan' then null else
            try_to_number(replace(replace(fc.deductible, '$', ''), ',', ''), 38, 2)
    end as deductible,
    case
        when fc.deductible_other = 'nan' then null else
            try_to_number(replace(replace(fc.deductible_other, '$', ''), ',', ''), 38, 2)
    end as deductible_other,
    case
        when fc.mop = 'nan' then null
        when fc.mop = 'Other' then 'Other'
        else try_to_number(replace(replace(fc.mop, '$', ''), ',', ''), 38, 2)::text
    end as mop,
    case
        when fc.mop = 'Other' then null
        else try_to_number(replace(replace(fc.mop, '$', ''), ',', ''), 38, 2)::text
    end as mop_amount,
    try_to_number(replace(replace(fc.mop_other, '$', ''), ',', '')) as mop_other,
    case
        when fc.total_paid = 'nan' then null else
            try_to_number(replace(replace(fc.total_paid, '$', ''), ',', ''), 38, 2)
    end as total_paid,
    try_to_number(replace(replace(fc.total_transactions, '$', ''), ',', ''), 38, 2) as total_transactions,
    try_to_number(replace(replace(fc.estimated_cost, '$', ''), ',', ''), 38, 2) as estimated_cost,
    coalesce(
        try_to_timestamp(fc.date_last_edited_est, 'MM/DD/YY HH24:MI'),
        try_to_timestamp(fc.date_last_edited_est)
    ) as date_last_edited_est,
    case when fc.platform = 'nan' then null else fc.platform end as platform,
    fc.fleet_name,
    fc.file_name,
    fc._es_update_timestamp
from {{ source('analytics_vehicle_solutions', 'flete_claims') }} as fc
