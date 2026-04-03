with costs as (

    select * from {{ ref('int_asset4000_asset_costs') }}

)

, assets_that_are_eligible_to_further_depreciate as (

    select * from costs
    where 
        latest_depreciation_date_rank = 1
        and nbv != 0 -- asset codes with 0 nbv cannot further depreciate
        and period_depreciation_expense != 0 -- asset codes with 0 depreciation for that period cannot further depreciate
        and gbv != 0 -- asset codes with 0 gbv cannot further depreciate
        and is_asset_disposed != TRUE -- assets that have been disposed cannot further depreciate

)

-- Remaining depreciation = GAAP life − months used (as of last depreciation)

, future_depreciation_dates as (
    select
        a.asset_code,
        last_day(series::date) as depreciation_date
    from assets_that_are_eligible_to_further_depreciate a
    cross join
        table(
            es_warehouse.public.generate_series(
                date_trunc(month, depreciation_date)::timestamp_tz,
                dateadd(month, round(a.useful_life_months - a.max_asset_life_used_months, 1) -- round to 1 decimal point. not doing so will result in incorrect # of depreciation months
                , a.depreciation_date)::timestamp_tz,
                'month'
                )
            ) as t
)

, union_as4k_future_depreciation_dates_together as (

    select
        asset_code
        , depreciation_date
    from costs

    union -- remove duplicates

    select
        asset_code
        , depreciation_date
    from future_depreciation_dates

)

select
    *
    , row_number() over(partition by asset_code order by depreciation_date asc) - 1 as month_number -- depreciation month count per asset (apply half-period depreciation at 1st/last). Depreciation starts at month 0 , hence the -1
from union_as4k_future_depreciation_dates_together
