select
    spc.store_part_id,
    spc.store_part_cost_id,
    spc.cost,
    spc.date_archived,
    spc.date_created,
    coalesce(lag(spc.date_archived)
        over (
            partition by spc.store_part_id
            order by spc.date_archived, spc.store_part_cost_id
        ),
    0::timestamp_ntz)::timestamp_ntz as date_start,
    coalesce(case
        -- If for some reason, there are 2 null date_archived, use the second date_created as date_archived
        when lead(spc.date_archived) over (
                partition by spc.store_part_id
                order by spc.date_created
            ) is null
            and spc.date_archived is null
            then lead(spc.date_created) over (
                    partition by spc.store_part_id
                    order by spc.date_created
                )
        else spc.date_archived
    end, '2099-12-31'::timestamp_ntz) as date_end
from {{ ref("stg_es_warehouse_inventory__store_part_costs") }} as spc
