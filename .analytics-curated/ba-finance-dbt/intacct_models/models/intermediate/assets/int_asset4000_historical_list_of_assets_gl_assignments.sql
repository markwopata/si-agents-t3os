with month_end as (

    -- this calculates the last day of each month, starting from 2021, up to one year after the current date
    -- reasoning for 2021: earlier data isn't fully reliable https://gitlab.internal.equipmentshare.com/business-intelligence/ba-finance-dbt/-/blob/main/intacct_models/models/intermediate/assets/int_asset4000_calculations.sql?ref_type=heads#L45
    -- reasoning for up to one year after the current date: per Ethan Glick of Fixed Assets accounting, depreciation for the new year is calculated in AS4K as part of their year-end processing
    -- uses the snowflake user defined function here: https://app.snowflake.com/tczvqmq/gga45239/#/data/databases/ES_WAREHOUSE/schemas/PUBLIC/user-function/GENERATE_SERIES(TIMESTAMP_NTZ%2C%20TIMESTAMP_NTZ%2C%20VARCHAR)

    select
        last_day(series::date) as month_end
    from table(es_warehouse.public.generate_series(
            '2021-01-01'::timestamp_tz
            , date_trunc(month, add_months(current_date(), 12))::timestamp_tz,
            'month')
        ) 

)

select
    g.asset_code,
    m.month_end as asset4000_report_date,
    max(g.asset_gl_assignment_date) as max_date
from {{ ref('stg_analytics_asset4000_dbo__gl_asset_grps') }} g
inner join month_end m
    on asset_gl_assignment_date <= m.month_end
group by
    all
