select
    cbdc.pk_id,
    cbdc.division_code,
    cbdc.division_name
from {{ source('analytics_retool', 'cip_budget_division_codes') }} as cbdc
