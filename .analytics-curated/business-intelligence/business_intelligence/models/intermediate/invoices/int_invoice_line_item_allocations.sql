{{ config(
    materialized='table'
) }}


/*
    Intermediate Model: Invoice Line Item Allocations
    
    Purpose:
    - Allocates invoice line item amounts across rental location assignments
    - Uses temporal overlap between invoice periods and location assignments
    - Produces one row per invoice_line_item × location × time_period allocation
    
    Grain: One row per invoice line item × location allocation
    
    Note: This intermediate table contains natural keys and business logic.
    The fact table (fact_invoice_line_allocations) will contain only surrogate keys.
*/

WITH line_items AS (
    -- Get ALL line items with rental_id (matching legacy - they don't filter by line_item_type!)
    -- Note: Using gold layer tables (line_items, invoices, etc.) which are already in platform's gold schema
    -- View layer (v_*) doesn't expose foreign key fields needed for joins
    SELECT 
        li.line_item_id AS invoice_line_item_id,
        li.invoice_id,
        li.rental_id,
        li.asset_id,
        lit.name AS invoice_line_item_type_name,
        CASE WHEN lit.line_item_type_id = 8 THEN TRUE ELSE FALSE END AS invoice_line_item_rental_revenue,
        -- Actual line item amounts (for CLASS flow support)
        li.amount AS line_item_amount,
        li.tax_amount AS line_item_tax_amount
    FROM {{ ref('platform', 'line_items') }} li
    LEFT JOIN {{ ref('platform', 'line_item_types') }} lit
        ON li.line_item_type_id = lit.line_item_type_id
        AND lit._line_item_types_effective_delete_utc_datetime IS NULL
    WHERE li.rental_id IS NOT NULL
      AND li._line_items_effective_delete_utc_datetime IS NULL
      
    {% if is_incremental() -%}
    AND {{ filter_incremental_with_buffer_day('li._line_items_update_utc_datetime', 1) }}
    {%- endif -%}
),

-- Get invoice totals (matching legacy logic - they use invoice.billed_amount directly)
invoice_totals AS (
    SELECT 
        invoice_id,
        billed_amount AS invoice_total_amount,
        tax_amount AS invoice_total_tax
    FROM {{ ref('platform', 'invoices') }}
    WHERE invoice_id IN (SELECT DISTINCT invoice_id FROM line_items)
      AND _invoices_effective_delete_utc_datetime IS NULL
),

-- Count ALL line items on the invoice (regardless of location!)
invoice_total_line_counts AS (
    SELECT 
        i.invoice_id,
        COUNT(DISTINCT all_li.line_item_id) AS total_line_items_on_invoice
    FROM {{ ref('platform', 'invoices') }} i
    INNER JOIN {{ ref('platform', 'line_items') }} all_li 
        ON i.invoice_id = all_li.invoice_id
        AND all_li._line_items_effective_delete_utc_datetime IS NULL
    WHERE i.invoice_id IN (SELECT DISTINCT invoice_id FROM line_items)
    GROUP BY i.invoice_id
),

-- Get company and billing information from gold layer
rental_invoice_info AS (
    SELECT DISTINCT
        li.rental_id,
        li.invoice_id,
        u.company_id,
        i.billing_approved_date,
        i.invoice_no,
        i.start_date AS invoice_start_date,
        i.end_date AS invoice_end_date,
        o.purchase_order_id,
        po.start_date as purchase_order_start_date
    FROM line_items li
    LEFT JOIN {{ ref('platform', 'rentals') }} r 
        ON li.rental_id = r.rental_id
        AND r._rentals_effective_delete_utc_datetime IS NULL
    LEFT JOIN {{ ref('platform', 'orders') }} o 
        ON r.order_id = o.order_id
        AND o._orders_effective_delete_utc_datetime IS NULL
    LEFT JOIN {{ ref('platform', 'users') }} u 
        ON o.user_id = u.user_id
        AND u._users_effective_delete_utc_datetime IS NULL
    LEFT JOIN {{ ref('platform', 'invoices') }} i 
        ON li.invoice_id = i.invoice_id
        AND i._invoices_effective_delete_utc_datetime IS NULL
    LEFT JOIN {{ ref('platform', 'purchase_orders') }} po
        ON i.purchase_order_id = po.purchase_order_id
        AND po._purchase_orders_effective_delete_utc_datetime IS NULL
    WHERE li.rental_id IS NOT NULL
),

-- Prepare line items with all necessary information
line_items_prepared AS (
    SELECT 
        li.invoice_line_item_id,
        li.invoice_id,
        li.rental_id,
        li.asset_id,
        li.invoice_line_item_type_name,
        li.invoice_line_item_rental_revenue,
        -- Invoice total amounts (for JOBSITE flow)
        it.invoice_total_amount AS original_line_item_amount,
        it.invoice_total_tax AS original_line_item_tax,
        itlc.total_line_items_on_invoice,
        -- Actual line item amounts (for CLASS flow support)
        li.line_item_amount,
        li.line_item_tax_amount,
        -- Company and billing information for filtering
        rii.company_id,
        rii.billing_approved_date,
        rii.invoice_no,
        rii.invoice_start_date,
        rii.invoice_end_date,
        rii.purchase_order_id,
        rii.purchase_order_start_date
    FROM line_items li
    LEFT JOIN invoice_totals it
        ON li.invoice_id = it.invoice_id
    LEFT JOIN invoice_total_line_counts itlc
        ON li.invoice_id = itlc.invoice_id
    LEFT JOIN rental_invoice_info rii
        ON li.invoice_id = rii.invoice_id
        AND li.rental_id = rii.rental_id
),

overlaps AS (
    SELECT * 
    FROM {{ ref('int_invoice_rental_location_overlaps') }}
    
    {% if is_incremental() -%}
    WHERE {{ filter_incremental_with_buffer_day('_created_recordtimestamp', 1) }}
    {%- endif -%}
),

allocations AS (
    SELECT 
        -- Natural Keys  
        li.invoice_line_item_id,
        li.invoice_id,
        li.rental_id,
        li.asset_id,
        ov.location_id,
        
        -- Attributes
        li.invoice_line_item_type_name,
        li.invoice_line_item_rental_revenue,
        
        -- Actual line item amounts (for CLASS flow support)
        li.line_item_amount,
        li.line_item_tax_amount,
        
        -- Company and billing information for filtering
        li.company_id,
        li.billing_approved_date,
        li.invoice_no,
        li.invoice_start_date,
        li.invoice_end_date,
        li.purchase_order_id,
        li.purchase_order_start_date,
        ov.rental_location_start_date,
        ov.rental_location_end_date,
        ov.overlap_seconds,
        ov.invoice_total_seconds,
        ov.allocation_percentage,
        
        -- Original amounts (invoice totals, matching legacy)
        li.original_line_item_amount,
        li.original_line_item_tax,
        li.total_line_items_on_invoice AS total_line_item_count,
        
        -- Prorated amount per line item (for reference: invoice_total / ALL_line_items_on_invoice)
        ROUND(COALESCE(li.original_line_item_amount, 0) / NULLIF(li.total_line_items_on_invoice, 0), 2) AS prorated_amount,
        
        -- Allocated amounts with temporal allocation (mathematically corrected)
        -- Legacy Looker query had integer division bug: (overlap_secs/invoice_seconds)::numeric = 0 for partial overlaps
        -- We use float division for mathematical correctness
        CASE 
            WHEN ov.invoice_total_seconds = 0 AND ov.overlap_seconds = 0 
            THEN ROUND(COALESCE(li.line_item_amount, 0) * 1.00, 2)
            ELSE ROUND(COALESCE(li.line_item_amount, 0) * (ov.overlap_seconds::FLOAT / ov.invoice_total_seconds), 2)
        END AS allocated_line_item_amount,
        CASE 
            WHEN ov.invoice_total_seconds = 0 AND ov.overlap_seconds = 0 
            THEN ROUND(COALESCE(li.line_item_tax_amount, 0) * 1.00, 2)
            ELSE ROUND(COALESCE(li.line_item_tax_amount, 0) * (ov.overlap_seconds::FLOAT / ov.invoice_total_seconds), 2)
        END AS allocated_tax_amount,
        CASE 
            WHEN ov.invoice_total_seconds = 0 AND ov.overlap_seconds = 0 
            THEN ROUND((COALESCE(li.line_item_amount, 0) + COALESCE(li.line_item_tax_amount, 0)) * 1.00, 2)
            ELSE ROUND((COALESCE(li.line_item_amount, 0) + COALESCE(li.line_item_tax_amount, 0)) * (ov.overlap_seconds::FLOAT / ov.invoice_total_seconds), 2)
        END AS allocated_total_amount
        
    FROM line_items_prepared li
    INNER JOIN overlaps ov
        ON li.rental_id = ov.rental_id
        AND li.invoice_id = ov.invoice_id
)

SELECT
    -- Natural Keys
    invoice_line_item_id,
    invoice_id,
    rental_id,
    asset_id,
    location_id,
    
    -- Attributes
    invoice_line_item_type_name,
    invoice_line_item_rental_revenue,
    
    -- Actual line item amounts (for CLASS flow support)
    line_item_amount,
    line_item_tax_amount,
    
    -- Degenerate dimensions
    purchase_order_id,
    company_id,
    
    -- Invoice attributes
    invoice_no,
    
    -- Date attributes (for date dimension joins and overlaps calculation)
    billing_approved_date,
    invoice_start_date,
    invoice_end_date,
    
    -- Temporal Metrics
    rental_location_start_date,
    rental_location_end_date,
    overlap_seconds,
    invoice_total_seconds,
    allocation_percentage,
    
    -- Original Amounts (for reference)
    original_line_item_amount,
    original_line_item_tax,
    total_line_item_count,
    prorated_amount,
    
    -- Allocated Amounts with temporal allocation (mathematically corrected)
    -- Note: Legacy Looker had integer division bug that caused partial overlaps to show $0
    -- We use float division for mathematical correctness
    allocated_line_item_amount,
    allocated_tax_amount,
    allocated_total_amount,
    
    -- Audit columns
    CURRENT_TIMESTAMP() AS _created_recordtimestamp,
    {{ get_current_timestamp() }} AS _updated_recordtimestamp

FROM allocations

