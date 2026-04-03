{% set clawback_id = generate_commission_id(
        'ecd.line_item_id',
        'ecd.salesperson_user_id',
        'ecd.credit_note_line_item_id',
        'ecd.manual_adjustment_id',
        '2',
        'ecd.commission_type_id'
    ) %}


with all_clawbacks as (
    select
        line_item_id,
        salesperson_user_id,
        -- Transaction date is 120 days after billing approved date as this is the date in which an invoice is "clawed back"
        dateadd(day, 120, billing_approved_date)::timestamp_ntz as transaction_date
    from {{ ref("int_commissions_line_item_details") }}
    where datediff(day, billing_approved_date, coalesce(paid_date, current_timestamp)) > 120
),

existing_commission_data as (
    select distinct
        c.commission_id,
        c.line_item_id,
        c.salesperson_user_id,
        c.credit_note_line_item_id,
        c.manual_adjustment_id,
        c.transaction_type_id,
        c.commission_type_id,
        ac.transaction_date,
        c.commission_rate,
        c.split,
        c.override_rate,
        c.amount * -1 as amount,
        false as is_finalized
    from {{ ref("int_commissions_finalized_data") }} as c
        inner join all_clawbacks as ac
            on c.line_item_id = ac.line_item_id
                and (
                    c.salesperson_user_id = ac.salesperson_user_id
                    or c.commission_type_id = 2
                ) -- Commission Type 2 is NAM, they do not appear on invoices
    where c.transaction_type_id = 1 -- Commissions type to be clawed back
)

select
    {{ generate_commission_id(
        'ecd.line_item_id',
        'ecd.salesperson_user_id',
        'ecd.credit_note_line_item_id',
        'ecd.manual_adjustment_id',
        '2',
        'ecd.commission_type_id'
    ) }} as commission_id,
    ecd.line_item_id,
    ecd.salesperson_user_id,
    ecd.credit_note_line_item_id,
    ecd.manual_adjustment_id,
    2 as transaction_type_id,
    {# TODO: move this type conversion upstream #}
    ecd.commission_type_id::int as commission_type_id,
    ecd.transaction_date,
    ecd.commission_rate,
    ecd.split,
    null as reimbursement_factor,
    ecd.override_rate,
    false as exception,
    ecd.amount
from existing_commission_data as ecd
{% if not var('ignore_finalized_filter', false) %}
where {{ clawback_id }} not in (
    select commission_id
    from {{ ref('int_commissions_finalized_data') }}
)
{% endif %}

