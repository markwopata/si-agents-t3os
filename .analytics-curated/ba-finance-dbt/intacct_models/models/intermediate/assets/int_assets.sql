/*
This is a dynamic table. If you update this, you will need to full-refresh. Contact Vishesh/Erik/Loren for help.
*/
with deleted_assets as (
    select
        a1.asset_id,
        min(ap._assets_effective_start_utc_datetime) as date_deleted
    from {{ ref("stg_es_warehouse_public__assets") }} as a1
        inner join {{ ref("stg_equipmentshare_public__silver__assets_pit") }} as ap
            on a1.asset_id = ap.asset_id
                and ap.deleted
    group by a1.asset_id
),

first_rentals as (
    select
        ea.asset_id,
        min(ea.date_start) as first_rental_date,
        max(ea.date_start) as latest_rental_start_date,
        max(ea.date_end) as last_rental_date,
        max(ea.date_end) as last_off_rent_date
    from {{ ref("stg_es_warehouse_public__equipment_assignments") }} as ea
    group by ea.asset_id
),

asset_trackers as (
    select
        ata.asset_id,
        ata.tracker_id,
        ata.date_installed as tracker_install_date
    from {{ ref("stg_es_warehouse_public__asset_tracker_assignments") }} as ata
    where ata.date_installed <= current_date
        and (ata.date_uninstalled is null or ata.date_uninstalled >= current_date)
    qualify row_number() over (
            partition by ata.asset_id
            order by ata.date_installed desc
        ) = 1
),

-- The tax team uses license plate numbers in filing property tax returns.
license_plates as (
    -- Distinct because there are multiple line item IDs per asset, and we only need the license plate per asset ID.
    -- There are no assets with multiple license plates.
    select distinct
        cpoli.asset_id,
        cpoli.license_plate
    from {{ ref("stg_es_warehouse_public__company_purchase_order_line_items") }} as cpoli
    where cpoli.asset_id is not null
        and cpoli.order_status = 'Received'
),

in_transit_assets as (

    select * from {{ ref("stg_asset_transfer_public__transfer_orders") }}

)

select
    a.asset_id,
    a.asset_type_id,
    aty.name as asset_type,
    a.equipment_make_id,
    trim(coalesce(ema.name, a.make)) as make,
    a.equipment_model_id,
    trim(coalesce(emo.name, a.model)) as model, -- noqa: RF04
    a.year,
    trim(a.custom_name) as custom_name,
    a.serial_number,
    a.vin,
    coalesce(a.license_plate_number, lp.license_plate) as license_plate_number,
    coalesce(a.serial_number, a.vin) as serial_number_or_vin,
    coalesce(ec.equipment_class_id, a.equipment_class_id) as equipment_class_id,
    trim(coalesce(ec.name, a.asset_class)) as equipment_class,
    coalesce(cat.category_id, cat2.category_id) as category_id,
    coalesce(cat.name, cat2.name) as category,
    coalesce(cat_p.category_id, cat2_p.category_id) as parent_category_id,
    coalesce(cat_p.name, cat2_p.name) as parent_category_name,
    coalesce(cat.category_id, cat2.category_id) as sub_category_id,
    coalesce(cat.name, cat2.name) as sub_category_name,
    a.company_id as asset_company_id,
    c.company_name as owning_company_name,
    eco.company_id is not null as is_es_owned_company,
    a.rental_branch_id,
    mr.market_name as rental_branch_name,
    a.inventory_branch_id,
    mi.market_name as inventory_branch_name,
    a.service_branch_id,
    ms.market_name as service_branch_name,
    im.state,
    coalesce(a.rental_branch_id, a.inventory_branch_id) as market_id,
    coalesce(mr.market_name, mi.market_name) as market_name,
    coalesce(mr.company_id, mi.company_id) as market_company_id,
    eco2.company_id is not null as is_managed_by_es_owned_market,
    (
        coalesce(a.custom_name, '') ilike 'RR%'
        or coalesce(a.serial_number, '') ilike 'RR%'
        or coalesce(a.vin, '') ilike 'RR%'
        or coalesce(market_company_id, -1) = 11606 /* re-rent company */
    ) as is_rerent_asset,
    -- TRUE if asset has an active 'Approved' transfer record; defaults to FALSE for all other assets
    coalesce(ita.is_in_transit, false) as is_in_transit,
    ita.status,
    fr.first_rental_date,
    fr.latest_rental_start_date,
    fr.last_rental_date,
    fr.last_off_rent_date,
    aph.purchase_date,
    aph.invoice_number,
    coalesce(aph.original_equipment_cost, aph.purchase_price) as oec,
    ec.business_segment_id,
    bs.business_segment_name,
    ata.tracker_id,
    ata.tracker_install_date,
    a.name as description,
    ipp.payout_program_id,
    ipp.payout_program_name,
    ipp.payout_program_type_id,
    ipp.payout_program_type,
    ipp.asset_payout_percentage,
    coalesce(ipp.is_payout_program_unpaid, FALSE) as is_payout_program_unpaid, -- if the asset is not in a payout program, default to FALSE
    coalesce(ipp.is_payout_program_enrolled, FALSE) as is_payout_program_enrolled, -- if the asset is not in a payout program, default to FALSE
    ipp.payout_program_id is not null as is_own_program_asset,
    coalesce(askv.value, 'No Inventory Status') as asset_inventory_status,
    iff(is_in_transit, concat(asset_inventory_status, ' - In Transit'), asset_inventory_status)
        as inventory_transit_status,
    bvt.battery_voltage_type_id,
    bvt.name as battery_voltage_type,
    a.url_admin,
    a.url_t3,
    a.is_deleted,
    a.date_created,
    a.date_updated,
    da.date_deleted
from {{ ref("stg_es_warehouse_public__assets") }} as a
    left join deleted_assets as da
        on a.asset_id = da.asset_id
    inner join {{ ref("stg_es_warehouse_public__asset_types") }} as aty
        on a.asset_type_id = aty.asset_type_id
    left join {{ ref("stg_es_warehouse_public__equipment_models") }} as emo -- equipment_model_id can be null
        on a.equipment_model_id = emo.equipment_model_id
    -- equipment_make_id can be null. We also want to go through models to make sure we're maintaining
    -- make-model connections. This is not maintained cleanly today.
    -- Join through models xref as this is what admin uses in the front end.
    left join {{ ref("stg_es_warehouse_public__equipment_makes") }} as ema -- model can be null
        on emo.equipment_make_id = ema.equipment_make_id
    left join {{ ref("stg_es_warehouse_public__equipment_classes_models_xref") }} as ecmx -- model can be null
        on a.equipment_model_id = ecmx.equipment_model_id
    -- Pass through the xref, see above. Can be null.
    left join {{ ref("stg_es_warehouse_public__equipment_classes") }} as ec
        on ecmx.equipment_class_id = ec.equipment_class_id
    left join {{ ref("stg_es_warehouse_public__categories") }} as cat -- category_id can be null
        on ec.category_id = cat.category_id
    left join {{ ref("stg_es_warehouse_public__categories") }} as cat2 -- category_id can be null
        on a.category_id = cat2.category_id
    -- Parent category for eqp_class/cat1's category. Note: cat.category_id can be null
    left join {{ ref("stg_es_warehouse_public__categories") }} as cat_p
        on cat.parent_category_id = cat_p.category_id
    -- Parent category for assets/cat2's category. Note: cat2.category_id can be null
    left join {{ ref("stg_es_warehouse_public__categories") }} as cat2_p
        on cat2.parent_category_id = cat2_p.category_id
    left join {{ ref("stg_es_warehouse_public__business_segments") }} as bs
        on ec.business_segment_id = bs.business_segment_id
    inner join {{ ref("stg_es_warehouse_public__companies") }} as c
        on a.company_id = c.company_id
    left join {{ ref("stg_es_warehouse_public__markets") }} as mr -- can be null
        on a.rental_branch_id = mr.market_id
    inner join {{ ref("stg_es_warehouse_public__markets") }} as mi -- always populated
        on a.inventory_branch_id = mi.market_id
    inner join {{ ref("stg_es_warehouse_public__markets") }} as ms -- always populated
        on a.service_branch_id = ms.market_id
    left join {{ ref("stg_analytics_public__es_companies") }} as eco
        on a.company_id = eco.company_id
            and eco.owned
    left join {{ ref("stg_analytics_public__es_companies") }} as eco2
        on coalesce(mr.company_id, mi.company_id) = eco2.company_id
            and eco2.owned
    left join first_rentals as fr
        on a.asset_id = fr.asset_id
    left join {{ ref("stg_es_warehouse_public__asset_purchase_history") }} as aph
        on a.asset_id = aph.asset_id
    inner join {{ ref("int_markets") }} as im
        on coalesce(mr.market_id, mi.market_id) = im.market_id
    left join asset_trackers as ata
        on a.asset_id = ata.asset_id
    left join {{ ref("int_payout_programs") }} as ipp
        on a.asset_id = ipp.asset_id
            and current_timestamp between ipp.date_start and ipp.date_end
    left join license_plates as lp
        on a.asset_id = lp.asset_id
    left join {{ ref("stg_es_warehouse_public__asset_status_key_values") }} as askv
        on a.asset_id = askv.asset_id
            and askv.name = 'asset_inventory_status'
    left join in_transit_assets as ita
        on a.asset_id = ita.asset_id
            and ita.is_in_transit = true -- only include assets currently in transit (status = 'Approved')
    left join {{ ref("stg_es_warehouse_public__battery_voltage_types") }} as bvt
        on a.battery_voltage_type_id = bvt.battery_voltage_type_id
