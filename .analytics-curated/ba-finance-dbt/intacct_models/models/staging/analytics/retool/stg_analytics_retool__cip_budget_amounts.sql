select
    cba.pk_id,
    cba.market_id,
    cba.division_code,
    cba.budget_amount,
    cba.budget_revision,
    cba.project_id,
    cba.created_by,
    cba.updated_by,
    cba.date_created,
    cba.date_updated
from {{ source('analytics_retool', 'cip_budget_amounts') }} as cba
