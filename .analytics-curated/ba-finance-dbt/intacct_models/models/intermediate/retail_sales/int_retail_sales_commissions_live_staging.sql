with commission_data as (
    -- New un-finalized commission data
    select     
        commission_id,
        line_item_id,
        salesperson_user_id,
        credit_note_line_item_id,
        manual_adjustment_id,
        transaction_type,
        commission_type,
        transaction_date,
        commission_rate,
        split,
        reimbursement_factor,
        exception,
        amount,
        false as is_finalized
from {{ ref("int_retail_sales_commissions_combined_final") }}
),
commission_data_cleaned as 
(select 
    cd.commission_id,
    cd.line_item_id,
    cd.salesperson_user_id,
    lid.invoice_id,
    lid.invoice_no,
    lid.order_id,
    lid.invoice_created_date,
    lid.order_date,
    lid.market_id,
    lid.market_name,
    lid.parent_market_id,
    lid.parent_market_name,
    lid.region,
    lid.region_name,
    lid.district,
    lid.ship_to_state,
    lid.company_id,
    lid.company_name,
    lid.line_item_type_id,
    lid.line_item_type,
    lid.asset_id,
    lid.invoice_asset_make,
    lid.invoice_class_id,
    lid.invoice_class,
    lid.amount as line_item_amount,
    cd.amount,
    lid.email_address,
    lid.employee_id,
    lid.full_name,
    lid.employee_title,
    case
        when cd.transaction_type = 1 and cd.credit_note_line_item_id is not null then 'credit'
        when cd.transaction_type = 1 then 'commission'
        when cd.transaction_type = 2 then 'clawback'
        when cd.transaction_type = 3 then 'reimbursement'
    end as transaction_type,
    lid.employee_manager_id,
    lid.employee_manager,
    case when cd.commission_type = 2 then 1 else lid.salesperson_type_id end as salesperson_type_id,
    case when cd.commission_type = 2 then 'Primary' else lid.sales_person_type end as salesperson_type,
    case
        -- Commission eligible
        when cd.transaction_type = 1 
            and cd.transaction_date between eci.guarantee_start and eci.guarantee_end then 'guarantee'
        when cd.transaction_type = 1 
            and cd.transaction_date between eci.commission_start and eci.commission_end then 'commission'

        -- Clawback / Reimbursement eligible
        when cd.transaction_type in (2,3) 
            and cd.transaction_date between eci.guarantee_start and eci.guarantee_end then 'guarantee'
        when cd.transaction_type in (2,3) 
            and cd.transaction_date between eci.commission_start and eci.commission_end
            and lid.billing_approved_date between eci.commission_start and eci.commission_end then 'commission'
        
        else 'non-salesperson'
    end as employee_type,
    lid.secondary_rep_count,
    lid.profit_margin,
    lid.nbv,
    lid.FLOOR_RATE,
    lid.BENCHMARK_RATE,
    lid.ONLINE_RATE,
    lid.rate_tier_id,
    lid.rate_tier_name,
    coalesce(cd.exception, false) as is_exception,
    accc.full_name as allocation_cost_center,
    cd.commission_rate,
    cd.transaction_date,
    lid.billing_approved_date,
    cd.split,
    cd.transaction_type as transaction_type_id,
    
    irscfd.is_payable as original_payable,
    cd.is_finalized,
    cd.reimbursement_factor,
    cd.credit_note_line_item_id,
    CASE
        WHEN cd.transaction_type = 1 AND cd.credit_note_line_item_id is not null THEN 'Credit Note Issued'
        WHEN cd.transaction_type = 2 AND cd.credit_note_line_item_id is not null THEN 'Credit Note Clawback'
        WHEN cd.transaction_type = 3 AND cd.credit_note_line_item_id is not null 
            THEN CONCAT('Credit Note ', ROUND(COALESCE(cd.reimbursement_factor, 1) * 100, 0), '% Reimbursement')

        WHEN cd.transaction_type = 1 THEN 'Commission Paid'
        WHEN cd.transaction_type = 2 THEN 'Commission 120 Day Clawback'
        WHEN cd.transaction_type = 3 THEN CONCAT('Commission ', ROUND(COALESCE(cd.reimbursement_factor, 1) * 100, 0), '% Reimbursement')
    END as transaction_description,
    date_trunc(month, cd.transaction_date) as commission_month,
    (iff(cd.commission_rate != 0, cd.commission_rate, cd.commission_rate)) 
        * cd.split 
        * coalesce(cd.reimbursement_factor, 1) 
        * (case when cd.exception and cd.transaction_type = 1 then 1
            when cd.exception then 0
            else 1 
          end)
        * cd.amount as commission_amount,
    pp.paycheck_date,
    case
        when not cd.is_finalized then true
        when current_timestamp < dateadd(day, -1, pp.paycheck_date) then true 
        else false
    end as hidden,
    0 as manual_adjustment_id
from commission_data cd
left join {{ ref("int_retail_sales_commissions_line_item_details") }} lid
    on cd.line_item_id = lid.line_item_id
    and cd.salesperson_user_id = lid.salesperson_user_id
left join {{ ref("stg_analytics_commission__employee_commission_info") }} eci 
    on cd.salesperson_user_id = eci.user_id
    and lid.billing_approved_date between coalesce(eci.guarantee_start, eci.commission_start) and eci.commission_end
left join {{ ref("stg_analytics_payroll__all_company_cost_centers") }} accc
    on lid.parent_market_id = accc.intaact
    and accc.name = 'Equipment Rental'
left join {{ ref("stg_analytics_payroll__pay_periods") }} pp 
    on comm_check_date
    and date_trunc(month, dateadd(month, -1, paycheck_date)) = date_trunc(month, cd.transaction_date)

left join {{ ref('int_retail_sales_commissions_finalized_data') }} irscfd on irscfd.commission_id = 
    {{ generate_commission_id(
            'cd.line_item_id',
            'cd.salesperson_user_id',
            '0',
            'cd.manual_adjustment_id',
            '1',
            'cd.commission_type'
        ) }})

select
commission_id,
line_item_id,
salesperson_user_id,
invoice_id,
invoice_no,
order_id,
invoice_created_date,
order_date,
market_id,
market_name,
parent_market_id,
parent_market_name,
region,
region_name,
district,
ship_to_state,
company_id,
company_name,
line_item_type_id,
line_item_type,
asset_id,
invoice_asset_make,
invoice_class_id,
invoice_class,
line_item_amount,
amount,
email_address,
employee_id,
full_name,
employee_title,
employee_manager_id,
employee_manager,
salesperson_type_id,
salesperson_type,
employee_type,
secondary_rep_count,
profit_margin,
nbv,
FLOOR_RATE,
BENCHMARK_RATE,
ONLINE_RATE,
rate_tier_id,
rate_tier_name,
is_exception,
allocation_cost_center,
commission_rate,
transaction_date,
billing_approved_date,
split,
transaction_type_id,
case
    when transaction_date is null then false --invoices that haven't been paid yet

    --  all commission entries
    when transaction_type_id = 1 and credit_note_line_item_id is null
        AND employee_type = 'commission'
        then TRUE

    -- all credit entries
    when
        (transaction_type_id = 1 and credit_note_line_item_id is not null)
        AND (
                original_payable = TRUE 
                OR original_payable IS NULL
             )
        AND employee_type = 'commission'
        
        then TRUE

    else false
end as is_payable,
original_payable,
is_finalized,
reimbursement_factor,
credit_note_line_item_id,
transaction_description,
commission_month,
commission_amount,
paycheck_date,
hidden,
manual_adjustment_id
from commission_data_cleaned
