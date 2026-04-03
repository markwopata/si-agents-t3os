with dds_keys as (
    select distinct
        dds.market_id,
        cast(date_trunc('month', dds.gl_date) as date) as month_start,
        dds.account_number
    from {{ ref('stg_analytics_public__branch_earnings_dds_snap') }} as dds
),

dds_agg as (
    -- DDS (finalized months)
    select
        dds.market_id,
        cast(date_trunc('month', dds.gl_date) as date) as month_start,
        dds.account_number,
        sum(dds.amount) as amount,
        'DDS' as source
    from {{ ref('stg_analytics_public__branch_earnings_dds_snap') }} as dds
    group by dds.market_id, cast(date_trunc('month', dds.gl_date) as date), dds.account_number
),

trending_agg as (
    -- Trending - exclude months that exist in DDS via LEFT ANTI JOIN
    select
        bel.market_id,
        cast(date_trunc('month', bel.gl_date) as date) as month_start,
        bel.account_number,
        sum(bel.amount) as amount,
        'BEL' as source
    from {{ ref("int_live_branch_earnings_looker") }} as bel
        left join dds_keys
            on bel.market_id = dds_keys.market_id
                and bel.account_number = dds_keys.account_number
                and dds_keys.month_start = cast(date_trunc('month', bel.gl_date) as date)
    where dds_keys.market_id is null
    group by bel.market_id, cast(date_trunc('month', bel.gl_date) as date), bel.account_number
),

dds_trending as (
    select * from dds_agg
    union all
    select * from trending_agg
)

select
    cast(dds_trending.market_id as int) as market_id,
    mrx.market_name,
    dds_trending.month_start,
    dds_trending.account_number,
    am.account_name,
    dds_trending.amount,
    dds_trending.source
from dds_trending
    inner join {{ ref('market_region_xwalk') }} as mrx
        on cast(dds_trending.market_id as int) = mrx.market_id
    left join {{ ref("int_live_branch_earnings_account_mapping") }} as am
        on dds_trending.account_number = am.account_number
where dds_trending.month_start >= '2022-01-01'
    and dds_trending.account_number in ('5000', 'GDDA', '6310', '6311', '6302', '6305', '6327')
