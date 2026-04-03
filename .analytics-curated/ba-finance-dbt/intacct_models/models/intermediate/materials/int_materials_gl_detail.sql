with detail_revenue_lines as (
    select
        mb.market_id,
        mt.header_number,
        mt.line_id,
        case
            when mt.header_number ilike '%in#%'
                then concat(mb.market_id, '-', regexp_substr(mt.header_number, 'in#[0-9]+', 1, 1, 'i'))
            when mt.header_number ilike '%cr#%'
                then concat(mb.market_id, '-', regexp_substr(mt.header_number, 'cr#[0-9]+', 1, 1, 'i'))
            else mt.header_number
        end as header_key,
        p.level_1_name,
        p.short_description,
        round(sum(mt.total_amount), 2) as line_amount,
        case
            when p.level_1_name ilike '%lumber%' then 'Lumber Revenue'
        end as account_name,
        'rev' as type,
        case
            when p.level_1_name ilike '%lumber%' then 'FABFL'
        end as gl_account_number
    from {{ ref('int_materials_transactions') }} as mt
        left join {{ ref('int_products') }} as p
            on mt.product_id = p.pk_product_id
        left join {{ ref('stg_analytics_gs__materials_branch') }} as mb
            on mt.bt_branch_id = mb.bt_branch_id
    where 1 = 1
    group by all
),

detail_cost_lines as (
    select
        mb.market_id,
        mt.header_number,
        mt.line_id,
        case
            when mt.header_number ilike '%in#%'
                then concat(mb.market_id, '-', regexp_substr(mt.header_number, 'in#[0-9]+', 1, 1, 'i'))
            when mt.header_number ilike '%cr#%'
                then concat(mb.market_id, '-', regexp_substr(mt.header_number, 'cr#[0-9]+', 1, 1, 'i'))
            else mt.header_number
        end as header_key,
        p.level_1_name,
        p.short_description,
        round(sum(mt.total_cost), 2) as line_amount,
        case
            when p.level_1_name ilike '%lumber%' then 'Lumber COGS'
        end as account_name,
        'exp' as type,
        case
            when p.level_1_name ilike '%lumber%' then 'GADEL'
        end as gl_account_number
    from {{ ref('int_materials_transactions') }} as mt
        left join {{ ref('int_products') }} as p
            on mt.product_id = p.pk_product_id
        left join {{ ref('stg_analytics_gs__materials_branch') }} as mb
            on mt.bt_branch_id = mb.bt_branch_id
    group by all
),

detail_lines as (
    select *
    from detail_revenue_lines
    union all
    select *
    from detail_cost_lines

),

detail_totals as (
    select
        market_id,
        header_key,
        type,
        any_value(header_number) as header_number,
        round(sum(line_amount), 2) as order_total
    from detail_lines
    group by all
),

gl_base as (
    select
        gl.pk_gl_detail_id,
        gl.fk_gl_entry_id,
        gl.entry_date,
        case when gl.account_number = '5990' then 'FJJA' else gl.account_number end as account_number,
        case when gl.account_number = '5990' then 'Materials Financing Revenue' else gl.account_name end as account_name,
        gl.account_type,
        gl.department_id,
        gl.market_id,
        gl.market_name,
        gl.department_name,
        gl.entity_id,
        gl.entry_description,
        gl.journal_title,
        gl.amount,
        gl.entry_amount,
        gl.intacct_module,
        gl.journal_type,
        gl.fk_journal_id,
        gl.journal_transaction_number,
        gl.line_number,
        gl.document,
        gl.url_journal,
        case
            when gl.entry_description ilike '%in#%'
                then concat(gl.department_id, '-', regexp_substr(gl.entry_description, 'in#[0-9]+', 1, 1, 'i'))
            when gl.entry_description ilike '%cr#%'
                then concat(gl.department_id, '-', regexp_substr(gl.entry_description, 'cr#[0-9]+', 1, 1, 'i'))
            else gl.department_id
        end as header_key,
        abs(gl.amount) as entry_amount_abs
    from {{ ref('gl_detail') }} as gl
    where gl.entity_id = 'E7'
),

matched as (
    select
        g.entry_date,
        coalesce(dl.gl_account_number, g.account_number) as gl_account_number,
        case
            when g.entry_description ilike '%in#%'
                then
                    concat(
                        'Invoice Number: ',
                        coalesce(regexp_substr(g.entry_description, 'in#([0-9]+)', 1, 1, 'i', 1), ''),
                        case when
                                dl.level_1_name is not null
                                then concat(' Product Category: ', substr(dl.level_1_name, 6))
                            else ''
                        end,
                        case when dl.short_description is not null
                                then
                                    concat(' Product: ', dl.short_description)
                            else ''
                        end
                    )
            when g.entry_description ilike '%cr#%'
                then
                    concat(
                        'Credit Number: ',
                        coalesce(regexp_substr(g.entry_description, 'cr#([0-9]+)', 1, 1, 'i', 1), ''),
                        case when
                                dl.level_1_name is not null
                                then concat(' Product Category: ', substr(dl.level_1_name, 6))
                            else ''
                        end,
                        case when dl.short_description is not null
                                then
                                    concat(' Product: ', dl.short_description)
                            else ''
                        end
                    )
            else coalesce(g.entry_description, '')
        end as entry_description,
        g.entry_amount,
        dt.header_number,
        dl.level_1_name,
        coalesce(dl.account_name, g.account_name) as account_name,
        dl.line_amount,
        dl.line_id,
        dl.type,
        dt.order_total,
        g.market_id,
        g.url_journal,
        g.fk_journal_id,
        g.fk_gl_entry_id,
        g.journal_transaction_number,
        g.pk_gl_detail_id,
        dl.level_1_name as product_category,
        dl.short_description,
        g.journal_title,
        'Matched' as status,
        g.market_name,
        g.account_type
    from gl_base as g
        inner join detail_totals as dt
            on dt.header_key = g.header_key            -- mention on 10/17 - not the best way to match
                and g.entry_amount = dt.order_total     -- this is a temporary solution for matching
        inner join detail_lines as dl
            on g.header_key = dl.header_key
                and (
                    (g.account_number in ('5015', '5300', '5009') and dl.type = 'rev')
                    or (g.account_number in ('6034') and dl.type = 'exp')
                )
    where g.account_type = 'incomestatement'

),

unmatched as (
    select
        g.*,
        case
            when g.entry_description ilike any ('%citi;%', '%navan;%', '%fuel;%', '%amex;%') then g.journal_title
            when
                g.entry_description ilike '%in#%'
                then concat('Invoice Number: ', regexp_substr(g.entry_description, 'in#([0-9]+)', 1, 1, 'i', 1))
            when
                g.entry_description ilike '%cr#%'
                then concat('Credit Number: ', regexp_substr(g.entry_description, 'cr#([0-9]+)', 1, 1, 'i', 1))
            else coalesce(g.entry_description, '')
        end as updated_entry_description,
        'Unmatched' as status
    from gl_base as g
        left join detail_totals as dt
            on g.header_key = dt.header_key
                and g.entry_amount = dt.order_total
                and g.account_type = 'incomestatement'
    where dt.header_key is null
),

final as (
    select
        concat(m.pk_gl_detail_id, '-', m.line_id, m.type) as pk,
        m.market_id,
        m.market_name,
        m.entry_date,
        m.gl_account_number,
        m.entry_description,
        m.line_amount as entry_amount,
        m.header_number,
        m.account_name,
        m.url_journal,
        m.fk_journal_id,
        m.fk_gl_entry_id,
        m.journal_transaction_number,
        m.journal_title,
        m.account_type,
        m.product_category,
        m.short_description,
        m.status,
        round(m.order_total - sum(m.line_amount) over (partition by m.header_number, m.entry_amount), 2) as diff
    from matched as m

    union all

    select
        u.pk_gl_detail_id as pk,
        u.market_id,
        u.market_name,
        u.entry_date,
        u.account_number as gl_account_number,
        u.updated_entry_description as entry_description,
        u.amount as entry_amount,
        null as header_number,
        u.account_name,
        u.url_journal,
        u.fk_journal_id,
        u.fk_gl_entry_id,
        u.journal_transaction_number,
        u.journal_title,
        u.account_type,
        null as product_category,
        null as short_description,
        u.status,
        null as diff
    from unmatched as u
)

select *
from final
