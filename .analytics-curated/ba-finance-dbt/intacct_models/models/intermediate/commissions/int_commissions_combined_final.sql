with unioned_data as (
    select
        *,
        'TAM' as source
    from {{ ref("int_commissions_tam") }}

    union all

    select
        *,
        'NAM' as source
    from {{ ref("int_commissions_nam") }}

    union all

    select *,
    'RC' as source

    from {{ ref("int_commissions_rc")}}

    union all

    select *,
    'Clawbacks' as source

    from {{ ref("int_commissions_clawbacks") }}
    where credit_note_line_item_id is null

    union all

    select
        *,
        'Reimbursements' as source

    from {{ ref("int_commissions_reimbursements") }}
    where credit_note_line_item_id is null

    union all

    select
        *,
        'Credits' as source

    from {{ ref("int_commissions_credits") }}
)

select
    ud.commission_id,
    ud.line_item_id,
    ud.salesperson_user_id,
    ud.credit_note_line_item_id,
    ud.manual_adjustment_id,
    ud.transaction_type,
    ud.commission_type,
    ud.transaction_date,
    ud.commission_rate,
    ud.split,
    ud.reimbursement_factor,
    nullifzero(
        greatest(
            coalesce(ud.override_rate, 0),
            coalesce(ico.employee_override_rate, 0),
            coalesce(ico.company_override_rate, 0),
            coalesce(ico.line_item_override_rate, 0)
        )
    ) as override_rate,
    coalesce(ico.is_exception, false) as exception,
    ud.amount,
    ud.source
from unioned_data ud
left join {{ ref("int_commissions_overrides") }} ico 
    on ud.line_item_id = ico.line_item_id
    and ud.salesperson_user_id = ico.salesperson_user_id
where ud.transaction_date::date >= '2024-01-01'
