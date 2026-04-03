select
    cac.accounting_category_id,
    cac.accounting_category_name,
    cac.date_created,
    cac.date_updated
from {{ source('analytics_retool', 'cip_accounting_categories') }} as cac
