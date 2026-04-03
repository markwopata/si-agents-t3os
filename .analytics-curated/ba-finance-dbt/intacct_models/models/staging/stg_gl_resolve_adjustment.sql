{{
    config(materialized='table',
        persist_docs={'relation': true, 'columns': true}
    )
}}

select
    sigr.pk_gl_resolve_id,
    sigr.fk_gl_entry_id,
    sigr.fk_subledger_header_id,
    sigr.fk_subledger_line_id,
    case
        -- This line is incorrect - subledger-ledger mismatch problem.
        when sigr.fk_gl_entry_id = 193487
            then sigr.raw_amount * 2
        when
            sigr.fk_gl_entry_id in (
                /*these have the wrong sign in subledger, right in ledger. We won't be fixing this in Sage.*/
                75536971,
                75536972,
                75536973,
                75536974,
                75536975,
                75536976
            )
            then -sigr.raw_amount
        when
            sigr.fk_gl_entry_id in (76432022, 76432023)
            and sigr.raw_trx_amount = -12464.52
            then -sigr.raw_trx_amount
        else sigr.raw_amount
    end as raw_amount,
    case
        -- This line is incorrect - subledger-ledger mismatch problem.
        when sigr.fk_gl_entry_id = 193487
            then sigr.raw_trx_amount * 2
        when
            sigr.fk_gl_entry_id in (
                /*these have the wrong sign in subledger, right in ledger. We won't be fixing this in Sage.*/
                75536971,
                75536972,
                75536973,
                75536974,
                75536975,
                75536976
            )
            then -sigr.raw_trx_amount
        when
            sigr.fk_gl_entry_id in (76432022, 76432023)
            and sigr.raw_trx_amount = -12464.52
            then -sigr.raw_trx_amount
        else sigr.raw_trx_amount
    end as raw_trx_amount,
    sigr.currency_code,
    sigr.date_created,
    sigr.date_updated,
    sigr.fk_created_by_user_id,
    sigr.fk_updated_by_user_id,
    sigr._es_update_timestamp,
    sigr.dds_read_timestamp
from {{ ref('base_analytics_intacct__gl_resolve') }} as sigr
    inner join {{ ref('base_analytics_intacct__gl_entry') }} as gle
        on sigr.fk_gl_entry_id = gle.pk_gl_entry_id
where case -- ignore glresolve for 1307 in december-2019 because it is incorrect
        when
            gle.account_number = '1307'
            and date_trunc(
                month,
                gle.entry_date
            ) = '2019-12-01'
            then 0
        else 1
    end = 1

order by sigr.fk_gl_entry_id, sigr.pk_gl_resolve_id
