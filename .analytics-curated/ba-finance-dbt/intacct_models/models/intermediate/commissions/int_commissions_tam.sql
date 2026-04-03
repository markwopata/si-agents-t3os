{% set tam_id = generate_commission_id(
        'line_item_id',
        'salesperson_user_id',
        '0',
        '0',
        '1',
        '1'
    ) %}


with commission_data as (
    select
        lid.line_item_id,
        lid.billing_approved_date,
        lid.line_item_type_id,
        lid.salesperson_user_id,
        lid.salesperson_type_id,
        lid.rate_tier_id,
        lid.commission_percentage,
        lid.company_name,
        pm.margin_commission,
        pm.margin_used,
        lid.amount,
        count(iff(lid.salesperson_type_id = 2, lid.salesperson_user_id, null))
            over (partition by lid.line_item_id)
            as secondary_rep_count
    from {{ ref("int_commissions_line_item_details") }} as lid
        left join {{ ref("stg_analytics_commission__parts_margin") }} as pm
            on lid.line_item_id = pm.line_item_id
    where lid.sales_person_type != 'NAM Salesperson'
        and lid.amount != 0
        and (
            (
                lid.line_item_type_id in (5, 6, 8, 44, 108, 109) -- Rental line item types
                and lid.billing_approved_date::date >= '2023-01-01'
            )
            or (
                lid.line_item_type_id in (49) -- Parts line item type
                and lid.billing_approved_date >= '2024-01-01'
                and pm.line_item_id is not null
            )
            or (lid.line_item_type_id in (129, 130, 131, 132)) -- Fuel line item types
            or (
                lid.line_item_type_id = 43 -- RPO Rental Revenue line item type
                and lid.billing_approved_date::date >= '2024-09-01'
            )
        )
)

select
{{ generate_commission_id(
        'line_item_id',
        'salesperson_user_id',
        '0',
        '0',
        '1',
        '1') }} as commission_id,
    line_item_id,
    salesperson_user_id,
    null as credit_note_line_item_id,
    null as manual_adjustment_id,
    1 as transaction_type,
    1 as commission_type,
    billing_approved_date::timestamp_ntz as transaction_date,

    ---- Commission rate calculation ----
    case
        -- Propane
        when line_item_type_id = 132
            then 0.03

        -- Parts Commission
        when
            line_item_type_id = 49
            and (salesperson_type_id = 1 or salesperson_type_id is null)
            then 0.03 + margin_commission
        when
            line_item_type_id = 49
            and salesperson_type_id != 1
            then 0.01 + margin_commission

        -- Other Rental Commission
        when line_item_type_id in (6, 108, 109)
            then 0.04

        --RPO Rental Commission
        when
            line_item_type_id in (8, 6, 108, 109)
            and right(company_name, 5) = '(RPO)'
            then 0.02

        when line_item_type_id = 43
            then 0.02

        -- Rates controlled by rate achievement
        when line_item_type_id in (5, 8, 44, 129, 130, 131) and commission_percentage is not null
            then commission_percentage

        else 0
    end as commission_rate,

    ---- Commission split calculation ----
    case
        when line_item_type_id = 49
            then 1
        when
            salesperson_type_id = 1
            and secondary_rep_count > 0
            then 0.50
        when
            salesperson_type_id = 1
            and secondary_rep_count = 0
            then 1
        when
            salesperson_type_id = 2
            and secondary_rep_count > 0
            then 0.50 / secondary_rep_count
        else 0
    end as split,

    null as reimbursement_factor,
    null as override_rate,
    false as exception,
    ---- Commission amount calculation ----
    case
        when line_item_type_id = 49
            then margin_used
        else amount
    end as amount
from commission_data
where billing_approved_date >= '2024-09-01'

{% if not var('ignore_finalized_filter', false) %}
and {{ tam_id }} not in (
    select commission_id
    from {{ ref('int_commissions_finalized_data') }}
)
{% endif %}

