with lost_stolen_destroyed_assets as (
    select
        scd_asset_company.asset_id,
        scd_asset_company.date_start::date as gl_date,
        scd_asset_company.company_id,
        scd_asset_company.company_id in (32367, 31712, 32365)
        and lead(scd_asset_company.company_id)
            over (partition by scd_asset_company.asset_id order by scd_asset_company.date_start desc)
        = 1854 as is_lsd,
        assets_aggregate.original_equipment_cost,
        assets_aggregate.asset_type,
        assets_aggregate.first_rental_date,
        assets_aggregate.purchase_date,
        assets_aggregate.date_created,
        scd_asset_company.date_start as scd_company_date_start
    from {{ ref("stg_es_warehouse_scd__scd_asset_company") }} as scd_asset_company
        inner join {{ ref('stg_es_warehouse_public__assets_aggregate') }} as assets_aggregate
            on scd_asset_company.asset_id = assets_aggregate.asset_id
    qualify is_lsd
),

assets_on_sales_invoices as (
    select distinct asset_id as exclude_asset_ids
    from {{ ref('stg_es_warehouse_public__line_items') }}
    where (
        line_item_type_id in ({{ live_be_retail_sales_line_item_type_ids() }})
        or line_item_type_id in ({{ live_be_core_sales_line_item_type_ids() }})
    )
    and asset_id is not null
),

output as (
    select
        scd_inventory.inventory_branch_id as market_id,
        'GDCC' as account_number,
        'Asset ID' as transaction_number_format,
        lsd.asset_id::varchar as transaction_number,
        'Asset ID: '
        || lsd.asset_id
        || ' Moved to Lost, Stolen, Destroyed Company ID: '
        || lsd.company_id as description,
        lsd.gl_date,
        '' as document_type,
        '' as document_number,
        '' as url_sage,
        '' as url_concur,
        'https://admin.equipmentshare.com/#/home/assets/asset/' || lsd.asset_id as url_admin,
        '' as url_t3,
        coalesce(
            nbv.nbv,
    {{
        calculate_nbv(
            "original_equipment_cost",
            "asset_type",
            "first_rental_date",
            "purchase_date",
            "date_created",
            "scd_company_date_start",
        )
    }}) * -1 as amount,
        object_construct(
            'asset_id', lsd.asset_id,
            'original_equipment_cost', lsd.original_equipment_cost
        ) as additional_data,
        'ES_WAREHOUSE' as source,
        'Lost, Stolen, Destroyed Assets' as load_section,
        '{{ this.name }}' as source_model
    from lost_stolen_destroyed_assets as lsd
        inner join {{ ref("stg_es_warehouse_scd__scd_asset_inventory") }} as scd_inventory
            on lsd.asset_id = scd_inventory.asset_id
                and gl_date between
                scd_inventory.date_start and scd_inventory.date_end
        left join {{ ref('int_live_branch_earnings_asset4000_nbv') }} as nbv
            on lsd.asset_id = nbv.asset_id and date_trunc(month, lsd.gl_date) = nbv.join_date
    where lsd.asset_id not in (select exclude_asset_ids from assets_on_sales_invoices)
)

select * from output
where amount != 0
    and amount is not null
