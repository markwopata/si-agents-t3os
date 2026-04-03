with historical_asset_ownership as (
    select
        iaho.asset_id,
        iaho.daily_timestamp::date as transfer_date,
        iaho.market_id,
        iaho.market_name,
        -- get the previous market id and asset inventory status, to signify a change in asset ownership
        lag(iaho.market_id)
            over (partition by iaho.asset_id order by iaho.daily_timestamp desc) as market_id_lead,
        iaho.asset_inventory_status as asset_inventory_status_as_transferred
    from {{ ref("int_asset_historical_ownership") }} as iaho
    --                                     just working with last 2 years of data
    where iaho.daily_timestamp >= dateadd(year, -2, current_timestamp())
    -- only looking at ES-Owned or OWN program assets
        and iaho.is_managed_by_es_owned_market = true
),

total_oec as (
    select
        hao.asset_id,
        ia.oec,
        hao.transfer_date,
        hao.market_id,
        m_c.market_name,
        hao.market_id_lead as next_market_id,
        m_n.market_name as next_market_name,
        hao.asset_inventory_status_as_transferred,
        datediff(month, mr.branch_earnings_start_month, hao.transfer_date) + 1 as receiver_market_be_age,
        not coalesce(
            datediff(month, mr.branch_earnings_start_month, hao.transfer_date) + 1 > 12,
            false
        ) as is_new_market
    from historical_asset_ownership as hao
        -- only include the receiving markets that are in market region xwalk
        inner join {{ ref("market_region_xwalk") }} as m_n
            on hao.market_id_lead = m_n.market_id
            -- only select the sender markets that are in market region xwalk
        inner join {{ ref("market_region_xwalk") }} as m_c
            on hao.market_id = m_c.market_id
        left join {{ ref("int_assets") }} as ia
            on hao.asset_id = ia.asset_id
        -- addin BE start month date of branch the asset is being transfered to
        left join {{ ref("stg_analytics_gs__market_rollout") }} as mr
            on hao.market_id_lead = mr.market_id
    -- table should only show date it changed markets
    where hao.market_id_lead != hao.market_id
)

select *
from total_oec
