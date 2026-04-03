with data as (
    select distinct
        sp.store_id || '-' || sp.part_id as pk_inventory_balance_id,
        current_timestamp() as timestamp,
        --  Meant to be used to get month end
        date_trunc(month, add_months(convert_timezone('UTC', 'America/Chicago', current_timestamp()), -1))::date
            as period_start_date,
        s.market_id,
        sp.store_id,
        s.store_name,
        pr.name as provider_name,
        coalesce(p.part_number, '') as part_number,
        coalesce(pt.description, '') as description,
        sp.threshold as min,
        sp.max,
        sp.quantity,
        sp.quantity as total_quantity,
        spc.cost,
        wacs.weighted_average_cost as average_cost,
        -- Based on average cost
        (sp.quantity * wacs.weighted_average_cost) as total_value,
        sp.store_part_id,
        sp.part_id,
        null as parent_store_id,
        s.is_default_store,
        m.market_name
    from {{ ref('stg_es_warehouse_inventory__store_parts') }} as sp
        inner join {{ ref('stg_es_warehouse_inventory__inventory_locations') }} as s
            on sp.store_id = s.store_id
        inner join {{ ref('stg_analytics_public__es_companies') }} as ec
            on
                s.company_id = ec.company_id
                and ec.owned
        left join {{ ref('stg_store_part_costs') }} as spc
            on
                sp.store_part_id = spc.store_part_id
                and current_timestamp() between spc.date_start and spc.date_end
        -- test integrity, should not be null, make join
        left join {{ ref('stg_es_warehouse_inventory__parts') }} as p
            on sp.part_id = p.part_id
            -- test integrity, should not be null for any part
        left join {{ ref('stg_es_warehouse_inventory__part_types') }} as pt
            on p.part_type_id = pt.part_type_id
            -- should not be null, left because parts is left
        left join {{ ref('stg_es_warehouse_inventory__providers') }} as pr
            on p.provider_id = pr.provider_id
        left join
            {{ ref('stg_es_warehouse_inventory__weighted_average_cost_snapshots') }} as wacs
            on
                sp.part_id = wacs.product_id
                and sp.store_id = wacs.inventory_location_id
                and wacs.is_current = true
        inner join {{ ref('stg_es_warehouse_public__markets') }} as m
            on s.market_id = m.market_id
    where sp.date_archived is null
)

select *
from data
-- qualify row_number() over (partition by pk_inventory_balance_id order by case when cost is not null then 1 else 0 end) = 1
