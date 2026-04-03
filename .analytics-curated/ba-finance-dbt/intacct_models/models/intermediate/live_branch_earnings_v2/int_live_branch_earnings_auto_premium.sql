with auto_premium as (
    select
        mapr.market_id,
        'HFAH' as account_number,
        'Market ID | GL Date' as transaction_number_format,
        mapr.market_id || '|' || mapr.branch_earnings_month::date as transaction_number,
        'Auto Insurance Premium - Trailing 12 Month Avg. '
        || {{ be_live_build_description([
            {'key': 'Total Claims Count', 'field': 'mapr.claims_count_rolling_12mo'},
            {'key': 'Avg. Vehicle Count', 'field': 'mapr.avg_vehicle_count_rolling_12mo'}
        ]) }} as description,
        last_day(mapr.branch_earnings_month)::date as gl_date,
        'Market' as document_type,
        mapr.market_id::varchar as document_number,
        null as url_sage,
        null as url_concur,
        null as url_admin,
        null as url_t3,
        mapr.monthly_premium_charge * -1 as amount,
        object_construct() as additional_data,
        'ANALYTICS' as source,
        'Auto Insurance Premium Charge' as load_section,
        '{{ this.name }}' as source_model
    from {{ ref("market_auto_premium_recovery") }} as mapr
    where
        {{
            live_branch_earnings_date_filter(
                date_field="branch_earnings_month", timezone_conversion=false
            )
        }}
)

select *
from
    auto_premium
