with credit_notes as (
    select 
        cnli.line_item_id,
        cnli.credit_note_line_item_id,
        cnli.date_created::timestamp_ntz as transaction_date,
        cnli.credit_revenue as credit_amount
    from {{ ref("stg_es_warehouse_public__credit_notes")}} cn
        join {{ ref("stg_es_warehouse_public__credit_note_line_items") }} cnli
            on cn.credit_note_id = cnli.credit_note_id
    where credit_revenue != 0 -- ignoring $0 credit note lines
    and credit_note_status_id = 2 -- only approved credit notes
    and (memo not ilike '%trade in%'
            AND memo not ilike '%trade-in%')
    and (
        (cnli.line_item_type_id in (80, 110, 141, 24, 81, 111, 123, 152, 153, 140) and cnli.credit_amount = cnli.amount)  -- per Lewis Horsnby & Jake Marshall, credits created due to trade-ins for equipment sales (both used and dealership) should not create credit entries to the reps. there may be edge cases where the trade-in value same as the credit amount but that's a problem for another day
    )
),
eligible_for_credit as (
    select distinct * from

    (select
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
        c.is_exception,
        c.amount
    from {{ ref("int_retail_sales_commissions_finalized_data")}} c 
    where coalesce(c.credit_note_line_item_id,0) = 0

    union all

    select 
        t.commission_id,
        t.line_item_id,
        t.salesperson_user_id,
        t.credit_note_line_item_id,
        t.manual_adjustment_id,
        t.transaction_type as transaction_type_id,
        t.commission_type as commission_type_id,
        t.transaction_date,
        t.commission_rate,
        t.split,
        t.reimbursement_factor,
        t.exception as is_exception,
        t.amount
    from {{ ref("int_retail_sales_commissions_tam")}} t 
        left join {{ ref("int_retail_sales_commissions_finalized_data")}} c on c.commission_id = t.commission_id
    where coalesce(t.credit_note_line_item_id,0) = 0
        and c.commission_id is null

    union all

    select 
        n.commission_id,
        n.line_item_id,
        n.salesperson_user_id,
        n.credit_note_line_item_id,
        n.manual_adjustment_id,
        n.transaction_type as transaction_type_id,
        n.commission_type as commission_type_id,
        n.transaction_date,
        n.commission_rate,
        n.split,
        n.reimbursement_factor,
        n.exception as is_exception,
        n.amount
    from {{ ref("int_retail_sales_commissions_nam")}} n
        left join {{ ref("int_retail_sales_commissions_finalized_data")}} c on c.commission_id = n.commission_id
    where coalesce(n.credit_note_line_item_id,0) = 0
        and c.commission_id is null
    )
),

credit_data as (select
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
    efc.transaction_type_id as transaction_type,
    efc.commission_type_id as COMMISSION_TYPE,
    cast(greatest(c.transaction_date, efc.transaction_date) AS TIMESTAMP_NTZ) as transaction_date,
    efc.commission_rate,
    efc.split,
    efc.reimbursement_factor,
    efc.is_exception as EXCEPTION,
    iff(efc.amount < 0, 1, -1) * c.credit_amount as amount
from eligible_for_credit efc 
join credit_notes c
    on efc.line_item_id = c.line_item_id
left join {{ ref('int_retail_sales_commissions_finalized_data') }} finalized
 on finalized.commission_id = {{ generate_commission_id(
        'efc.line_item_id',
        'efc.salesperson_user_id',
        '0',
        'efc.manual_adjustment_id',
        '1',
        '1'
        ) }} 
        and coalesce(finalized.credit_note_line_item_id,0) = 0
        )
select *
from credit_data