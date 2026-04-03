with nam_commission_data as (
    select 
        lid.line_item_id,
        lid.billing_approved_date,
        lid.paid_date,
        lid.line_item_type_id,
        lid.salesperson_user_id,
        lid.salesperson_type_id,
        lid.company_name,
        lid.amount,
        lid.RATE_TIER_ID,
        lid.RATE_TIER_NAME,

    from {{ ref("int_retail_sales_commissions_line_item_details") }} lid
        WHERE lid.sales_person_type = 'NAM Salesperson'
    qualify row_number() over (partition by lid.line_item_id order by lid.salesperson_type_id) = 1
)
select 
    {{ generate_commission_id(
        'line_item_id',
        'salesperson_user_id',
        '0',
        '0',
        '1',
        '2') }} as commission_id,
    line_item_id,
    salesperson_user_id,
    null as credit_note_line_item_id,
    null as manual_adjustment_id,
    1 as transaction_type,
    2 as commission_type,
    paid_date::timestamp_ntz as transaction_date,
    case 
        when rate_tier_id = 64 then 0
        else 0.0025
    end as commission_rate,
    1 as split,
    null as reimbursement_factor,
    false as exception,
    amount
from nam_commission_data
where (paid_date::date >= '2025-02-01' OR paid_date is null)
