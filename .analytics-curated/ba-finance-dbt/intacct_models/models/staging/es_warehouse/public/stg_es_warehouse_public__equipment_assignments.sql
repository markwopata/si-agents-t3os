select

    -- ids
    ea.equipment_assignment_id,
    ea.asset_id,
    ea.rental_id,
    ea.drop_off_delivery_id,
    ea.return_delivery_id,

    -- dates
    ea.start_date as date_start,
    lead(ea.start_date) over (
        partition by ea.asset_id
        order by ea.start_date
    ) as next_date_start,
    case
        when next_date_start < ea.end_date then next_date_start
        else ea.end_date
    end as date_end,
    ea.date_created,
    ea.date_updated,

    -- numerics 
    datediff('minutes', date_start, date_end) as rental_duration,

    -- timestamps
    ea._es_update_timestamp
from {{ ref('base_es_warehouse_public__equipment_assignments') }} as ea
