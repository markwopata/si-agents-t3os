with invoices as (
    select
        ih.bt_branch_id,
        concat('IN-', il.invoice_line_id) as line_id,
        il.invoice_id::varchar as header_id,
        concat('IN#', ih.invoice_number) as header_number,
        il.description,
        il.unit_amount,
        -1 * il.total_cost as total_cost,
        il.total_amount,
        il.total_tax,
        il.total_margin,
        il.datetime_created::date as datetime_created,
        il.quantity,
        il.product_id,
        case
            when p.product_type_id in (1, 5, 6, 7, 10, 11, 12, 13) then '5015'
            when p.product_type_id in (110) then coalesce(molt.gl_code_sales, '5015')
            else 'other'
        end as rev_gl_code,
        case
            when p.product_type_id in (1, 5, 6, 7, 10, 11, 12, 13) then '6034'
            when p.product_type_id in (110) then '7409'
            else 'other'
        end as exp_gl_code,
        'IN' as line_type
    from {{ ref("stg_analytics_bt_dbo__invoice_line") }} as il
        inner join {{ ref("stg_analytics_bt_dbo__invoice_header") }} as ih
            on il.invoice_id = ih.invoice_id
        left join {{ ref("stg_analytics_bt_dbo__product") }} as p
            on il.product_id = p.pk_product_id
        left join {{ ref("stg_analytics_bt_dbo__manual_order_line_type") }} as molt
            on p.pk_product_id = molt.product_id
),

credit_notes as (
    select
        ch.bt_branch_id,
        concat('CR-', cl.credit_note_line_id) as line_id,
        cl.credit_note_id::varchar as header_id,
        concat('CR#', ch.credit_note_number) as header_number,
        cl.description,
        cl.unit_amount * -1 as unit_amount,
        cl.total_cost,
        cl.total_amount * -1 as total_amount,
        cl.total_tax,
        cl.total_margin,
        ch.datetime_released::date as datetime_created,
        cl.quantity,
        cl.product_id,
        case
            when p.product_type_id in (1, 5, 6, 7, 10, 11, 12, 13) then '5015'
            when p.product_type_id in (110) then coalesce(molt.gl_code_sales, '5015')
            else 'other'
        end as rev_gl_code,
        case
            when p.product_type_id in (1, 5, 6, 7, 10, 11, 12, 13) then '6034'
            when p.product_type_id in (110) then '7409'
            else 'other'
        end as exp_gl_code,
        'CR' as line_type
    from {{ ref("stg_analytics_bt_dbo__credit_note_line") }} as cl
        inner join {{ ref("stg_analytics_bt_dbo__credit_note_header") }} as ch
            on cl.credit_note_id = ch.credit_note_id
        left join {{ ref("stg_analytics_bt_dbo__product") }} as p
            on cl.product_id = p.pk_product_id
        left join {{ ref("stg_analytics_bt_dbo__manual_order_line_type") }} as molt
            on p.pk_product_id = molt.product_id
    where ch.datetime_released is not null
)

select *
from invoices
where line_id not in ('IN-531461', 'IN-528388') -- temp fix to remove incorrect data input by branch

union all

select *
from credit_notes
where line_id not in ('CR-51614', 'CR-51620')
