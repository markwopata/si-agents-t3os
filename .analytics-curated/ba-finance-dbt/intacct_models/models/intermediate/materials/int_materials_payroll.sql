select
    pk_gl_detail_id,
    market_id,
    market_name,
    account_name,
    entry_description,
    amount,
    entry_date,
    url_journal
from {{ ref ('gl_detail') }}
where entity_id = 'E7'
    and account_name ilike '%Payroll%'
    and account_name != 'Telematics Installation Payroll'
    and account_name != 'Telematics Administration Payroll'
