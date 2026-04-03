select
    g.generalledgerid as general_ledger_id,
    g.glcode as gl_code,
    g.sourceid as source_id,
    g.sourcetype as source_type,
    g.referencenumber as reference_number,
    g.creditamount as credit_amount,
    g.datetimecreated as datetime_created,
    g.debitamount as debit_amount,
    g.distributiontype as distribution_type,
    g._fivetran_deleted,
    g._fivetran_synced
from {{ source('analytics_bt_dbo', 'generalledger') }} as g
