select
    m._row,
    m.mcc_no_::text as mcc_code,
    m.mcc::text as mcc_description,
    m.intacct_account::text as account_number,
    m.intacct_account_description as account_name,
    m._fivetran_synced
from {{ source('analytics_gs', 'mcc') }} as m
