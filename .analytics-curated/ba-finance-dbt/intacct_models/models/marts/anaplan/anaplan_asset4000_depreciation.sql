with asset4000 as (
    select
        date_trunc(month, faaf.depreciation_date) as period_start_date,
        faaf.depreciation_date,
        daa.asset_class_name,
        round(sum(faaf.nbv), 2) as nbv,
        round(sum(faaf.gbv), 2) as gbv,
        round(sum(faaf.gbv) - sum(faaf.nbv), 2) as accumulated_depreciation,
        round(sum(faaf.period_depreciation_expense), 2) as period_depreciation_expense,
        round(sum(faaf.year_to_date_depreciation_expense), 2) as year_to_date_depreciation_expense,
        round(sum(faaf.salvage_value), 2) as salvage_value,
        md5(concat(period_start_date, daa.asset_class_name)) as pk_depreciation_id
    from {{ ref('dim_asset4000_assets') }} as daa
        inner join {{ ref('fct_asset4000_asset_financials') }} as faaf
            on daa.asset_code = faaf.asset_code
                and daa.depreciation_date = faaf.depreciation_date
    group by
        all
)

select * from asset4000
