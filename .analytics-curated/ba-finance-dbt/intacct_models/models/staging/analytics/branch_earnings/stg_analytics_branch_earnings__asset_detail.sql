with
    source as (
        select
            *
        from {{ source('analytics_branch_earnings', 'asset_detail') }}
    )

select
    market_id,
    asset_id,
    contractor_flag,
    inventory_status,
    company_id,
    company_name,
    make,
    model,
    year,
    asset_class,
    asset_type,
    oec,
    oec as original_equipment_cost,
    gl_date,
    load_section
from source
