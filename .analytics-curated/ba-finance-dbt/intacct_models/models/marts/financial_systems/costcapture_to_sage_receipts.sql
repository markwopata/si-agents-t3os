{{ 
    config(
        materialized='view'
    )
}}

with lcd as (select max(period_end_date) as last_closed from {{ ref('stg_analytics_concur__last_close_date_ap') }}),

errors as (
    select document_number
    from {{ ref('stg_analytics_ap_accrual__create_receipts_job_results') }}
    where result_status = 'error'
    group by document_number
    having count(document_number) > 5
),

success as (
    select document_number
    from {{ ref('stg_analytics_ap_accrual__create_receipts_job_results') }}
    where result_status = 'success'
)

select
    case
        when cc.pr_date_received <= lcd.last_closed then lcd.last_closed + 1
        else cc.pr_date_received
    end as date_adj,
    year(date_adj) as datecreated_year,
    month(date_adj) as datecreated_month,
    day(date_adj) as datecreated_day,
    cc.vendor_id as vendorid,
    cc.intacct_po_number as documentno,
    cc.referenceno,
    cc.vendor_term as termname,
    cc.returnto_contactname,
    cc.payto_contactname,
    cc.t3_po_created_by,
    cc.t3_pr_created_by,
    cc.received_to_store,
    cc.item_id as itemid,
    -- removed damaged quantity from calc april 2025
    cc.accepted_quantity as quantity,
    'Each' as unit,
    cc.price_per_unit as price,
    'E1' as locationid,
    cc.final_department_id as department_id,
    cc.memo,
    cc.fk_t3_purchase_order_receiver_item_id as po_line_rec_item_id,
    cc.full_part_description as part_info,
    cc.part_id
from {{ ref('costcapture_po_receipt_details') }} as cc
    cross join lcd
    left join {{ ref('stg_analytics_intacct__po_line') }} as intpo
        on cc.fk_t3_purchase_order_receiver_item_id = intpo.fk_t3_purchase_order_receiver_item_id
            and intpo.docparid = 'Purchase Order'
    left join {{ ref('stg_analytics_intacct__department') }} as d on cc.final_department_id = d.department_id
    left join errors on cc.intacct_po_number = errors.document_number
    left join success on cc.intacct_po_number = success.document_number
where cc.item_type != 'SERVICE'
    -- exclude receipts already in sage
    and intpo.document_name is null
    -- exclude receipts created in the last 12 minutes
    and cc.pr_date_created < dateadd(minute, -12, convert_timezone('America/Chicago', current_timestamp(0)))
    -- exclude unmapped vendors
    and cc.vendor_id is not null
    -- exclude inactive vendors
    and cc.vendor_status = 'active'
    -- exclude null and inactive department ids
    and d.department_id is not null
    and d.department_status = 'active'
    -- exclude certain branches
    and cc.order_branch_id not in (7521, 55924, 32198, 47399, 32199, 1491, 32200, 32197, 13481, 66875)
    -- exclude branches migrated to Vic.ai
    and d.date_vic_migration is null
    -- exclude pos that have errored more than 5 times
    and errors.document_number is null
    -- exclude pos marked as succeeded
    and success.document_number is null
    -- exclude missing item ids
    and cc.item_id is not null
    -- exclude certain item ids
    and cc.item_id not in ('A1310', 'A6315', 'A1308')
    -- excluding pre-2024 receipts
    and cc.pr_date_received >= '2024-01-01'
    -- must have a $ value
    and cc.price_per_unit > 0
    -- must have a qty value
    and cc.accepted_quantity > 0
