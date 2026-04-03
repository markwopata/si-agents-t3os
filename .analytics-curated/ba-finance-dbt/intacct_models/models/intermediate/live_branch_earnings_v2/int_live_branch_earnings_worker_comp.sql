with work_comp_data as (
    select
        mwcp.market_id,
        'HFAI' as account_number,
        'Market ID | GL Date' as transaction_number_format,
        mwcp.market_id || '|' || mwcp.branch_earnings_month::date as transaction_number,
        'Work Comp Insurance Premium - Trailing 12 Month Avg. '
        || {{ be_live_build_description([
            {'key': 'Total Claims Count', 'field': 'mwcp.claims_count_rolling_12mo'},
            {'key': 'Avg. Headcount Count', 'field': 'mwcp.avg_headcount_rolling_12mo'}
        ]) }} as description,
        last_day(mwcp.branch_earnings_month)::date as gl_date,
        'Market' as document_type,
        mwcp.market_id::varchar as document_number,
        null as url_sage,
        null as url_concur,
        null as url_admin,
        null as url_t3,
        mwcp.monthly_premium_charge * -1 as amount,
        object_construct() as additional_data,
        'ANALYTICS' as source,
        'Worker''s Comp Insurance' as load_section,
        '{{ this.name }}' as source_model
    from {{ ref("market_work_comp_premium_recovery") }} as mwcp
    where
        {{
            live_branch_earnings_date_filter(
                date_field="branch_earnings_month", timezone_conversion=false
            )
        }}
)

select *
from work_comp_data
