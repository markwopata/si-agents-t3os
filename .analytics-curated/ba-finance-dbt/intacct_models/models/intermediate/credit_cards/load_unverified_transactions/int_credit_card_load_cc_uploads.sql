/*
   date_buffer: Number of days to allow for a buffer when matching transactions to receipts.
   This allows for transactions and receipts to be matched even if the dates
   are not exactly the same.

   e.g. user swipes card on 5/5/2025, but citi transaction came through labeled 5/6/2025 - need a buffer to match these.
 */
{% set date_buffer = 5 %}

with purchases as (
    select
        p1._es_load_timestamp,
        p1.purchase_id,
        p1.submitted_at,
        p1.vendor_id,
        p1.modified_at,
        -- Coalesce purchase_account user_id to get actual card holder's user_id - supports authorized submitter 
        -- workflow.
        coalesce(u.user_id, p1.user_id) as user_id,
        p1.notes,
        p1.grand_total,
        p1.submitted_by_user_id,
        p1.vendor_name,
        p1.market_id,
        p1.account_type,
        p1.purchased_at,
        p1.image_urls,
        p1.business_sub_department_snapshot_id,
        p1.business_department_snapshot_id,
        p1.business_expense_line_snapshot_id,
        p1.inventory_received_status,
        p1.vendor_snapshot_id,
        p1.unofficial_vendor_name,
        p1.purchase_account_id,
        p1.is_personal_expense,
        p1.is_return,
        p1._es_update_timestamp
    from {{ ref('stg_procurement_public__purchases') }} as p1
        left join {{ ref('stg_procurement_public__purchase_accounts') }} as pa
            on p1.purchase_account_id = pa.purchase_account_id
        left join {{ ref('stg_es_warehouse_public__users') }} as u
            on pa.user_id = u.user_id
),

cc_transaction_receipt_uploads as (
    select
        p.user_id::varchar
        || '|'
        || p.purchased_at::date::varchar
        || '|'
        || case when p.is_return = true then -p.grand_total::varchar else p.grand_total::varchar end
        || '|'
        || row_number() over (
            partition by p.user_id, p.grand_total, date_trunc('day', p.purchased_at)
            order by p.user_id asc, p.grand_total asc, p.purchased_at asc, p.purchase_id desc
        ) as pk_upload,
        p.market_id as upload_market_id,
        p.purchase_id as upload_id,
        p.user_id as upload_user_id,
        case when p.is_return = true then -p.grand_total else p.grand_total end as upload_amount,
        p.purchased_at as upload_date,
        left(lower(p.account_type), 4) as upload_card_type,
        p.business_sub_department_snapshot_id,
        p.business_department_snapshot_id,
        p.business_expense_line_snapshot_id,
        row_number()
            over (
                partition by p.user_id, p.grand_total, date_trunc('day', p.purchased_at)
                order by p.user_id asc, p.grand_total asc, p.purchased_at asc, p.purchase_id desc
            )
            as upload_rank,
        0 as upload_matched,
        trim(p.notes) as upload_notes,
        trim(replace(replace(replace(p.image_urls, '[', ''), ']', ''), '"', '')) as upload_url,
        p.submitted_at as upload_submitted_at_date,
        p.modified_at as upload_modified_at_date,
        p.is_personal_expense,
        p.is_return
    from purchases as p
    where p.grand_total >= 0.99
        and (
            (p.purchased_at::date >= dateadd('day', -1 * {{ date_buffer }}, '2023-07-01') and p.account_type != 'FUEL')
            or (
                p.purchased_at::date >= dateadd('day', -1 * {{ date_buffer }}, '2023-08-21') and p.account_type = 'FUEL'
            )
        )
)

select * from cc_transaction_receipt_uploads
