{% set credit_id = generate_commission_id(
        'efc.line_item_id',
        'efc.salesperson_user_id',
        'c.credit_note_line_item_id',
        'efc.manual_adjustment_id',
        'efc.transaction_type_id',
        'efc.commission_type_id'
    ) %}


with credit_notes as (
    select
        cnli.line_item_id,
        cnli.credit_note_line_item_id,
        cnli.date_created::timestamp_ntz as transaction_date,
        cnli.credit_revenue as credit_amount
    from {{ ref("stg_es_warehouse_public__credit_notes") }} as cn
        inner join {{ ref("stg_es_warehouse_public__credit_note_line_items") }} as cnli
            on cn.credit_note_id = cnli.credit_note_id
    where credit_revenue != 0 -- ignoring $0 credit note lines
        and credit_note_status_id = 2 -- only approved credit notes
        and cnli.line_item_type_id not in (80, 81, 110, 111, 123, 24, 141)-- ignoring retail sales line item credits
),

eligible_for_credit as (
    select
        c.commission_id,
        c.line_item_id,
        c.salesperson_user_id,
        c.credit_note_line_item_id,
        c.manual_adjustment_id,
        c.transaction_type_id,
        c.commission_type_id,
        c.transaction_date,
        c.commission_rate,
        c.split,
        c.reimbursement_factor,
        c.override_rate,
        c.is_exception,
        c.amount
    from {{ ref("int_commissions_finalized_data") }} as c

    union all

    select *
    from {{ ref("int_commissions_tam") }}

    union all

    select *
    from {{ ref("int_commissions_nam") }}

    union all

    select *
    from {{ ref("int_commissions_rc")}}
    
    union all

    select *
    from {{ ref("int_commissions_clawbacks")}}
    where credit_note_line_item_id is null

    union all

    select *
    from {{ ref("int_commissions_reimbursements") }}
    where credit_note_line_item_id is null
)

select
    {{ generate_commission_id(
        'efc.line_item_id',
        'efc.salesperson_user_id',
        'c.credit_note_line_item_id',
        'efc.manual_adjustment_id',
        'efc.transaction_type_id',
        'efc.commission_type_id'
    ) }} as commission_id,
    efc.line_item_id,
    efc.salesperson_user_id,
    c.credit_note_line_item_id,
    efc.manual_adjustment_id,
    efc.transaction_type_id,
    efc.commission_type_id,
    greatest(c.transaction_date, efc.transaction_date) as transaction_date,
    efc.commission_rate,
    efc.split,
    efc.reimbursement_factor,
    efc.override_rate,
    efc.is_exception,
    iff(efc.amount < 0, 1, -1) * coalesce(pm.margin_used, c.credit_amount) as amount
from eligible_for_credit as efc
    inner join credit_notes as c
        on efc.line_item_id = c.line_item_id
    left join {{ ref("stg_analytics_commission__parts_margin") }} as pm
        on efc.line_item_id = pm.line_item_id
where efc.credit_note_line_item_id is null

{% if not var('ignore_finalized_filter', false) %}
    and {{ credit_id }} not in (
        select commission_id
        from {{ ref('int_commissions_finalized_data') }}
    )
{% endif %}

qualify row_number() over (
    partition by {{ credit_id }}
    order by greatest(c.transaction_date, efc.transaction_date) desc
) = 1

