{{
    config(
        materialized='view',
        schema=(env_var('DBT_SCHEMA_DEV', 'default_dev_schema') if target.name == 'dev' else 'public'),
        post_hook=[
            "grant select on {{ this }} to role APP_LOOKER_PROD_ROLE",
            "grant select on {{ this }} to role APP_LOOKER_NON_PROD_ROLE"
        ]
    )
}}

select
    m.child_market_id,
    m.child_market_name,
    m.market_id,
    m.market_name,
    m.state,
    m.abbreviation,
    m.region,
    m.region_name,
    m.area_code,
    m.district,
    m.region_district,
    m._id_dist,
    m.market_type_id,
    m.market_type,
    m.is_dealership,
    m.branch_earnings_start_month,
    m.market_start_month,
    datediff(months, branch_earnings_start_month, current_date()) + 1 as current_months_open,
    current_months_open > 12 as is_current_months_open_greater_than_twelve,
    m.date_updated
from
    {{ ref('market') }} as m
