select
    md5(
        coalesce(gle.pk_gl_entry_id, '-1')
        || '-'
        || coalesce(glr.pk_gl_resolve_id, '-1')
    ) as pk_gl_detail_id,
    gle.pk_gl_entry_id as fk_gl_entry_id,
    glr.pk_gl_resolve_id as fk_gl_resolve_id,
    gle.entry_date,
    gle.account_number,
    gle.account_name,
    gle.fk_account_id,
    gle.account_normal_balance,
    gle.account_type,
    gle.department_name,
    gle.department_id,
    gle.market_id,
    gle.market_name,
    gle.entity_id,
    gle.entity_name,
    gle.extended_entity_name,
    coalesce(glr.raw_amount, gle.raw_amount)::number(38, 2) as raw_amount,
    gle.entry_description,
    gle.journal_title,
    gle.debit_credit,
    gle.debit_credit_sign,
    (gle.debit_credit_sign * coalesce(glr.raw_amount, gle.raw_amount))::number(
        38, 2
    ) as net_amount,
    gle.positive_revenue_sign,
    gle.applied_sign,
    (gle.applied_sign * coalesce(glr.raw_amount, gle.raw_amount))::number(
        38, 2
    ) as amount,
    coalesce(glr.raw_trx_amount, gle.raw_trx_amount)::number(38, 2)
        as raw_trx_amount,
    (
        debit_credit_sign * coalesce(glr.raw_trx_amount, gle.raw_trx_amount)
    )::number(38, 2) as net_trx_amount,
    (applied_sign * coalesce(glr.raw_trx_amount, gle.raw_trx_amount))::number(
        38, 2
    ) as trx_amount,
    gle.raw_amount::number(38, 2) as raw_entry_amount,
    gle.net_amount::number(38, 2) as net_entry_amount,
    gle.amount::number(38, 2) as entry_amount,
    gle.exchange_rate,
    gle.currency_code,
    gle.base_currency_code,
    gle.exchange_rate_date,
    gle.fk_expense_type_id,
    gle.expense_type,
    gle.expense_category,
    gle.intacct_module,
    gle.journal_type,
    gle.extended_journal_type,
    gle.date_reversed,
    gle.fk_reversed_from_journal_id,
    gle.fk_journal_id,
    gle.journal_transaction_number,
    gle.line_number,
    gle.document,
    gle.url_journal,
    glr.fk_subledger_header_id,
    glr.fk_subledger_line_id,
    gle.fk_ud_loan_id,
    gle.gl_dim_transaction_identifier,
    gle.asset_id,
    gle.gl_dim_asset_id,
    gle.fk_created_by_user_id,
    gle.created_by_username,
    gle.created_by_name,
    gle.fk_updated_by_user_id,
    gle.updated_by_username,
    gle.updated_by_name,
    gle.entry_state,
    gle.journal_state,
    gle.is_statistical,
    gle.combined_state,
    coalesce(glr.date_created, gle.date_created) as date_created,
    coalesce(glr.date_updated, gle.date_updated) as date_updated,
    coalesce(glr._es_update_timestamp, gle._es_update_timestamp) as _es_update_timestamp,
    coalesce(glr.dds_read_timestamp, gle.dds_read_timestamp) as dds_read_timestamp
from {{ ref('stg_gl_entry') }} as gle
    left join {{ ref('stg_gl_resolve_adjustment') }} as glr
        on
            gle.pk_gl_entry_id = glr.fk_gl_entry_id

order by gle.entry_date, gle.account_number, gle.entity_id, gle.department_id, gle.fk_expense_type_id
