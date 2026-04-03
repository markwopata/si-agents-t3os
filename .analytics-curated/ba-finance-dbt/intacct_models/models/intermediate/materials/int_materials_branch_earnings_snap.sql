select *
from {{ source('analytics_public', 'branch_earnings_dds_snap') }} as be
    left join {{ ref('market_region_xwalk') }} as mrx
        on be.mkt_id = mrx.market_id
where mrx.market_type = 'Materials'
