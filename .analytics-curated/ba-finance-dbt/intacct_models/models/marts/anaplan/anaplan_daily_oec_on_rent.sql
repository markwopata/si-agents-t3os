select
    daily_timestamp,
    sum(oec_on_rent) as oec_on_rent,
    sum(total_units) as total_units
from {{ ref('int_asset_historical') }}
group by
    all
order by daily_timestamp desc
