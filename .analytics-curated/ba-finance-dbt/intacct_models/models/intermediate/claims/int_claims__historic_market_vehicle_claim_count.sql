-- calculating fleet count for the given month
with monthly_vehicle_counts_per_branch as (
    select
        date_trunc(month, aho.month_end_date::date) as date_month,
        aho.market_id,
        aho.market_name,
        count(aho.asset_id) as vehicle_count
    from {{ ref('int_asset_historical_ownership') }} as aho
        inner join {{ ref('int_assets') }} as a
            on aho.asset_id = a.asset_id
            -- selecting the asset_id's market location at the end of the month
        and aho.month_end_date is not null
    where a.asset_type in ('vehicle', 'trailer')
        -- owned by EquipmentShare and EquipmentShare Forge and Build (confirmed with Mitch)
        and aho.asset_company_id in (1854, 144107)
        --       exclude corporate vehicles (Main Branch and Corporate)
        and aho.market_name not in ('Main Branch', 'Corporate')
    group by date_trunc(month, aho.month_end_date::date), aho.market_id, aho.market_name
),

-- number of accidents for a given month
claims_count as (
    select
        date_trunc('month', ru.date_of_claim::date) as date_of_claim,
        ru.market_id,
        count(ru.claim_id) as claims_count
    from {{ ref('int_claims__auto_accident_insurance_claims') }} as ru
    -- only want to include losses for assets that are vehicles or trailers
        inner join {{ ref('int_assets') }} as a
            on ru.asset_number = a.asset_id
    where a.asset_type in ('vehicle', 'trailer')
        -- only count material losses and ES being at fault
        and is_material_loss = true
        and at_fault_payer = 'ES'
    group by date_trunc('month', ru.date_of_claim::date), ru.market_id
),

rolling_functions as (
    select
        vc.date_month,
        vc.market_id,
        vc.market_name,
        -- fleet size for the month
        vc.vehicle_count,
        -- number of accidents for the month
        cc.claims_count,
        --calculate a rolling average of the fleet count for the last 12 months
        avg(vc.vehicle_count)
            over (
                partition by vc.market_id
                order by vc.date_month
                rows between 11 preceding and current row
            ) as avg_vehicle_count_rolling_12mo,
        --sum the loss count for the last 12 months        
        sum(coalesce(cc.claims_count, 0)) over (
            partition by vc.market_id
            order by vc.date_month
            rows between 11 preceding and current row
        ) as claims_count_rolling_12mo
    from monthly_vehicle_counts_per_branch as vc
        left join claims_count as cc
            on vc.date_month = cc.date_of_claim
                and vc.market_id = cc.market_id
)

select
    date_month,
    market_id,
    market_name,
    round(avg_vehicle_count_rolling_12mo, 0) as avg_vehicle_count_rolling_12mo,
    vehicle_count as monthly_vehicle_count,
    claims_count_rolling_12mo,
    coalesce(claims_count, 0) as monthly_claims_count
from rolling_functions
order by date_month desc, market_id asc
