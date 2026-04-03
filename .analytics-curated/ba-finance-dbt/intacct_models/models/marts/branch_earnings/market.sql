with general_manager as (
    select
        cd.market_id,
        cd.employee_id,
        cd.employee_title,
        cd.first_name,
        cd.last_name,
        coalesce(cd.nickname, cd.full_name) as general_manager_name,
        cd.position_effective_date,
        cd.work_email,
        egl.greenhouse_link
    from {{ ref("stg_analytics_payroll__company_directory") }} as cd
        left join {{ ref("employee_greenhouse_link") }} as egl
            on cd.employee_id = egl.employee_id
    where (
        cd.employee_title ilike 'General Manager%'
        or cd.employee_title in ('Interim General Manager')
        or cd.employee_title ilike '%Tool Trailer Manager%'
    )
    and cd.employee_status not in
    ('Terminated', 'Inactive', 'Never Started', 'Not In Payroll')
    qualify
        row_number()
            over (
                partition by cd.market_id
                order by cd.date_hired desc
            )
        = 1
)

select
    m.market_id::number as child_market_id,
    m.market_name as child_market_name,
    mrx_o.market_id,
    mrx_o.market_name,
    mrx_o.state,
    mrx_o.abbreviation,
    mrx_o.region,
    mrx_o.region_name,
    mrx_o.area_code,
    mrx_o.district,
    mrx_o.region_district,
    mrx_o._id_dist,
    mrx_o.market_type_id,
    mrx_o.market_type,
    mrx_o.is_dealership,
    mrx_o.date_updated,
    rmr.branch_earnings_start_month,
    rmr.market_start_month,
    rmr.market_end_month,
    gm.employee_id as general_manager_employee_id,
    gm.general_manager_name,
    gm.employee_title as general_manager_title,
    gm.greenhouse_link as general_manager_url_greenhouse,
    dm.disc_code as general_manager_disc_code,
    dm.environment_style as general_manager_environment_style,
    dm.url_disc as general_manager_url_disc,
    gm.work_email as general_manager_email,
    gm.position_effective_date as general_manager_position_effective_date,
    l.street_1,
    l.street_2,
    l.city,
    l.zip_code,
    s.abbreviation as state_abbreviation,
    l.street_1 || ', ' || l.city || ', ' || s.abbreviation || ' ' || l.zip_code as address -- Quick address
from
    {{ ref("stg_es_warehouse_public__markets") }} as m
    left join {{ ref('stg_analytics_branch_earnings__parent_market') }} as pm
        on
            m.market_id = pm.market_id
            and pm.end_date is null -- TODO should make sure this doesn't cause bugs if someone puts a future end date
    left join {{ ref("market_region_xwalk") }} as mrx_p
        on pm.parent_market_id = mrx_p.market_id
    -- Inner join because we want this to hard filter things not in market_region_xwalk. If we have a parent, use that,
    -- if not use the child market
    -- o for output/coalesced market name. Could be
    inner join {{ ref("market_region_xwalk") }} as mrx_o
        -- parent
        on coalesce(mrx_p.market_id, m.market_id) = mrx_o.market_id
    left join {{ ref('stg_analytics_gs__market_rollout') }} as rmr
        on mrx_o.market_id = rmr.market_id
    left join general_manager as gm
        on mrx_o.market_id = gm.market_id
    left join {{ ref("stg_analytics_public__disc_master") }} as dm
        on gm.employee_id = dm.employee_id
    left join {{ ref("stg_es_warehouse_public__locations") }} as l
        on m.location_id = l.location_id
    left join {{ ref("stg_es_warehouse_public__states") }} as s
        on l.state_id = s.state_id
