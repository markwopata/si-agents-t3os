--Net Income

with net_income as (
    select
        mkt_id,
        mkt_name,
        date_trunc('month', gl_date) as be_month,
        sum(amt) as net_income,
        sum(case when revexp = 'REV' then amt else 0 end) as revenue,
        date_part('day', last_day(date_trunc('month', gl_date))) as days_in_month
    from {{ ref('int_materials_branch_earnings_snap') }}
    group by all
),

account_details as (
    select
        gl.market_id,
        gl.market_name,
        date_trunc('month', gl.entry_date) as month,
        -- Accounts Receivable GL account
        sum(case when gl.gl_account_number = '1223' then gl.entry_amount else 0 end) as ar_monthly_total,
        -- Material COGS and Lumber COGS
        sum(case when gl.gl_account_number in ('6034', 'GADEL') then gl.entry_amount else 0 end) as cogs_monthly_total,
        sum(case when gl.account_name ilike '%Payroll%' and gl.account_name != 'Telematics Installation Payroll'
                and gl.account_name != 'Telematics Administration Payroll' then gl.entry_amount
            else 0
        end) as payroll_monthly_total,
        count(distinct case when gl.gl_account_number in ('5015', 'FABFL') then gl.header_number end)
            as number_of_orders,
        sum(case when gl.gl_account_number in ('5015', 'FABFL') then gl.entry_amount else 0 end) as total_order_amount
    from {{ ref('int_materials_gl_detail') }} as gl
    group by all
),

ar as (
    select
        ad.market_id,
        ad.market_name,
        ad.month,
        ad.ar_monthly_total,
        ad.cogs_monthly_total as cogs,
        ad.number_of_orders,
        ad.total_order_amount,
        ad.payroll_monthly_total as total_payroll,
        sum(ad.ar_monthly_total) over (
            partition by ad.market_id order by ad.month
            rows between unbounded preceding and current row
        ) as ar_running_total
    from account_details as ad
    order by ad.month
),

--inventory 

inventory as (
    select
        market_id,
        market_name,
        date_trunc('month', entry_date) as month,
        sum(entry_amount) as month_amount,
        sum(sum(entry_amount)) over (
            partition by market_id order by date_trunc('month', entry_date)
        ) as running_total
    from {{ ref('int_materials_gl_detail') }}
    where gl_account_number in ('1304', '1319', '1318', '1301', '1312') --Inventory related GL accounts
    group by all
    order by month
),

average_inventory as (
    select
        *,
        (running_total + lag(running_total) over (partition by market_id order by month))
        / 2.0 as avg_last_2mo_running_total
    from inventory
    order by market_id, month
),

--Sales per Square Foot

sales_per_sq_ft as (
    select
        sf.market_id,
        sf.market_name,
        sf.square_footage
    from {{ ref('stg_analytics_gs__materials_branch') }} as sf
),

--company info

company_info as (
    with manager as (
        select
            cd.market_id,
            date_trunc('month', cd._es_update_timestamp) as months,
            cd.full_name as store_manager
        from {{ ref('stg_analytics_payroll__company_directory_vault') }} as cd
        where cd.employee_title = 'Store Manager'
            and cd.employee_status = 'Active'
        qualify row_number() over (
                partition by cd.market_id, date_trunc('month', cd._es_update_timestamp)
                order by cd._es_update_timestamp desc
            ) = 1
        order by months
    ),

    monthly_employees as (
        select
            cd.market_id,
            date_trunc('month', _es_update_timestamp) as months,
            count(distinct iff(cd.employee_status = 'Active', cd.employee_id, null)) as num_employees
        from {{ ref('stg_analytics_payroll__company_directory_vault') }} as cd
            left join {{ ref('market_region_xwalk') }} as mrx
                on cd.market_id = mrx.market_id
        where mrx.market_type = 'Materials'
        group by all
    )

    select
        me.market_id,
        me.months,
        me.num_employees as employee_count,
        m.store_manager as manager
    from monthly_employees as me
        inner join manager as m
            on me.market_id = m.market_id and me.months = m.months

)

select
    ni.mkt_id,
    ni.mkt_name,
    ni.be_month,
    ni.net_income,
    ni.revenue,
    ni.days_in_month,
    ar.ar_running_total,
    ar.cogs,
    ar.total_payroll,
    ar.number_of_orders,
    ar.total_order_amount,
    inv.month_amount as inventory_change_amount,
    inv.running_total as inventory_amount,
    inv.avg_last_2mo_running_total,
    spsf.square_footage,
    ci.manager,
    ci.employee_count,
    row_number() over (partition by ni.mkt_id order by ni.be_month asc) as months_open
from net_income as ni
    left join ar as ar
        on ni.mkt_id = ar.market_id
            and ni.be_month = ar.month
    left join average_inventory as inv
        on ni.mkt_id = inv.market_id
            and ni.be_month = inv.month
    left join sales_per_sq_ft as spsf
        on ni.mkt_id = spsf.market_id
    left join company_info as ci
        on ni.mkt_id = ci.market_id
            and ni.be_month = ci.months
