select
    rsc.market_id,
    (case
        when rsc.description ilike '%Cost Type: other%' then '5006'
        when rsc.description ilike '%Cost Type: inbound freight%' then '6014'
        when rsc.description ilike '%Cost Type: outbound freight%' then '6014'
        when rsc.description ilike '%Cost Type: transfer freight%' then '6031'
        when rsc.description ilike '%Cost Type: fuel%' then '6309'
        when rsc.description ilike '%Cost Type: pdi%' then '6310'
        when rsc.description ilike '%Cost Type: preventative maintenance%' then '6310'
        when rsc.description ilike '%Cost Type: service order%' then '6310'
        when rsc.description ilike '%Cost Type: part order%' then 'GDDAB'
    end) as acctno,
    rsc.transaction_number_format,
    rsc.transaction_number,
    'Dealership Sales Offset - ' || rsc.description as description,
    rsc.gl_date,
    rsc.document_type,
    rsc.document_number,
    rsc.url_sage,
    rsc.url_concur,
    rsc.url_admin,
    rsc.url_t3,
    -rsc.amount as amount,
    rsc.additional_data,
    rsc.source,
    'Retail Sales COGS Offsets' as load_section,
    '{{ this.name }}' as source_model
from {{ ref('int_live_branch_earnings_sales_cogs_retail') }} as rsc
where (
    rsc.description ilike '%Cost Type: other%'
    or rsc.description ilike '%Cost Type: inbound freight%'
    or rsc.description ilike '%Cost Type: outbound freight%'
    or rsc.description ilike '%Cost Type: transfer freight%'
    or rsc.description ilike '%Cost Type: fuel%'
    or rsc.description ilike '%Cost Type: pdi%'
    or rsc.description ilike '%Cost Type: preventative maintenance%'
    or rsc.description ilike '%Cost Type: service order%'
    or rsc.description ilike '%Cost Type: part order%'
)
