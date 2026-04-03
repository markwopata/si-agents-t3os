select
    cpoli.asset_id,
    min(cpoli._company_purchase_order_line_items_effective_start_utc_datetime) as received_date
from {{ ref("stg_equipmentshare_public_silver__company_purchase_order_line_items_pit") }} as cpoli
where cpoli.order_status = 'Received'
group by cpoli.asset_id
