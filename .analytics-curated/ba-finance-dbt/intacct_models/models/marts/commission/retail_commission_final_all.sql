select 
    *
from {{ ref("stg_analytics_commission__commission_retail_manual_adjustments")}}

union all

select 
    *

from {{ ref("stg_analytics_commission__retail_commission_details_final")}}