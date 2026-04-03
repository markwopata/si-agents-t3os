{% set reimbursement_id = generate_commission_id(
        're.line_item_id',
        're.salesperson_user_id',
        're.credit_note_line_item_id',
        're.manual_adjustment_id',
        '3',
        're.commission_type_id'
    ) %}


with all_reimbursements as (
    select
        lid.line_item_id,
        lid.salesperson_user_id,
        datediff(day, lid.billing_approved_date, lid.paid_date) as days_to_pay,
        case
            when days_to_pay <= 180
                then 1
            when days_to_pay <= 210
                then 0.75
            when days_to_pay <= 240
                then 0.5
            when days_to_pay <= 270
                then 0.25
            when days_to_pay > 270
                then 0
        end as reimbursement_factor,
        lid.paid_date::timestamp_ntz as transaction_date
    from {{ ref("int_commissions_line_item_details") }} as lid
    where reimbursement_factor is not null
),

reimbursement_eligible as (
    select
        c.line_item_id,
        c.salesperson_user_id::int as salesperson_user_id,
        c.credit_note_line_item_id,
        c.manual_adjustment_id,
        c.commission_type_id,
        c.commission_rate,
        c.override_rate,
        c.split,
        c.amount
    from {{ ref("int_commissions_finalized_data") }} as c
    where c.transaction_type_id = 2

    union all

    select
        cl.line_item_id,
        cl.salesperson_user_id::int as salesperson_user_id,
        cl.credit_note_line_item_id,
        cl.manual_adjustment_id,
        cl.commission_type_id,
        cl.commission_rate,
        cl.override_rate,
        cl.split,
        cl.amount
    from {{ ref("int_commissions_clawbacks") }} as cl

)

select distinct
    {{ generate_commission_id(
        're.line_item_id',
        're.salesperson_user_id',
        're.credit_note_line_item_id',
        're.manual_adjustment_id',
        '3',
        're.commission_type_id'
    ) }} as commission_id,
    re.line_item_id,
    re.salesperson_user_id,
    re.credit_note_line_item_id,
    re.manual_adjustment_id,
    3 as transaction_type_id,
    re.commission_type_id,
    ar.transaction_date,
    re.commission_rate,
    re.split,
    ar.reimbursement_factor,
    re.override_rate,
    false as exception,
    re.amount * -1 as amount
from reimbursement_eligible as re
    inner join all_reimbursements as ar
        on re.line_item_id = ar.line_item_id
            and (
                re.salesperson_user_id = ar.salesperson_user_id
                or re.commission_type_id = 2
            )

{% if not var('ignore_finalized_filter', false) %}
where {{ reimbursement_id }} not in (
    select commission_id
    from {{ ref('int_commissions_finalized_data') }}
)
{% endif %}

