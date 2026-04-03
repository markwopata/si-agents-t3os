select
    md5(concat(ad.asset_id, ad.gl_date, ad.load_section)) as pk,
    ad.market_id,
    date_trunc(month, ad.gl_date)::date as gl_date,
    ad.asset_id,
    ad.make,
    ad.model,
    ad.year,
    ad.asset_class,
    ad.asset_type,
    ad.company_id,
    ad.company_name,
    case
        when ad.asset_type = 'vehicle' then 'Vehicle'
        else iah.asset_inventory_status
    end as inventory_status,
    round(ad.oec, 2) as amount,
    round(ad.oec * {{ var("equip_factor") }}, 2) as equipment_charge,
    true as is_current_asset,
    lag(ad.asset_id) over (partition by ad.asset_id order by ad.gl_date) is null as is_new_asset,
    'https://admin.equipmentshare.com/#/home/assets/asset/' || ad.asset_id::string
    || '/edit' as url_admin,
    'https://app.estrack.com/#/assets/edit/' || ad.asset_id::string as url_track,
    iah.rental_branch_id as rental_market_id,
    iah.rental_branch_name as rental_market,
    iah.inventory_branch_id as inventory_market_id,
    iah.inventory_branch_name as inventory_market,
    iah.service_branch_id as service_market_id,
    iah.service_branch_name as service_market,
    case
        when iah.rental_branch_id is null and iah.service_branch_id != iah.inventory_branch_id
            then 'Service branch doesn''t match inventory branch. Check Admin & T3. Inventory branch can be adjusted in T3'
        when iah.rental_branch_id is not null and iah.service_branch_id != iah.rental_branch_id
            then 'Service branch doesn''t match rental branch.'
    end as problem_note,
    ad.load_section
from {{ ref("stg_analytics_branch_earnings__asset_detail") }} as ad
    inner join {{ ref("int_asset_historical") }} as iah
        on ad.asset_id = iah.asset_id
            and (ad.gl_date::date + 1 - interval '1 nanosecond') = iah.daily_timestamp
-- Pick static if static and trending exist in the same month.
qualify ad.load_section = min(ad.load_section) over (partition by ad.gl_date)
