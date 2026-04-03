{{
    config(
        materialized='view'
    )
}}
select
    cp.project_id,
    cp.project_code,
    cp.project_name,
    cp.market_id,
    bdc.division_code,
    bdc.division_name,
    coalesce(cba.budget_amount, 0) as budget_amount
from {{ ref("stg_analytics_retool__cip_projects") }} as cp
    cross join {{ ref("stg_analytics_retool__cip_budget_division_codes") }} as bdc
    left join {{ ref("stg_analytics_retool__cip_budget_amounts") }} as cba
        on cp.project_id = cba.project_id
            and bdc.division_code = cba.division_code
