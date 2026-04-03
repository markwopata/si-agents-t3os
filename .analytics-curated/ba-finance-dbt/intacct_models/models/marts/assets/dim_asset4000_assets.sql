with assets as (

   select * from {{ ref('int_asset4000_assets_full_depreciation_dates') }}

)

, asset_details as (

    select
        asset_code
        , asset_title
        , asset_purchase_date
        , asset_capitalized_date
    from {{ ref('stg_analytics_asset4000_dbo__gl_asset') }}

)

, assets_most_recent_gl_assignment_date as (

    select * from {{ ref('stg_analytics_asset4000_dbo__gl_asset_grps') }} gr

)

, asset_descriptions as (

    select
        asset_code
        , sage_transaction_number
        , invoice_number
        , invoice_number_two
        , invoice_number_three
        , serial_number
        , admin_asset_id -- drops characters after the special characters denoted and casts to number
        , facility_type
        , last_modified_by
        , make
        , model
    from {{ ref('stg_analytics_asset4000_dbo__gl_asset_descs') }}
)

, asset_relevant_dates as (

    select
        asset_code
        , book_code
        , asset_expiration_date
        , asset_depreciation_start_date
    from {{ ref('stg_analytics_asset4000_dbo__gl_asset_bk') }}

)

, asset_class_descriptions as (

    select
        group_code
        , group_name
        , group_id
    from {{ ref('stg_analytics_asset4000_dbo__gl_grpcodes') }}

)

, asset_disposal_date as (

    select 
        asset_code
        , asset_disposal_date
        , asset_disposal_reason
    from {{ ref('stg_analytics_asset4000_dbo__fa_disposals') }}
)

select

    -- ids
    a.asset_code

    -- coalesce with last_value to fill columns when asset_gl_assignment_date has gaps
    , coalesce(g.market_id, last_value(g.market_id ignore nulls) over (partition by a.asset_code order by a.depreciation_date)) as market_id
    , a.depreciation_date
    , coalesce(g.asset_account, last_value(g.asset_account ignore nulls) over (partition by a.asset_code order by a.depreciation_date)) as asset_account
    , coalesce(g.accumulated_depreciation_account, last_value(g.accumulated_depreciation_account ignore nulls) over (partition by a.asset_code order by a.depreciation_date)) as accumulated_depreciation_account
    , coalesce(g.depreciation_expense_account, last_value(g.depreciation_expense_account ignore nulls) over (partition by a.asset_code order by a.depreciation_date)) as depreciation_expense_account
    , ad.serial_number
    , ad.sage_transaction_number
    , ad.admin_asset_id

    -- strings
    , 'Asset4000' as source
    , d.asset_title
    , g.address
    , coalesce(g.asset_class, last_value(g.asset_class ignore nulls) over (partition by a.asset_code order by a.depreciation_date)) as asset_class
    , coalesce(acd.group_name, last_value(acd.group_name ignore nulls) over (partition by a.asset_code order by a.depreciation_date)) as asset_class_name
    , ad.facility_type
    , ad.last_modified_by
    , ad.make
    , ad.model
    , ad.invoice_number
    , ad.invoice_number_two
    , ad.invoice_number_three
    , dd.asset_disposal_reason
    -- booleans
    -- dates
    , dd.asset_disposal_date
    

    -- timestamps
    , d.asset_purchase_date
    , d.asset_capitalized_date
    , g.asset_gl_assignment_date
    , da.asset_expiration_date
    , da.asset_depreciation_start_date

from assets a
left join assets_most_recent_gl_assignment_date g
    on a.asset_code = g.asset_code
    and a.depreciation_date between last_day(g.asset_gl_assignment_date) and last_day(coalesce(g.next_gl_assignment_date - interval '1 nanosecond', '9999-12-31')) -- subtract 1 nanosecond since next_gl_assignment_date and asset_gl_assignment_date start at the same time
inner join asset_details d
    on a.asset_code = d.asset_code
inner join asset_descriptions ad
    on a.asset_code = ad.asset_code
inner join asset_relevant_dates da
    on a.asset_code = da.asset_code
    and da.book_code = 'GAAP'
left join asset_class_descriptions acd
    on g.asset_class = acd.group_code
    and acd.group_id = 2 -- Filtering to group_id 2 to use this specific group_code
left join asset_disposal_date dd
    on dd.asset_code = a.asset_code
    and last_day(asset_disposal_date) >= a.depreciation_date

-- currently joining every record whose asset_gl_assignment_date ≤ depreciation_date, but without QUALIFY we’ll get one output row for each matching event (fan‐out)
qualify row_number() over (partition by a.asset_code, a.depreciation_date order by g.asset_gl_assignment_date desc nulls last) = 1
