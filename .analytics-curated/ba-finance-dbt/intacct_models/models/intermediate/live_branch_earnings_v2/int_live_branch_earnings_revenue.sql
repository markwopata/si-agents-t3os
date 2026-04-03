select
    market_id,
    iff(is_rerent_asset and account_number = '5000', 'FAAA', account_number) as account_number,
    transaction_number_format,
    transaction_number,
    description,
    gl_date::date as gl_date,
    document_type,
    document_number,
    url_sage,
    url_concur,
    url_admin,
    url_t3,
    amount,
    object_construct(
        'asset_id', asset_id,
        'vendor_id', vendor_id,
        'invoice_id', invoice_id,
        'line_item_id', line_item_id
    ) as additional_data,
    source,
    load_section,
    '{{ this.name }}' as source_model
from {{ ref('int_live_branch_earnings_base_invoices') }}
where {{ live_branch_earnings_date_filter(date_field='gl_date', timezone_conversion=true) }}
