{{ config(
    materialized='table'
) }}

-- Base model for invoice line items with all dimension joins
-- Replaces the inline fact_line_items CTE pattern used across T3 staging tables
-- Matches legacy V_LINE_ITEMS pattern for reusability
-- Includes ROW_NUMBER() for deduplication (one row per invoice_id × rental_id × asset_id combination)

select 
    di.invoice_id,
    di.invoice_no,
    di.invoice_billing_approved,
    i.invoice_date,
    i.billing_approved_date,
    i.ordered_by_user_id,
    dr.rental_id,
    dr.rental_status_id,
    r.start_date as rental_start_date,
    r.end_date as rental_end_date,
    coalesce(da.asset_id, null) as asset_id,
    da.asset_custom_name,
    da.asset_equipment_class_name,
    do.order_id,
    i.purchase_order_id,  -- Use purchase_order_id from invoices table (matches legacy query)
    o.user_id as order_user_id,
    o.market_id,
    dpo.purchase_order_name,
    dpo.purchase_order_start_date,
    dpo.purchase_order_company_id,
    du_order.user_full_name as ordered_by,
    dc_vendor.company_name as vendor,
    fild.invoice_line_details_amount as amount,
    fild.invoice_line_details_tax_amount as tax_amount,
    dli.line_item_type_id,
    ROW_NUMBER() OVER (
        PARTITION BY di.invoice_id, 
                     coalesce(dr.rental_id, -1), 
                     coalesce(da.asset_id, -1)
        ORDER BY di.invoice_id
    ) as rn
from {{ ref('platform', 'fact_invoice_line_details') }} fild
left join {{ ref('platform', 'dim_invoices') }} di 
    on fild.invoice_line_details_invoice_key = di.invoice_key
left join {{ ref('platform', 'invoices') }} i
    on i.invoice_id = di.invoice_id
    and i._invoices_effective_delete_utc_datetime is null
left join {{ ref('platform', 'dim_rentals') }} dr 
    on fild.invoice_line_details_rental_key = dr.rental_key
left join {{ ref('platform', 'rentals') }} r
    on r.rental_id = dr.rental_id
    and r._rentals_effective_delete_utc_datetime is null
left join {{ ref('platform', 'dim_assets') }} da 
    on fild.invoice_line_details_asset_key = da.asset_key
left join {{ ref('platform', 'dim_line_items') }} dli 
    on fild.invoice_line_details_line_item_key = dli.line_item_key
left join {{ ref('platform', 'dim_orders') }} do 
    on fild.invoice_line_details_order_key = do.order_key
left join {{ ref('platform', 'orders') }} o 
    on o.order_id = do.order_id
    and o._orders_effective_delete_utc_datetime is null
left join {{ ref('platform', 'dim_purchase_orders') }} dpo 
    on dpo.purchase_order_id = i.purchase_order_id  -- Use purchase_order_id from invoices table
left join {{ ref('platform', 'dim_users') }} du_order 
    on du_order.user_id = o.user_id
left join {{ ref('platform', 'dim_markets') }} dm 
    on dm.market_id = o.market_id
left join {{ ref('platform', 'dim_companies') }} dc_vendor 
    on dc_vendor.company_id = dm.market_company_id
where di.invoice_id > 0  -- Filter out invoice_id = -1 to match V_LINE_ITEMS behavior
    -- Note: amount != 0 filter is NOT applied here - let consumers decide where to filter

