select
    v.vendor_id,
    v.vendor_name,
    v.vendor_type,
    v.vendor_term as terms,
    v.vendor_status as status,
    v.vendor_category
from {{ ref("stg_analytics_intacct__vendor") }} as v
