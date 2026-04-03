with asset_full_depreciation_dates as (

    select * from {{ ref('int_asset4000_assets_full_depreciation_dates') }}

)

, original_salvage_values as (

    select
      asset_code,
      asset_residual_value as original_salvage_value
    from {{ ref('stg_analytics_asset4000_dbo__gl_asset_bk') }}
    where book_code = 'GAAP'

),

revalued_assets as (
  select
    r.asset_code,
    r.revaluation_month_end,
    b.revaluation_previous_salvage_value,
    b.revaluation_revalued_salvage_value,
  from {{ ref('stg_analytics_asset4000_dbo__fa_revaluations') }} r
  left join {{ ref('stg_analytics_asset4000_dbo__fa_revaluations_bk') }} b
    on r.asset_code = b.asset_code
    and r.revaluation_year = b.revaluation_year
    and b.book_code = 'GAAP'
  where r.revaluation_reason != 'Update Minimum NBV'

)

select
    -- grain
    ad.asset_code,
    ad.depreciation_date,

    -- dates
    re.revaluation_month_end,

    -- numerics
    og.original_salvage_value,
    re.revaluation_previous_salvage_value,
    re.revaluation_revalued_salvage_value,
    coalesce(
      case
        when re.revaluation_month_end is null then og.original_salvage_value -- 1) never revalued at all
        when ad.depreciation_date <= re.revaluation_month_end then re.revaluation_previous_salvage_value -- 2) date up through the revaluation date, use the previous salvage value
        else re.revaluation_revalued_salvage_value -- 3) date _after_ the revaluation date
      end
    , 0) as salvage_value
from asset_full_depreciation_dates ad
left join original_salvage_values og
    on ad.asset_code = og.asset_code
left join revalued_assets re
    on ad.asset_code = re.asset_code
    and re.revaluation_month_end <= ad.depreciation_date

-- joining every revaluation event whose month_end ≤ depreciation_date, but without QUALIFY we’ll get one output row for *each* matching event (fan‐out)
qualify row_number() over (partition by ad.asset_code, ad.depreciation_date order by re.revaluation_month_end desc nulls last) = 1