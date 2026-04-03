with unioned_data as (
    select 
        *,
        'TAM' as source
    from {{ ref("int_retail_sales_commissions_tam")}}

    union all

    select 
        *,
        'NAM' as source
    from {{ ref("int_retail_sales_commissions_nam")}}

    union all

    select 
        *,
        'Credits' as source
    from {{ ref("int_retail_sales_commissions_credits")}}
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
    coalesce(ico.is_exception, false) as exception,
    ud.amount
from unioned_data ud
left join {{ ref("int_commissions_overrides") }} ico 
    on ud.line_item_id = ico.line_item_id
    and ud.salesperson_user_id = ico.salesperson_user_id
where (ud.transaction_date::date >= '2024-06-01' or ud.transaction_date is null) 
