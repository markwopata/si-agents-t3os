with gaap_accounts as(
select date_trunc(month,gl.entry_date) as gl_month
     , gl.market_id 
     , nvl(gam.sort_group_ovr,m.sort_group) as sort_group
     , nvl(gam.dept_ovr,m."GROUP") as department
     , nvl(gam.revexp_ovr,m.revexp) as revexp
     , nvl(cast(gam.map_id as varchar),cast(gl.account_number as varchar)) as map_id
     , nvl(cast(gam.rep_acct as varchar),cast(gl.account_number as varchar)) as gaap_account_number
     , nvl(gam.rep_acct_name,gl.account_name) as gaap_account_name
     , sum(gl.amount) as gaap_amount
 from {{ ref('gl_detail') }} gl
 left join {{ ref('stg_analytics_gs__plexi_bucket_mapping') }} m on cast(gl.account_number as varchar) = m.sage_gl and m.exclude_flag = FALSE
 left join {{ ref('seed_gaap_acct_map') }} gam on cast(gl.account_number as varchar) = gam.gaap_acct 
 where gl.account_type = 'incomestatement'
  and (m.sage_gl is not null or gam.gaap_acct is not null)
 group by all)

, be_accounts as(
select date_trunc(month,be.gl_date) as gl_month
     , be.market_id
     , nvl(sam.sort_group_ovr,m.sort_group) as sort_group
     , nvl(sam.dept_ovr,m."GROUP") as department
     , nvl(sam.revexp_ovr,m.revexp) as revexp
     , nvl(cast(sam.map_id as varchar),cast(be.account_number as varchar)) as map_id
     , nvl(cast(sam.rep_acct as varchar),be.account_number) as branch_earnings_account_number
     , nvl(sam.rep_acct_name,m.sage_name) as branch_earnings_account_name
     , sam.stat_start_date as statistical_account_start_date
     , sum(be.amount) as branch_earnings_amount
 from {{ ref('stg_analytics_public__branch_earnings_dds_snap') }} be
 left join {{ ref('stg_analytics_gs__plexi_bucket_mapping') }} m on be.account_number = m.sage_gl
 left join {{ ref('seed_stat_acct_map') }} sam on cast(be.account_number as varchar) = sam.stat_acct
 group by all)

, date_range as(
select distinct gl_month
 from be_accounts)

, coalesce as(
select coalesce(g.gl_month,b.gl_month) as gl_month
     , coalesce(g.market_id,b.market_id) as market_id 
     , coalesce(g.sort_group,b.sort_group) as sort_group
     , coalesce(g.department,b.department) as department
     , coalesce(g.revexp,b.revexp) as revexp
     , coalesce(g.map_id,b.map_id) as account_map_id
     , g.gaap_account_number
     , g.gaap_account_name 
     , b.branch_earnings_account_number
     , (case 
         when b.branch_earnings_account_number is not null then coalesce(b.branch_earnings_account_name,g.gaap_account_name) 
        end) as branch_earnings_account_name
     , b.statistical_account_start_date
     , nvl(g.gaap_amount,0) as gaap_amount
     , nvl(b.branch_earnings_amount,0) as branch_earnings_amount
 from gaap_accounts g
 full outer join be_accounts b on g.map_id = b.map_id 
                                and g.gl_month = b.gl_month
                                and g.market_id = b.market_id)

select c.gl_month::varchar as gl_month
     , c.market_id 
     , m.child_market_name as market_name 
     , m.region_district
     , m.region
     , m.region_name
     , c.sort_group 
     , c.department
     , c.revexp 
     , c.account_map_id 
     , c.gaap_account_number 
     , c.gaap_account_name 
     , c.branch_earnings_account_number
     , c.branch_earnings_account_name
     , c.statistical_account_start_date::varchar as statistical_account_start_date
     , c.gaap_amount 
     , c.branch_earnings_amount
     , (c.branch_earnings_amount - c.gaap_amount) as difference
 from coalesce c 
 join date_range dr on c.gl_month = dr.gl_month
 left join {{ref('market') }} m on c.market_id = m.child_market_id 
