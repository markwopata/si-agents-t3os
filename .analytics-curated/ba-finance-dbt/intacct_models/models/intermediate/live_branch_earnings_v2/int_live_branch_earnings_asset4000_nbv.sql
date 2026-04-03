select
    afk.admin_asset_id as asset_id,
    afk.depreciation_date,
    dateadd(month, 1, date_trunc(month, afk.depreciation_date)) as join_date,
    sum(afk.nbv_estimated_book_value) as nbv
from {{ ref('asset4000_las_assets') }} as afk
where afk.source = 'Asset4000'
    and afk.asset_account != 1508 -- Exclude Telematics
    and afk.admin_asset_id is not null
group by all
