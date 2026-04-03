with asset_full_depreciation_dates as (

    select * from {{ ref('int_asset4000_assets_full_depreciation_dates') }}

)


, as4k_asset_costs as (

    select * from {{ ref('int_asset4000_asset_costs') }}

)

, depreciation_start_date as (

    select * from {{ ref('stg_analytics_asset4000_dbo__gl_asset_bk') }}
    where book_code = 'GAAP'

)

, salvage_values as (

    select * from {{ ref('int_asset4000_salvage_value_calculation')}}

)

, add_values_to_date_spine as (

    select 
        a.asset_code
        , a.depreciation_date
        , start_date.asset_depreciation_start_date
        , a.month_number
        , c.nbv
        , max(a.month_number) over(partition by a.asset_code) as max_number_of_depreciation_months
        , max(c.period_depreciation_expense) over(partition by a.asset_code) as max_period_depreciation_expense
        , coalesce(c.gbv, last_value(c.gbv ignore nulls) over (partition by a.asset_code order by a.depreciation_date)) as gbv
        -- single period_depreciation_expense column: use AS4K period_depreciation_expense when present, otherwise use the most recent period_depreciation_expense
        , last_value(c.period_depreciation_expense ignore nulls) over (partition by a.asset_code order by a.depreciation_date)  as most_recent_period_depreciation_expense
        , coalesce(c.period_depreciation_expense, last_value(c.period_depreciation_expense ignore nulls) over (partition by a.asset_code order by a.depreciation_date)) as period_depreciation_expense

        , sv.salvage_value
    from asset_full_depreciation_dates a
    left join as4k_asset_costs c
        on a.asset_code = c.asset_code
        and a.depreciation_date = c.depreciation_date
    left join depreciation_start_date start_date
        on a.asset_code = start_date.asset_code
    left join salvage_values sv
        on a.asset_code = sv.asset_code
        and a.depreciation_date = sv.depreciation_date

)

select 
    -- grain
    asset_code
    , depreciation_date

    -- measures
    , gbv
    , period_depreciation_expense
    , salvage_value

    , sum(period_depreciation_expense) over (partition by asset_code order by month_number asc rows between unbounded preceding and current row) as accumulating_depreciation
    , sum(period_depreciation_expense) over (partition by asset_code, extract(year from depreciation_date) order by month_number asc rows between unbounded preceding and current row) as year_to_date_depreciation_expense

    -- a half-month depreciation is applied in the first and last months, regardless of the asset’s acquisition or sale date. period in months / years
    , (datediff(month, asset_depreciation_start_date,  depreciation_date) + 0.5)/ 12.0 as gaap_life_used_in_years

    -- single NBV column: use AS4K nbv when present, otherwise calculate gbv – accumulated depreciation for future depreciation months. capping it at the salvage_value since an asset starting from a positive nbv cannot future depreciate down to negative 
    , coalesce(nbv, greatest(gbv - accumulating_depreciation, salvage_value)) as nbv

from add_values_to_date_spine
