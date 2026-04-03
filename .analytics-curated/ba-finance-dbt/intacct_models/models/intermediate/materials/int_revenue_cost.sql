with materials_map as (
    select
        bt_branch_id,
        bt_branch_code,
        market_id,
        market_name,
        bt_start_date
    from {{ ref('stg_analytics_gs__materials_branch') }}
),

unioned as (
    select
        ict.bt_branch_id,
        mm.market_id,
        ict.line_id,
        ict.header_id,
        ict.header_number,
        ict.description,
        ict.unit_amount,
        ict.total_cost,
        ict.total_amount,
        ict.total_tax,
        ict.total_margin,
        ict.datetime_created::date as datetime_created,
        ict.quantity,
        ict.product_id,
        ict.rev_gl_code,
        ict.exp_gl_code,
        ict.line_type,
        mm.market_name,
        mm.bt_start_date
    from {{ ref('int_materials_transactions') }} as ict
        inner join materials_map as mm
            on ict.bt_branch_id = mm.bt_branch_id
    where ict.datetime_created >= date_trunc('month', mm.bt_start_date) + interval '1 month'

    union all

    select
        mm.bt_branch_id,
        ims.market_id,
        ims.line_id,
        ims.header_id,
        ims.header_number,
        ims.description,
        ims.unit_amount,
        ims.total_cost,
        ims.total_amount,
        ims.total_tax,
        ims.total_margin,
        ims.datetime_created::date as datetime_created,
        ims.quantity,
        ims.product_id,
        ims.rev_gl_code,
        ims.exp_gl_code,
        ims.line_type,
        mm.market_name,
        mm.bt_start_date
    from {{ ref('int_materials_sage') }} as ims
        inner join materials_map as mm
            on ims.market_id = mm.market_id
    where ims.datetime_created <
        coalesce(
            date_trunc('month', mm.bt_start_date) + interval '1 month',
            '2099-12-31'::date
        )
)

select *
from unioned
