select
    date_trunc(month, afs.date::date)::date as period_start_date,
    case
        when year(afs.purchase_date::date) not between 1900 and year(current_date)+1 then null -- can't be < 1900 or > current year
        else date_trunc(month, afs.purchase_date::date)::date
    end as purchase_month,
    round(sum(afs.oec), 2) as oec,
    round(sum(datediff('month', coalesce(afs.first_rental::date, afs.date)::date, afs.date) * afs.oec), 2)
        as weighted_age_numerator,
    round(
        sum(datediff('month', coalesce(afs.first_rental::date, afs.date)::date, afs.date) * afs.oec)
        / nullifzero(sum(afs.oec)),
        1
    ) as weighted_age,
    afs.company_id,
    afs.market_id,
    c.company_name as owning_company_name,
    case
        when afs.category in ('Owned Rental OEC', 'Owned Rolling Stock OEC') then 'EquipmentShare Owned'
        when
            afs.category in ('Contractor Owned OEC', 'Payout Program Enrolled OEC', 'Payout Program Unpaid OEC')
            then 'Own Program'
        when afs.category = 'Operating Lease OEC' then 'Operating Lease'
        else 'Unknown Category'
    end as asset_ownership,
    ia.category as asset_category,
    coalesce(fsm.mix_group, 'Gen Rent') as rental_type,
    md5(
        concat(
            afs.date,
            coalesce(date_trunc(month, afs.purchase_date::date)::date, '9999-12-31'),
            afs.company_id,
            coalesce(afs.market_id, 0),
            asset_ownership,
            coalesce(asset_category, 'NO ASSET CATEGORY'),
            rental_type
        )
    ) as pk_afs_id -- coalesce ensures md5 is stable; concat() would return NULL if market_id / purchase_date is NULL
from {{ ref('stg_analytics_public__asset_financing_snapshots') }} as afs
    inner join {{ ref("int_assets") }} as ia -- TODO this needs to be static with historical data
        on afs.asset_id = ia.asset_id
    inner join {{ ref("stg_es_warehouse_public__companies") }} as c
        on afs.company_id = c.company_id
    left join {{ ref("stg_analytics_public__fleet_specialty_mix") }} as fsm
        on ia.equipment_class_id = fsm.equipment_class_id
where afs.date >= '2022-01-01'
    and afs.category in (
        'Owned Rental OEC',
        'Owned Rolling Stock OEC',
        'Contractor Owned OEC',
        'Payout Program Enrolled OEC',
        'Payout Program Unpaid OEC',
        'Operating Lease OEC'
    )
    and afs.date = last_day(afs.date)
    and afs.oec is not null
group by all
