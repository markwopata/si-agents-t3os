select
    ea.equipment_assignment_id,
    ea.asset_id,
    ea.rental_id,
    ec.company_id is not null as is_intercompany,
    ea.drop_off_delivery_id,
    ea.return_delivery_id,
    ea.date_start,
    ea.next_date_start,
    ea.date_end,
    ea.date_created,
    ea.date_updated,
    ea.rental_duration,
    -- Assign a descending row number to get a count on the number of assets assigned to the rental in a single day.
    -- Assets switched on rentals = asset swaps. This logic gets us the last assignment for a rental on a day. We use
    -- this later on to prevent double counting assets that have been swapped for on rent fleet.
    row_number() over (partition by ea.rental_id, date_trunc(day, ea.date_start) order by ea.date_start desc)
    = 1 as is_last_assignment_on_day,
    ea._es_update_timestamp
from {{ ref("stg_es_warehouse_public__equipment_assignments") }} as ea
    inner join {{ ref("stg_es_warehouse_public__rentals") }} as r
        on ea.rental_id = r.rental_id
    inner join {{ ref("stg_es_warehouse_public__orders") }} as o
        on r.order_id = o.order_id
    inner join {{ ref("stg_es_warehouse_public__users") }} as u
        on o.user_id = u.user_id
    left join {{ ref("stg_analytics_public__es_companies") }} as ec
        on u.company_id = ec.company_id
            and ec.owned
