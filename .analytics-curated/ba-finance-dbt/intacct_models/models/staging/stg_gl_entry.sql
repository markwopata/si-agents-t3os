{{
    config(materialized='table',
        persist_docs={'relation': true, 'columns': true}
    )
 }}
select
    gle.pk_gl_entry_id,
    gle.entry_date,
    gla.account_number,
    gla.account_name,
    gle.fk_account_id,
    gla.account_normal_balance,
    gla.account_type,
    m.market_id,
    m.market_name,
    d.department_name,
    gle.entity_id,
    l.entity_name,
    l.extended_entity_name,
    gle.raw_amount,
    gle.department_id,
    gle.entry_description,
    gle.journal_title,
    gle.debit_credit,
    gle.debit_credit_sign,
    gle.market_id as markets_id,
    -- debit minus credit
    (raw_amount * debit_credit_sign)::number(38, 2) as net_amount,
    -1 as positive_revenue_sign,
    debit_credit_sign * positive_revenue_sign as applied_sign,
    (raw_amount * applied_sign)::number(38, 2) as amount,
    gle.raw_trx_amount::number(38, 2) as raw_trx_amount,
    (raw_trx_amount * debit_credit_sign)::number(38, 2) as net_trx_amount,
    (raw_trx_amount * applied_sign)::number(38, 2) as trx_amount,
    gle.exchange_rate,
    gle.currency_code,
    gle.base_currency_code,
    gle.exchange_rate_date,
    gle.fk_expense_type_id,
    el.expense_type,
    el.expense_category,
    glb.intacct_module,
    glb.journal_type,
    gljt.extended_journal_type,
    glb.date_reversed,
    glb.fk_reversed_from_journal_id,
    glb.pk_journal_id as fk_journal_id,
    -- Accounting knows this as transaction number
    glb.journal_transaction_number,
    gle.line_number,
    gle.document,
    ru.url_sage as url_journal,
    gle.fk_ud_loan_id,
    gle.gl_dim_transaction_identifier,
    gle.asset_id,
    gle.gl_dim_asset_id,
    gle.fk_created_by_user_id,
    u_c.username as created_by_username,
    u_c.user_description as created_by_name,
    gle.fk_updated_by_user_id,
    u_m.username as updated_by_username,
    u_m.user_description as updated_by_name,
    gle.entry_state,
    glb.journal_state,
    gle.is_statistical,
    -- There are a few instances where gle.state != glb.state, probably due to DDS not syncing one of the objects over.
    coalesce(gle.entry_state, glb.journal_state) as combined_state,
    gle.date_created,
    gle.date_updated,
    gle._es_update_timestamp,
    gle.dds_read_timestamp
from {{ ref('base_analytics_intacct__gl_entry') }} as gle
    inner join {{ ref('stg_analytics_intacct__gl_journal') }} as glb
        on gle.fk_journal_id = glb.pk_journal_id
    left join {{ ref('stg_analytics_intacct__gl_journal_type') }} as gljt
        on glb.journal_type = gljt.journal_type
    inner join {{ ref('stg_analytics_intacct__gl_account') }} as gla
        on gle.fk_account_id = gla.pk_account_id
    -- Department can be null
    left join {{ ref('stg_analytics_intacct__department') }} as d
        on gle.fk_department_id = d.pk_department_id
    inner join {{ ref('stg_analytics_intacct__entity') }} as l
        on gle.fk_entity_id = l.pk_entity_id
    -- Not all gl entries have an expense line/type
    left join {{ ref('stg_analytics_intacct__expense_type') }} as el
        on gle.fk_expense_type_id = el.pk_expense_type_id
    -- Left join here because there may be instances where we do not have
    left join {{ ref('stg_analytics_intacct__record_url') }} as ru
        -- the record_url for a batch yet
        on
            glb.pk_journal_id = ru.intacct_recordno
            and ru.intacct_object = 'GLBATCH'
    left join {{ ref('stg_es_warehouse_public__markets') }} as m
        on gle.market_id::varchar = m.market_id::varchar
    left join {{ ref('stg_analytics_intacct__user') }} as u_c
        on gle.fk_created_by_user_id = u_c.pk_user_id
    left join {{ ref('stg_analytics_intacct__user') }} as u_m
        on gle.fk_updated_by_user_id = u_m.pk_user_id
