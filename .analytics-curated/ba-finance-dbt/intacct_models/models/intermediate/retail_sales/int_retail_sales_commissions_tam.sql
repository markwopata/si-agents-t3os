with commission_data as (
select 
    lid.line_item_id,
    lid.billing_approved_date,
    lid.paid_date,
    lid.line_item_type_id,
    lid.salesperson_user_id,
    lid.salesperson_type_id,
    lid.rate_tier_id,
    lid.company_name,
    lid.amount,
    count(iff(lid.salesperson_type_id = 2, lid.salesperson_user_id, null)) over (partition by lid.line_item_id) as secondary_rep_count,
    lid.PROFIT_MARGIN,
    lid.RATE_TIER_ID,
    lid.RATE_TIER_NAME,
    lid.COMMISSION_RATE,
from {{ ref("int_retail_sales_commissions_line_item_details") }} lid
where lid.sales_person_type != 'NAM Salesperson'
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
    PAID_DATE::timestamp_ntz as transaction_date,
    commission_rate,
    ---- Commission split calculation ----
    case 
        when billing_approved_date::date < '2025-09-01' then 1
        else 
            case 
                when line_item_type_id in (24, 110, 81, 111, 123) -- non-dealerships are not subject for splits yet
                    then 1
                when salesperson_type_id = 1 and secondary_rep_count > 0
                    then 0.50
                when salesperson_type_id = 1 and secondary_rep_count = 0
                    then 1
                when salesperson_type_id = 2 and secondary_rep_count > 0
                    then 0.50 / secondary_rep_count
                else 0
            end
    end as split,
    null as reimbursement_factor,
    false as exception,
    amount
from commission_data
 where billing_approved_date::date >= '2024-06-01'
