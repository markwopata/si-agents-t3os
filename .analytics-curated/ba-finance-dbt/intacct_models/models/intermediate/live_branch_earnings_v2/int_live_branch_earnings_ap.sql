with gl_details as (
    select
        market_id::varchar as market_id,
        account_number,
        pk_gl_detail_id::varchar as transaction_number,
        journal_title,
        entry_date as gl_date,
        intacct_module,
        journal_type,
        fk_subledger_line_id,
        url_journal as url_sage,
        amount,
        created_by_username,
        entry_description
    from {{ ref('gl_detail') }}
    where (intacct_module in ('3.AP', '9.PO') or created_by_username = 'APA_TRUE_UP')
        and {{ live_branch_earnings_date_filter(date_field='entry_date', timezone_conversion=false) }}
        and account_number::numeric >= 5000
        and market_id is not null
),

ap_details as (
    select *
    from {{ ref('ap_detail') }}
),

po_details as (
    select *
    from {{ ref('po_detail') }}
),

apa_details as (
    select *
    from {{ ref('po_detail') }}
),

joined_data as (
    select
        gl_detail.market_id,
        gl_detail.account_number,
        'gl_detail pk' as transaction_number_format,
        gl_detail.transaction_number,
        gl_detail.gl_date::date as gl_date,
        case
            when gl_detail.intacct_module = '3.AP' then 'AP Invoice Number'
            when gl_detail.journal_type = 'APA' then 'Invoice Number|Receipt Number'
            when gl_detail.intacct_module = '9.PO' then 'Receipt Number'
            else 'unrecognized ap transaction type'
        end as document_type,
        case
            when gl_detail.intacct_module = '3.AP' then coalesce(ap_detail.invoice_number, '')
            when
                gl_detail.journal_type = 'APA'
                then coalesce(apa_detail.invoice_number, '') || '|' || coalesce(apa_detail.source_document_name, '')
            when gl_detail.intacct_module = '9.PO' then coalesce(po_detail.purchase_order_number, '')
            else 'unrecognized ap transaction type'
        end as document_number,
        coalesce(po_detail.url_sage, ap_detail.url_invoice, apa_detail.url_sage) as url_sage,
        coalesce(ap_detail.url_concur, apa_detail.url_concur) as url_concur,
        null as url_admin,
        coalesce(po_detail.url_t3, source_po_detail.url_t3) as url_t3,
        gl_detail.amount,
        object_construct(
            'journal_title', gl_detail.journal_title,
            'gl_detail_pk', gl_detail.transaction_number,
            'pk_ap_detail_id', ap_detail.pk_ap_detail_id,
            'pk_po_detail_id', coalesce(po_detail.pk_po_detail_id, apa_detail.pk_po_detail_id),
            'intacct_module', gl_detail.intacct_module,
            'entry_description', gl_detail.entry_description,
            'ap_description', ap_detail.description,
            'ap_line_description', ap_detail.line_description,
            'po_item_description', coalesce(po_detail.item_description, apa_detail.item_description),
            'po_line_description', coalesce(po_detail.line_description, apa_detail.line_description),
            'po_document_name', coalesce(po_detail.document_name, apa_detail.document_name),
            'invoice_number', coalesce(po_detail.invoice_number, apa_detail.invoice_number),
            'receipt_number', coalesce(po_detail.purchase_order_number, apa_detail.source_document_name),
            'vendor_id', coalesce(po_detail.vendor_id, apa_detail.vendor_id, ap_detail.vendor_id),
            'vendor_name', coalesce(po_detail.vendor_name, apa_detail.vendor_name, ap_detail.vendor_name)
        ) as additional_data,
        'ANALYTICS.INTACCT_MODELS' as source,
        case
            when gl_detail.intacct_module = '3.AP' then 'AP - Invoice Issued'
            when
                gl_detail.journal_type = 'APA' and gl_detail.created_by_username = 'APA_TRUE_UP'
                then 'AP - Invoice Variance Adjustment'
            when
                gl_detail.intacct_module = '9.PO' and gl_detail.journal_title ilike 'Closed Purchase Order - %'
                then 'AP - Closed Receipt'
            when
                gl_detail.intacct_module = '9.PO' and gl_detail.journal_title not ilike 'Closed Purchase Order - %'
                then 'AP - Receipt Accrual'
            else 'Unrecognized AP Transaction Type'
        end as load_section,

        case when gl_detail.intacct_module = '3.AP'
                then {{ be_live_build_description([
                    {'key': 'Vendor', 'field': 'ap_detail.vendor_name'},
                    {'key': 'Description', 'field': 'ap_detail.line_description'}])
                }}

            when gl_detail.journal_type = 'APA' and gl_detail.created_by_username = 'APA_TRUE_UP'
                then 'Price Variance - '
                    || {{ be_live_build_description([
                            {'key': 'Invoice #', 'field': 'apa_detail.invoice_number'},
                            {'key': 'Receipt #', 'field': 'apa_detail.receipt_number'},
                            {'key': 'Invoice Price', 'field': 'apa_detail.extended_amount'},
                            {'key': 'Invoice Quantity', 'field': 'apa_detail.quantity'},
                            {'key': 'Vendor', 'field': 'apa_detail.vendor_name'},
                            {'key': 'Quantity Matched', 'field': 'apa_detail.quantity_remaining'}
                        ]) }}

            when gl_detail.intacct_module = '9.PO' and po_detail.document_type = 'Closed Purchase Order'
                then 'Receipt Reversal - ' || {{ be_live_build_description([
                    {'key': 'Invoice #', 'field': 'po_detail.invoice_number'},
                    {'key': 'Receipt #', 'field': 'po_detail.receipt_number'},
                    {'key': 'Vendor', 'field': 'po_detail.vendor_name'},
                    {'key': 'Received Quan.', 'field': 'po_detail.quantity'},
                    {'key': 'Description', 'field': 'po_detail.line_description'},
                    {'key': 'Price', 'field': 'po_detail.extended_amount'}
                ]) }}

            when gl_detail.intacct_module = '9.PO' and po_detail.document_type != 'Closed Purchase Order'
                then 'Receipt - ' || {{ be_live_build_description([
                    {'key': 'Receipt #', 'field': 'po_detail.receipt_number'},
                    {'key': 'Vendor', 'field': 'po_detail.vendor_name'},
                    {'key': 'Received Quan.', 'field': 'po_detail.quantity'},
                    {'key': 'Description', 'field': 'po_detail.line_description'},
                    {'key': 'Price', 'field': 'po_detail.extended_amount'}
                ]) }}

        end as description,

        '{{ this.name }}' as source_model
    from gl_details as gl_detail
        left join ap_details as ap_detail
            on gl_detail.fk_subledger_line_id = ap_detail.fk_ap_line_id
                and gl_detail.intacct_module = '3.AP'
        left join po_details as po_detail
            on gl_detail.fk_subledger_line_id = po_detail.fk_po_line_id
                and gl_detail.intacct_module = '9.PO'
        left join po_details as source_po_detail
            on po_detail.fk_source_po_line_id = source_po_detail.fk_po_line_id
        left join apa_details as apa_detail
            on split_part(gl_detail.entry_description, ' - ', 1)::varchar = apa_detail.fk_po_line_id::varchar
                and gl_detail.created_by_username = 'APA_TRUE_UP'
),

output as (

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
    from joined_data
)

select * from output
