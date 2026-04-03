select
    markets.market_id,
    dds_snap.account_number,
    dds_snap.gl_date,
    date_trunc(month, dds_snap.gl_date) as gl_month,
    dds_snap.amount,
    am.* exclude (account_number),
    markets.* exclude (market_id, child_market_id, child_market_name),
    datediff(month, date_trunc(month, markets.branch_earnings_start_month::date), date_trunc(month, dds_snap.gl_date))
        as market_age_in_months
from {{ ref("stg_analytics_public__branch_earnings_dds_snap") }} as dds_snap
    inner join {{ ref("int_live_branch_earnings_account_mapping") }} as am
        on dds_snap.account_number = am.account_number
    inner join {{ ref("market") }} as markets
        on dds_snap.market_id = markets.child_market_id
where date_trunc(month, dds_snap.gl_date)::date >= dateadd(month, -1, '{{ live_be_start_date() }}')
    and date_trunc(month, dds_snap.gl_date)::date < dateadd(month, 1, '{{ last_branch_earnings_published_date() }}')
