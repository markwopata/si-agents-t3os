select distinct
    beds.account_number,
    beds.account_name,
    beds.type as account_category
from {{ ref('stg_analytics_public__branch_earnings_dds_snap') }} as beds
where beds.gl_date >= dateadd(month, -24, current_date())
