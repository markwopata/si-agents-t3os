select
    gd.market_id,
    gd.fk_gl_entry_id::varchar as line_id,
    gd.pk_gl_detail_id::varchar as header_id,
    gd.entry_description as header_number,
    gd.entry_description as description,
    null as unit_amount,
    case when gd.account_number in ('6030', '6034', '6308', '7409') then gd.amount * -1 else 0 end as total_cost,
    case when gd.account_number in ('5009', '5015', '5300', '5990') then gd.amount else 0 end as total_amount,
    null as total_tax,
    null as total_margin,
    gd.entry_date as datetime_created,
    null as quantity,
    null as product_id,
    case when gd.account_number in ('5009', '5015', '5300', '5990') then gd.account_number else '' end as rev_gl_code,
    case when gd.account_number in ('6030', '6034', '6308', '7409') then gd.account_number else '' end as exp_gl_code,
    'sage' as line_type
from {{ ref ('gl_detail') }} as gd
where gd.entity_id = 'E7'
    and gd.account_number in ('5009', '5015', '5300', '5990', '6030', '6034', '6308', '7409')
