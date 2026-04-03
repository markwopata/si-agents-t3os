select 
    asset_code
    , max(asset_gl_assignment_date) as max_date
from {{ ref('stg_analytics_asset4000_dbo__gl_asset_grps') }}
where asset_gl_assignment_date <= '{{ var("as4k_report_date") }}'
group by
    1
order by
    1 
asc
