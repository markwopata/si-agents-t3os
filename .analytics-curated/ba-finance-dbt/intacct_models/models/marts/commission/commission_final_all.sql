select *
from {{ ref("stg_analytics_commission__commission_manual_adjustments") }}

union all

select
    *,
    null as requester_id,
    null as requester_full_name,
    null as description,
    null as comments,
    null as submitted_by,
    null as submitted_date

from {{ ref("stg_analytics_commission__commission_details_final") }}
