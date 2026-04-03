select
    cec.pk_gl_detail_id,
    cec.division_code,
    cec.created_by,
    cec.updated_by,
    cec.accounting_category_id,
    cec.project_id,
    cec.date_created,
    cec.date_updated
from {{ source('analytics_retool', 'cip_expense_classifications') }} as cec
