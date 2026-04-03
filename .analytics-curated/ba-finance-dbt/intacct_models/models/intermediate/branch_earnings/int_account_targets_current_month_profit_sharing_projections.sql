with recursive org_chain as (
-- Create Employee Heirarchy for assigning eligible Profit Sharing Employees
    select
        cd.market_id,
        cd.employee_id,
        cd.direct_manager_employee_id as next_manager_employee_id,
        case
            when cd.employee_title in ('General Manager', 'General Manager - Advanced Solutions', 'interim General Manager')
                then 'General Manager'
            when cd.employee_title in ('Service Manager')
                then 'Service Manager'
            when cd.employee_title in ('District Operations Manager', 'District Manager', 'District Operations manager')
                then 'District Operations Manager'
            when cd.employee_title in ('District Sales Manager')
                then 'District Sales Manager'
            when cd.employee_title in (
                'Regional Director of Advanced Solutions', 'Regional Manager- Advanced Solutions', 'Regional Director Of Advanced Solutions',
                'Regional Operations Manager - Advanced Solutions', 'Regional Director of Advanced Solutions', 'Regional Operations Director - Advanced Solutions'
                )
                then 'Regional Advanced Solutions Operations Manager'
            when cd.employee_title in ('Regional Advanced Solutions Sales Manager', 'Regional Sales Manager Advanced Solutions')
                then 'Regional Advanced Solutions Sales Manager'
            when cd.employee_title in ('Fleet Manager', 'Fleet Manager Southwest', 'Fleet Manager Southeast')
                then 'Regional Fleet Manager'
            when cd.employee_title in ('Regional Director of Operations', 'Regional Operations Director - Southwest', 'Regional Operations Director')
                then 'Regional Operations Manager'
            when cd.employee_title in ('Regional Sales Manager', 'Regional Director of Sales', 'Regional Sales Director')
                then 'Regional Sales Manager'
            when cd.employee_title in ('Vice President of Operations', 'Vice President of Sales', 'Regional Vice President', 'VP Regional Director of Sales')
                then 'Vice President'
            else 'Not Classified'
        end as employee_title_classification,
        1 as level,
        to_varchar(cd.employee_id) as path
    from {{ ref('stg_analytics_payroll__company_directory') }} as cd
    where cd.market_id is not null
        and cd.is_active_employee = true

    union all

    -- Recursive: move up one manager level, but keep the original market_id
    select
        oc.market_id,
        mgr.employee_id,
        mgr.direct_manager_employee_id as next_manager_employee_id,
        case
            when mgr.employee_title in ('General Manager', 'General Manager - Advanced Solutions', 'interim General Manager')
                then 'General Manager'
            when mgr.employee_title in ('Service Manager')
                then 'Service Manager'
            when mgr.employee_title in ('District Operations Manager', 'District Manager', 'District Operations manager')
                then 'District Operations Manager'
            when mgr.employee_title in ('District Sales Manager')
                then 'District Sales Manager'
            when mgr.employee_title in (
                'Regional Director of Advanced Solutions', 'Regional Manager- Advanced Solutions', 'Regional Director Of Advanced Solutions',
                'Regional Operations Manager - Advanced Solutions', 'Regional Director of Advanced Solutions', 'Regional Operations Director - Advanced Solutions'
                )
                then 'Regional Advanced Solutions Operations Manager'
            when mgr.employee_title in ('Regional Advanced Solutions Sales Manager', 'Regional Sales Manager Advanced Solutions')
                then 'Regional Advanced Solutions Sales Manager'
            when mgr.employee_title in ('Fleet Manager', 'Fleet Manager Southwest', 'Fleet Manager Southeast')
                then 'Regional Fleet Manager'
            when mgr.employee_title in ('Regional Director of Operations', 'Regional Operations Director - Southwest', 'Regional Operations Director')
                then 'Regional Operations Manager'
            when mgr.employee_title in ('Regional Sales Manager', 'Regional Director of Sales', 'Regional Sales Director')
                then 'Regional Sales Manager'
            when mgr.employee_title in ('Vice President of Operations', 'Vice President of Sales', 'Regional Vice President', 'VP Regional Director of Sales')
                then 'Vice President'
            else 'Not Classified'
        end as employee_title_classification,
        oc.level + 1 as level,
        oc.path || '>' || to_varchar(mgr.employee_id) as path
    from org_chain as oc
        inner join {{ ref('stg_analytics_payroll__company_directory') }} as mgr
            on oc.next_manager_employee_id = mgr.employee_id
    where oc.next_manager_employee_id is not null
    -- cycle protection (don’t revisit the same employee in the chain)
        and position('>' || to_varchar(mgr.employee_id) || '>' in '>' || oc.path || '>') = 0
),

employee_spine as (
    select distinct
        m.market_id,
        m.market_name,
        m.branch_earnings_start_month,
        o.employee_id,
        cd.nickname as employee_name,
        split_part(cd.default_cost_centers_full_path, '/', -1) as department,
        o.employee_title_classification,
        cd.position_effective_date,
        coalesce(cd.date_terminated, current_date + 1) as position_end_date
    from org_chain as o
        inner join {{ ref('market') }} as m on o.market_id = m.child_market_id
        left join {{ ref('stg_analytics_payroll__company_directory') }} as cd on o.employee_id = cd.employee_id
    where (
        o.employee_title_classification != 'Not Classified'
        or (o.employee_title_classification = 'Not Classified' and o.market_id = cd.market_id)
    ) -- Include non-manager employees at the branch for store distribution
    qualify row_number() over (
            partition by o.market_id, o.employee_id
            order by o.level
        ) = 1
),

live_net_income as (
-- For live months, sum projected totals across all accounts to get projected Net Income and revenue to use in profit sharing accrual calculation.
    select
        np.market_id,
        np.gl_month,
        sum(case when np.rev_exp = 'REV' then coalesce(pp.month_end_projected_amount, np.month_end_projected_amount) else 0 end) as month_end_projected_revenue,
        sum(coalesce(pp.month_end_projected_amount, np.month_end_projected_amount)) as month_end_projected_net_income
    from {{ ref('int_account_targets_current_month_non_payroll_projections') }} as np
        left join {{ ref('int_account_targets_current_month_payroll_projections') }} as pp
            on np.market_id = pp.market_id
                and np.gl_month = pp.gl_month
                and np.account_no = pp.account_no
                and np.account_name = pp.account_name
    group by np.market_id, np.gl_month
),

employee_projections as (
    select
        es.market_id,
        es.employee_id,
        es.department,
        es.employee_title_classification,
        lni.gl_month,
        datediff(month, es.branch_earnings_start_month, lni.gl_month) + 1 as months_open_at_time,
        lni.month_end_projected_net_income,
        lni.month_end_projected_revenue,
        case
            when es.department = 'Administrative' then '7700'
            when es.department in ('Equipment Rental', 'Sales') then '6008'
            when es.department = 'Maintenance' then '6310'
            when es.department = 'Delivery and Pickup' then '6019'
        end as account_no,
        case
            when es.department = 'Administrative' then 'Administrative Payroll'
            when es.department in ('Equipment Rental', 'Sales') then 'Equipment Rental Payroll'
            when es.department = 'Maintenance' then 'Maintenance Payroll'
            when es.department = 'Delivery and Pickup' then 'Delivery and Pickup Payroll'
        end as account_name,
        case
            when es.employee_title_classification = 'General Manager' then 0.0375
            when es.employee_title_classification = 'Service Manager' then 0.015
            when es.employee_title_classification = 'District Operations Manager' then 0.0075
            when es.employee_title_classification = 'District Sales Manager' then 0.005
            when es.employee_title_classification = 'Regional Operations Manager' then 0.005
            when es.employee_title_classification = 'Regional Sales Manager' then 0.0025
            when es.employee_title_classification = 'Regional Advanced Solutions Operations Manager' then 0.0075
            when es.employee_title_classification = 'Regional Advanced Solutions Sales Manager' then 0.005
            when es.employee_title_classification = 'Regional Fleet Manager' then 0.0001
            when es.employee_title_classification = 'Vice President' then 0.005
        end as profit_sharing_pct,
        case
        -- For Non-Managers, split 2% of the profit evenly across all employees in the store. For Managers, use the % table above.
            when lni.month_end_projected_net_income > 0
                and es.employee_title_classification = 'Not Classified'
                then (lni.month_end_projected_net_income * 0.02) / nullif(count(es.employee_id) over (partition by es.market_id, lni.gl_month), 0)
            when lni.month_end_projected_net_income > 0 then lni.month_end_projected_net_income * profit_sharing_pct
            else 0
        end as projected_profit_sharing_accrual,
        case
            when es.employee_title_classification in ('Not Classified', 'General Manager') and months_open_at_time = 3 then 5000
            when es.employee_title_classification in ('Not Classified', 'General Manager') and months_open_at_time = 6 then 10000
            when es.employee_title_classification in ('Not Classified', 'General Manager') and months_open_at_time = 9 then 15000
            when es.employee_title_classification ilike any ('%district%op%', '%district%sale%', '%region%op%', '%region%sale%') and months_open_at_time = 3 then 1000
            when es.employee_title_classification ilike any ('%district%op%', '%district%sale%', '%region%op%', '%region%sale%') and months_open_at_time = 6 then 2000
            when es.employee_title_classification ilike any ('%district%op%', '%district%sale%', '%region%op%', '%region%sale%') and months_open_at_time = 9 then 3000
            when es.employee_title_classification = 'Service Manager' and months_open_at_time = 3 then 2000
            when es.employee_title_classification = 'Service Manager' and months_open_at_time = 6 then 4000
            when es.employee_title_classification = 'Service Manager' and months_open_at_time = 9 then 6000
            when es.employee_title_classification = 'Regional Fleet Manager' and months_open_at_time = 3 then 100
            when es.employee_title_classification = 'Regional Fleet Manager' and months_open_at_time = 6 then 200
            when es.employee_title_classification = 'Regional Fleet Manager' and months_open_at_time = 9 then 300
        end as rev_sharing_amount,
        case
            when lni.month_end_projected_revenue >= mg.revenue_goals
                and es.employee_title_classification = 'Not Classified'
                then coalesce(rev_sharing_amount / nullif(count(es.employee_id) over (partition by es.market_id, lni.gl_month), 0), 0)
            when lni.month_end_projected_revenue >= mg.revenue_goals then coalesce(rev_sharing_amount, 0)
            else 0
        end as projected_revenue_sharing_accrual
    from employee_spine as es
        inner join live_net_income as lni
            on es.market_id = lni.market_id
                and least(last_day(lni.gl_month), current_date) between es.position_effective_date and es.position_end_date
        left join {{ ref('stg_analytics_public__market_goals') }} as mg
            on es.market_id = mg.market_id
                and lni.gl_month = mg.months
)

select *
from employee_projections
where projected_profit_sharing_accrual > 0 or projected_revenue_sharing_accrual > 0
