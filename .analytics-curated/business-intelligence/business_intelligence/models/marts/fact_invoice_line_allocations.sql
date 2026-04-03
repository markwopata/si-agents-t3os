{{ config(
    materialized='table'
) }}

/*
    Fact Table: Invoice Line Item Allocations
    
    Purpose:
    - Core fact table for invoice spend analysis and allocation
    - Contains only surrogate keys and measures (dimensional modeling best practice)
    - References int_invoice_line_item_allocations for detailed allocation logic
    
    Grain: One row per invoice line item × location allocation
    
    This fact table enables:
    - Spend analysis by jobsite/location
    - Spend analysis by equipment class (via rental → equipment_class)
    - Spend analysis by purchase order
    - Cross-dimensional spend analysis (jobsite × class × PO)
    - Budget tracking and allocation
    - Temporal allocation toggle (with/without temporal logic)
*/

WITH allocations AS (
    SELECT * FROM {{ ref('int_invoice_line_item_allocations') }}
    
    {% if is_incremental() -%}
    WHERE {{ filter_incremental_with_buffer_day('_created_recordtimestamp', 1) }}
    {%- endif -%}
)

SELECT
    -- Surrogate Keys
    {{ dbt_utils.generate_surrogate_key([
        "'ESDB'",
        'invoice_line_item_id',
        'location_id',
        'rental_location_start_date',
        'rental_location_end_date'
    ]) }} AS invoice_line_allocation_key,
    
    {{ dbt_utils.generate_surrogate_key(["'ESDB'", 'invoice_line_item_id']) }} AS invoice_line_item_key,
    {{ dbt_utils.generate_surrogate_key(["'ESDB'", 'invoice_id']) }} AS invoice_key,
    {{ dbt_utils.generate_surrogate_key(["'ESDB'", 'rental_id']) }} AS rental_key,
    {{ dbt_utils.generate_surrogate_key(["'ESDB'", 'asset_id']) }} AS asset_key,
    {{ dbt_utils.generate_surrogate_key(["'ESDB'", 'location_id']) }} AS location_key,
    {{ dbt_utils.generate_surrogate_key(["'ESDB'", 'purchase_order_id']) }} AS purchase_order_key,
    {{ dbt_utils.generate_surrogate_key(["'ESDB'", 'company_id']) }} AS company_key,
    {{ dbt_utils.generate_surrogate_key(["CAST(billing_approved_date AS DATE)"]) }} AS billing_approved_date_key,
    
    -- Natural Keys (degenerate dimensions)
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
    
    -- Degenerate dimensions (high-cardinality IDs)
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
    -- Note: Corrected from legacy Looker bug (uses float division, not integer division)
    -- Legacy bug caused partial overlaps to show $0 due to integer division
    allocated_line_item_amount,
    allocated_tax_amount,
    allocated_total_amount,
    
    -- Audit columns
    _created_recordtimestamp,
    _updated_recordtimestamp

FROM allocations
