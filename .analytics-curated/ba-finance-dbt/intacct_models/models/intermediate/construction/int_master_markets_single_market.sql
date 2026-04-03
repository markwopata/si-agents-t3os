select mmb.*
from {{ ref('master_markets_board') }} as mmb
where mmb.market_id is not null
    -- Assume we don't need to show dead deals in budget entry/classification.
    and mmb.grouping_name != 'Dead Deals'
-- The same market id can show up multiple times. Maybe they start a project and then don't find a suitable property
-- There are also secondary construction projects done for some already established sites.
qualify
    row_number()
        over (
            partition by mmb.market_id
            order by mmb.is_active_project desc, mmb.last_updated_date desc
        )
    = 1
