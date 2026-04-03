with costs as (

    select
        -- grain
        c.asset_code,
        c.depreciation_date,

        -- attributes
        sum(c.life_used) as life_used,
        sum(c.life_used * 12) as life_used_months,
        max(t.transfer_date) as transfer_date,
        max(c._fivetran_synced) as _fivetran_synced,
        sum(c.gbv) as gbv,
        sum(c.nbv) as nbv,
        sum(c.period_depreciation_expense) as period_depreciation_expense,
        sum(c.year_to_date_depreciation_expense) as year_to_date_depreciation_expense,
        row_number() over (partition by c.asset_code order by c.depreciation_date desc) as latest_depreciation_date_rank
    from {{ ref('stg_analytics_asset4000_dbo__fa_costs') }} as c
        inner join {{ ref('stg_analytics_asset4000_dbo__fa_transfers') }} as t
            on c.asset_code = t.asset_code
                and c.transfer_year = t.transfer_year
                and c.transfer_per_sequence = t.transfer_per_sequence
    where
        c.book_code = 'GAAP'
        and date_part(year, c.depreciation_date) >= 2021 -- only include 2021 onwards; earlier data isn't fully reliable
    group by
        c.asset_code,
        c.depreciation_date
),

asset_classes as (

    select
        asset_code,
        asset_class,
        asset_gl_assignment_date,
        next_gl_assignment_date
    from {{ ref('stg_analytics_asset4000_dbo__gl_asset_grps') }}

),

gaap_life_used as (

    select
        group_code as asset_class,
        useful_life_years
    from {{ ref('stg_analytics_asset4000_dbo__gl_ass_grpdetail_bk') }}
    where book_code = 'GAAP'

),

asset_disposal_date as (

    select
        asset_code,
        asset_disposal_date,
        asset_disposal_reason
    from {{ ref("stg_analytics_asset4000_dbo__fa_disposals") }}
),

add_depreciation_duration_values as (

    select
        c.asset_code,
        c.depreciation_date,
        cl.next_gl_assignment_date,
        cl.asset_gl_assignment_date,
        disp.asset_disposal_date,
        disp.asset_disposal_date is not null as is_asset_disposed,
        c.life_used,
        c.life_used_months,
        last_value(g.useful_life_years ignore nulls)
            over (
                partition by c.asset_code
                order by c.depreciation_date asc rows between unbounded preceding and current row
            )
            as useful_life_years,
        last_value(g.useful_life_years * 12 ignore nulls)
            over (
                partition by c.asset_code
                order by c.depreciation_date asc rows between unbounded preceding and current row
            )
            as useful_life_months,
        last_value(g.asset_class ignore nulls)
            over (
                partition by c.asset_code
                order by c.depreciation_date asc rows between unbounded preceding and current row
            )
            as asset_class,
        c.nbv,
        c.gbv,
        c.period_depreciation_expense,
        -- each asset’s last actual depreciation date
        max(c.depreciation_date) over (partition by c.asset_code) as max_depreciation_date,
        -- each asset’s last actual asset_life_used value
        max(c.life_used_months) over (partition by c.asset_code) as max_asset_life_used_months,
        c.latest_depreciation_date_rank
    from costs as c
        left join asset_classes as cl
            on c.asset_code = cl.asset_code
                and c.depreciation_date >= cl.asset_gl_assignment_date
                and (
                    cl.next_gl_assignment_date is null
                    or c.depreciation_date < cl.next_gl_assignment_date
                )
        left join gaap_life_used as g
            on cl.asset_class = g.asset_class
        left join asset_disposal_date as disp
            on c.asset_code = disp.asset_code

)

select * from add_depreciation_duration_values
