with master_markets_user_emails as (
    select
        muv.board_id,
        muv.item_id,
        muv.group_id,
        muv.group_title,
        muv.item_name::text as user_name,
        muv.text::text as user_email
    from {{ ref("int_monday_unpivoted_values") }} as muv
    where muv.column_id = 'user_email'
        and muv.board_id = '8840815858'
    group by all
),

-- Budget vs Actuals
combine_budget_actual_committed as (
    select
        cb.project_id,
        cb.project_code,
        cb.market_id,
        cb.division_code,
        cb.division_name,
        coalesce(cb.budget_amount, 0) as budget_amount,
        round(sum(coalesce(ca.actual_amount, 0)), 2) as actual_amount,
        0 as committed_amount,
        'budget-actual match' as source
    from {{ ref("int_cip_budgets") }} as cb
        left join {{ ref("int_cip_actuals") }} as ca
            on cb.project_id = ca.project_id
                and cb.division_code = ca.division_code
    group by all

    union all

    select
        ca.project_id,
        ca.project_code,
        ca.market_id,
        ca.division_code,
        ca.division_name,
        0 as budget_amount,
        round(sum(coalesce(ca.actual_amount, 0)), 2) as actual_amount,
        0 as committed_amount,
        'actuals no project' as source
    from {{ ref("int_cip_actuals") }} as ca
        left join {{ ref("int_cip_budgets") }} as cb
            on ca.project_id = cb.project_id
    where cb.project_id is null
    group by all

    union all

    -- committed with no project
    select
        -1 as project_id,
        'NO PROJECT' as project_code,
        cm.market_id,
        cm.division_code,
        cm.division_name,
        0 as budget_amount,
        0 as actual_amount,
        round(sum(coalesce(cm.committed_amount, 0)), 2) as committed_amount,
        'committed no project' as source
    from {{ ref("int_cip_committed") }} as cm
    group by
        cm.market_id,
        cm.division_code,
        cm.division_name
),

out as (
    select
        coalesce(bac.project_code, 'NO PROJECT')
        || '-' || coalesce(bac.market_id, -1)::text
        || '-' || coalesce(bac.division_code, 'ZZ-9999') as pk_id,
        bac.project_id,
        bac.project_code,
        cp.description,
        ps.name as project_status,
        bac.market_id::int as market_id,
        m.market_name,
        coalesce(
            l.street_1 || ', ' || l.city || ', ' || s.abbreviation || ' ' || l.zip_code,
            mm.address || ' (*Not Entered in T3)'
        ) as address,
        mm.is_active_project,
        mm.url_market_google_drive_folder as url_drive,
        mm.close_date,
        mm.possession_date,
        mm.basic_operational_readiness_completed_date as bor_date,
        mm.cpm_project_completion_date,
        datediff('day', mm.possession_date, mm.basic_operational_readiness_completed_date) as days_to_open,
        datediff('day', mm.possession_date, mm.target_construction_completion_date) as days_to_completion,
        mm.grouping_name as market_grouping,
        mm.target_construction_completion_date,
        mm.launch_phase,
        coalesce(cd.nickname, cd.full_name, mm.construction_project_manager_name) as cpm_key,
        cd.work_email as cpm_email,
        cd.date_hired as cpm_hire_date,
        bac.division_code,
        bac.division_name,
        round(sum(coalesce(bac.budget_amount, 0)), 2) as budget_amount,
        round(sum(coalesce(bac.actual_amount, 0)), 2) as actual_amount,
        round(sum(coalesce(bac.committed_amount, 0)), 2) as committed_amount,
        round(sum(coalesce(coalesce(bac.budget_amount, 0) - bac.actual_amount, 0)), 2) as budget_delta
    from combine_budget_actual_committed as bac
        left join {{ ref("stg_analytics_retool__cip_projects") }} as cp
            on bac.project_id = cp.project_id
        left join {{ ref("stg_analytics_payroll__company_directory") }} as cd
            on cp.construction_project_manager_employee_id = cd.employee_id
        left join {{ ref("stg_es_warehouse_public__markets") }} as m
            on bac.market_id = m.market_id
        left join {{ ref("stg_es_warehouse_public__locations") }} as l
            on m.location_id = l.location_id
        left join {{ ref("stg_es_warehouse_public__states") }} as s
            on l.state_id = s.state_id
        left join {{ ref("int_master_markets_single_market") }} as mm
            on bac.market_id = mm.market_id
        left join {{ ref("stg_analytics_retool__cip_project_statuses") }} as ps
            on cp.project_status_id = ps.project_status_id
    where m.market_id < 1000000
    group by all
)

-- Final Join
select
    bva.pk_id,
    bva.project_id,
    bva.project_code,
    bva.market_id,
    bva.market_name,
    bva.description,
    bva.project_status,
    bva.is_active_project,
    bva.launch_phase,
    bva.address,
    bva.url_drive,
    bva.close_date,
    bva.possession_date,
    bva.bor_date,
    bva.days_to_open,
    bva.days_to_completion,
    bva.market_grouping,
    bva.target_construction_completion_date,
    bva.cpm_project_completion_date,

    -- unified user name: if we got nothing from monday, fall back to bva.cpm_key
    coalesce(mn.user_name, me.user_name, bva.cpm_key) as cpm,
    coalesce(bva.cpm_email, me.user_email, mn.user_email) as email_unified,

    bva.cpm_hire_date,
    bva.division_code,
    bva.division_name,
    bva.budget_amount,
    bva.actual_amount,
    bva.committed_amount,
    bva.budget_delta,

    (me.user_name is null and mn.user_name like '%,%') as is_multi_cpm

from out as bva
    left join master_markets_user_emails as me
        on lower(bva.cpm_email) = lower(me.user_email)
    left join master_markets_user_emails as mn
        on bva.cpm_email is null
            and lower(bva.cpm_key) = lower(mn.user_name)
order by bva.market_id, bva.project_code
