with filter_gl_detail as (
    select
        market_id,
        account_number,
        'GL Entry Record Number' as transaction_number_format,
        fk_gl_entry_id::varchar as transaction_number,
        journal_title as description,
        entry_date::date as gl_date,
        'GL Batch' as document_type,
        journal_transaction_number::varchar as document_number,
        url_journal as url_sage,
        null as url_concur,
        null as url_admin,
        null as url_t3,
        amount,
        object_construct('pk_gl_detail_id', pk_gl_detail_id) as additional_data,
        'ANALYTICS.INTACCT' as source,
        'Payroll INTACCT Journal Entries - GL' as load_section,
        '{{ this.name }}' as source_model
    from {{ ref('gl_detail') }}
    where {{ live_branch_earnings_date_filter(date_field='entry_date', timezone_conversion=false) }}
        and journal_transaction_number not in ({{ dropped_branch_earnings_journal_entries() }})
        and created_by_username != 'APA_TRUE_UP'
        and intacct_module not in ('3.AP', '4.AR', '9.PO')
        and journal_title not ilike '%profit sharing%'
        and journal_title not ilike '%1240 - Non-CC region/district allocation entry%'
        and journal_title not ilike '%1275 - Entry to reclassify external service expense to new account for better P&L reporting%'
        and
        (
            account_name ilike '%PAYROLL%'
            or
            (
                account_name ilike '%COMMISSION%'
                and
                account_name not ilike '%REVEN%'
            )
        )
)

select
    market_id,
    account_number,
    transaction_number_format,
    transaction_number,
    description,
    gl_date,
    document_type,
    document_number,
    url_sage,
    url_concur,
    url_admin,
    url_t3,
    amount,
    additional_data,
    source,
    load_section,
    source_model
from filter_gl_detail
