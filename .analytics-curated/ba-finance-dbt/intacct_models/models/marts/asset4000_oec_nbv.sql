with asset_list as (
    select * from {{ ref('int_asset4000_asset_list') }}
    where coalesce(asset_account, '') not in ('1508', '1518', '1619', '')
    -- excluding these accounts b/c:
    -- 1508 is telematics so we can’t include due tracker #s.
    -- 1518 lease child assets so no mainmover in asset4K
    -- 1619 is old finance leased data tht really we’d like to delete but keep for record
)


, get_nbv as (
    select 
        l.asset_code
        , l.asset_account
        , l.admin_asset_id
        , c.depreciation_date
        , c.nbv
        , c.oec
    from asset_list l
    left join {{ ref('int_asset4000_calculate_nbv')}} c
        on c.asset_code = l.asset_code
    where c.asset_code in (
            select asset_code from asset_list
    )
    and c.book_code = 'GAAP'
    and (c.oec != 0 or c.nbv != 0 or c.period_depreciation_expense != 0)
    and not c._fivetran_deleted

)


select 
    admin_asset_id
    , depreciation_date
    , sum(oec) as asset4000_original_cost
    , sum(nbv) as asset4000_net_book_value
from get_nbv
where admin_asset_id > 0
group by 
    all