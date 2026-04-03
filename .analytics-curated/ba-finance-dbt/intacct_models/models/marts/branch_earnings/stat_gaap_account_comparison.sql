select gl_month
     , market_id 
     , market_name 
     , region_district
     , region
     , region_name
     , sort_group 
     , department
     , revexp 
     , account_map_id 
     , gaap_account_number 
     , gaap_account_name 
     , branch_earnings_account_number
     , branch_earnings_account_name
     , statistical_account_start_date
     , gaap_amount 
     , branch_earnings_amount
     , difference
 from {{ ref('int_branch_earnings_stat_gaap_rollup') }}
 