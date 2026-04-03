/*
Allocation Basis for market hierarchy

   Background: Make a table that provides the basis for allocation for region -> market, district -> market, or national
   account -> market. Input through department_id and get back a list of markets + the allocation % to use.
   There will be a record for each month in the date_list.

   Structure:
   - Is market? (use inner join from child_market_id on market, but don't put the parent market details in)
    - just use market_id, allocation_pct = 1
   - Is district?
    - allocate to >0 markets in district

   Potential Variances:
    For some cases, we will over or under allocate
      e.g. 1/7 = 0.166667, which *7 = 1.00002
    For the purposes of live BE, we are ok with this small variance. This means this dataset should not be used
      outside of live without an added approach to cover rounding variances.
*/
with markets as (
    select distinct
        market_id,
        market_name,
        district,
        region,
        region_name,
        branch_earnings_start_month,
        is_dealership,
        market_type
    from {{ ref("market") }}
),

markets_by_department as (
    -- allocate to open markets in a district
    select
        de.department_id,
        m.market_id,
        m.branch_earnings_start_month,
        'District' as allocation_method
    from {{ ref("stg_analytics_intacct__department") }} as de
        inner join analytics.public.districts as di
            on de.department_name = 'District ' || di.district_id
        inner join markets as m
            on di.district_id = m.district
    where de.department_name ilike '%district%'
        and m.market_type != 'ITL' -- Hard exclusion of ITL, no ITL people should be at this level

    union all

    -- Allocate to open markets in a region
    select
        de.department_id,
        m.market_id,
        m.branch_earnings_start_month,
        'Region' as allocation_method
    from {{ ref("stg_analytics_intacct__department") }} as de
        inner join markets as m
            -- Department name in Sage has this format of region: R1 Pacific
            on regexp_substr(de.department_name, 'R(\\d+)', 1, 1, 'e') = m.region::text
    where de.department_name regexp 'R\\d+.*'
        and m.market_type != 'ITL' -- Hard exclusion of ITL, no ITL people should be at this level
    -- todo months open check

    union all

    -- Simply allocate markets that are markets
    select
        m.child_market_id::text as department_id,
        m.child_market_id::number as market_id, -- just use child_market_id as market_id
        m.branch_earnings_start_month,
        'Market' as allocation_method
    from {{ ref("market") }} as m

    union all

    -- Allocate to all open markets, no exclusions
    --- This includes industrial contract compliance and national fleet support
    --- Tests on this output should include 2 distinct department_ids
    --- Mark confirmed in Slack 7/3/2024
    select
        dlist.value as department_id,
        m.market_id,
        m.branch_earnings_start_month,
        case
            when dlist.value = '999995' then 'Industrial Contract Compliance - All Markets'
            when dlist.value = '999998' then 'National Fleet Support - All Markets'
            else 'Error, unknown department'
        end as allocation_method
    from lateral flatten(input => array_construct('999995', '999998')) as dlist,
        markets as m

    union all

    -- Allocate to open ITL/Tooling markets
    select
        '999996' as department_id,
        m.market_id,
        m.branch_earnings_start_month,
        'National Tooling' as allocation_method
    from markets as m
    where m.market_type = 'ITL'

    union all

    -- Allocate to open Advanced Solutions markets
    select
        '999997' as department_id,
        m.market_id,
        m.branch_earnings_start_month,
        'National Advanced Solutions' as allocation_method
    from markets as m
    where m.market_type = 'Advanced Solutions'

    union all

    -- Allocate to open Advanced Solutions markets
    select
        '999999' as department_id,
        m.market_id,
        m.branch_earnings_start_month,
        'National Equipment Sales' as allocation_method
    from markets as m
    where m.is_dealership
),

out as (
    select
        date_list.datelist::date as gl_date,
        mbd.department_id,
        mbd.market_id,
        1::number(15, 10) / count(mbd.market_id)
            over (partition by mbd.department_id, date_list.datelist::date)
        ::number(15, 10) as allocation_pct,
        mbd.allocation_method
    from markets_by_department as mbd,
        ({{ live_be_period_firstday_of_each_month() }}) as date_list
    where mbd.allocation_method = 'Market'
        or mbd.branch_earnings_start_month <= date_list.datelist::date
)

select out.*
from out
