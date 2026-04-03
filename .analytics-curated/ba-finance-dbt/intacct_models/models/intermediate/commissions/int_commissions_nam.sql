{% set nam_id = generate_commission_id(
        'line_item_id',
        'nam_user_id',
        '0',
        '0',
        '1',
        '2'
    ) %}


with nam_commission_data as (
    select
        lid.company_name,
        lid.line_item_id,
        lid.salesperson_user_id as nam_user_id,
        lid.company_id,
        lid.billing_approved_date,
        lid.line_item_type_id,
        iff(lid.line_item_type_id = 49, coalesce(pm.margin_used, lid.amount), lid.amount) as amount
    from {{ ref("int_commissions_line_item_details") }} as lid
        left join {{ ref("stg_analytics_commission__parts_margin") }} as pm
            on lid.line_item_id = pm.line_item_id
    where lid.sales_person_type = 'NAM Salesperson'
        and lid.line_item_type_id in (
            5,	-- 'Additional Transportation'
            6,	-- 'Additional Hourly Usage'
            8,	-- 'Rental Charge'
            43,	-- 'RPO Rental Revenue'
            44,	-- 'Non-Serialized Rental Charge'
            49,	-- 'Parts Retail Sale'
            108,	-- 'Rebilled Rental Charge'
            109,	-- 'Manually Created Rental Charge'
            129,	-- 'Onsite Fuel Delivery - Diesel'
            130,	-- 'Onsite Fuel Delivery - Dyed Diesel'
            131,	-- 'Onsite Fuel Delivery - Gasoline'
            132	-- 'Onsite Fuel Delivery - Propane'
        )
        and lid.amount != 0
    qualify row_number() over (partition by lid.line_item_id order by lid.salesperson_type_id) = 1
)

select
    {{ generate_commission_id(
        'line_item_id',
        'nam_user_id',
        '0',
        '0',
        '1',
        '2') }} as commission_id,
    line_item_id,
    nam_user_id as salesperson_user_id,
    null as credit_note_line_item_id,
    null as manual_adjustment_id,
    1 as transaction_type,
    2 as commission_type,
    billing_approved_date::timestamp_ntz as transaction_date,
    case
        -- RPO Rental Revenue line item type
        when line_item_type_id = 43 or (line_item_type_id = 8 and right(company_name, 5) = '(RPO)')
            then 0.02
        when line_item_type_id in (5, 6, 8, 44, 108, 109) -- Rental line item types
            then 0.01
        when line_item_type_id in (129, 130, 131, 132) -- Fuel line item types
            then 0.0075
        when line_item_type_id = 49 -- Parts line item type
            then 0.0025
        else 0
    end as commission_rate,
    1 as split,
    null as reimbursement_factor,
    case
        when nam_user_id = 15301
            and line_item_type_id = 8
            -- These are companies that were agreed to by Jabbok for user_id 15301
            and company_id in (5658, 69021, 7531, 39192, 8935, 24813, 6855)
            and billing_approved_date >= '2024-04-01'
            and billing_approved_date < '2025-01-01'
            then 0.04
    end as override_rate,
    false as exception,
    amount
from nam_commission_data
{% if not var('ignore_finalized_filter', false) %}
where {{ nam_id }} not in (
    select commission_id
    from {{ ref('int_commissions_finalized_data') }}
)
{% endif %}

