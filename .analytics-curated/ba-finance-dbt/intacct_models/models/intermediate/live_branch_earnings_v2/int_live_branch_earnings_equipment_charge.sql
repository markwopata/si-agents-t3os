with filter_dates as (
    select dateadd(ms, -1, dateadd(day, 1, max(date))) as gl_date
    from {{ ref("dim_date") }}
    where
        date >= '{{ live_be_start_date() }}'
        and date < current_date
    group by year, month
),

first_rental_assignment_date as (
    select
        min(sar.date_start) as first_rental_assignment_date,
        sar.asset_id
    from {{ ref("stg_es_warehouse_scd__scd_asset_rsp") }} as sar
    group by sar.asset_id
),

first_inventory_assignment_date as (
    select
        min(sai.date_start) as first_inventory_assignment_date,
        sai.asset_id
    from {{ ref("stg_es_warehouse_scd__scd_asset_inventory") }} as sai
    group by sai.asset_id
),

asset_company as (
    select
        fd.gl_date,
        sac.asset_id
    from {{ ref("stg_es_warehouse_scd__scd_asset_company") }} as sac
        inner join {{ ref("stg_analytics_public__es_companies") }} as esc
            on sac.company_id = esc.company_id
        inner join filter_dates as fd
            on fd.gl_date between sac.date_start and sac.date_end
    where esc.rental_fleet
),

rental_asset_data as (
    select
        fd.gl_date,
        frad.first_rental_assignment_date,
        sar.asset_id,
        sar.rental_branch_id as market_id
    from {{ ref("stg_es_warehouse_scd__scd_asset_rsp") }} as sar
        inner join filter_dates as fd
            on fd.gl_date between sar.date_start and sar.date_end
        inner join first_rental_assignment_date as frad
            on sar.asset_id = frad.asset_id
),

inventory_asset_data as (
    select
        fd.gl_date,
        fiad.first_inventory_assignment_date,
        sai.asset_id,
        sai.inventory_branch_id as market_id
    from {{ ref("stg_es_warehouse_scd__scd_asset_inventory") }} as sai
        inner join filter_dates as fd
            on fd.gl_date between sai.date_start and sai.date_end
        inner join first_inventory_assignment_date as fiad
            on sai.asset_id = fiad.asset_id
        inner join asset_company as ac
            on sai.asset_id = ac.asset_id
                and fd.gl_date = ac.gl_date
),

combine_rental_inventory_branch as (
    select
        coalesce(rad.first_rental_assignment_date, iad.first_inventory_assignment_date)
            as first_assignment_date,
        coalesce(rad.market_id, iad.market_id) as market_id,
        coalesce(rad.asset_id, iad.asset_id) as asset_id,
        coalesce(rad.gl_date, iad.gl_date) as gl_date
    from rental_asset_data as rad
        full outer join inventory_asset_data as iad
            on rad.asset_id = iad.asset_id
                and rad.gl_date = iad.gl_date
),

received_assets as (
    select
        cpoli.asset_id,
        cpoli.order_status
    from {{ ref('stg_equipmentshare_public__company_purchase_order_line_items') }} as cpoli
    qualify row_number()
            over (
                partition by cpoli.asset_id
                order by cpoli._company_purchase_order_line_items_effective_start_utc_datetime desc
            )
        = 1
),

include_only_received_assets as (
    select
        crib.first_assignment_date,
        crib.market_id,
        crib.asset_id,
        crib.gl_date
    from combine_rental_inventory_branch as crib
        left join received_assets as ra
            on crib.asset_id = ra.asset_id
    where
        ra.order_status is null
        or ra.order_status = 'Received'
),

output as (
    select
        iora.asset_id,
        iora.market_id,
        date_trunc(month, iora.gl_date) as gl_month,
        date_trunc(month, iora.first_assignment_date) as first_assignment_month,
        aa.oec as original_equipment_cost,
        (gl_month = first_assignment_month) as is_grace_period
    from include_only_received_assets as iora
        inner join {{ ref("int_assets") }} as aa
            on iora.asset_id = aa.asset_id
        inner join {{ ref("market") }} as m
            on iora.market_id = m.child_market_id
)

select
    market_id,
    'IBAB' as account_number,
    'Asset ID | Historical Asset Market' as transaction_number_format,
    asset_id || '|' || market_id as transaction_number,
    'Equipment Payment - Asset ID: ' || asset_id as description,
    gl_month as gl_date,
    'Asset ID' as document_type,
    asset_id::varchar as document_number,
    null as url_sage,
    null as url_concur,
    'https://admin.equipmentshare.com/#/home/assets/asset/' || asset_id as url_admin,
    null as url_t3,
    iff(is_grace_period = true, 0, round(original_equipment_cost * {{ var("equip_factor") }} * -1, 2)) as amount,
    object_construct(
        'asset_id', asset_id,
        'original_equipment_cost', original_equipment_cost
    ) as additional_data,
    'ANALYTICS' as source,
    'Equipment Charge' as load_section,
    '{{ this.name }}' as source_model
from output
where amount is not null
