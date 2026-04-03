{{ config(
    materialized='table'
) }}

/*
    Purpose: Calculate temporal overlaps between invoice periods and rental location assignments
    Grain: One row per invoice × rental × location × time_period overlap
    
    Note: A rental can move between locations multiple times (e.g., delivered to jobsite A, 
    returned to yard, delivered to jobsite A again). Each movement creates a separate time period.
    
    This intermediate model handles the complex temporal logic of determining:
    - When a rental was at a specific location during an invoice period
    - How many seconds of overlap occurred for each time period
    - The allocation percentage for cost distribution
*/

WITH invoice_line_rentals AS (
    -- Get unique invoice-rental combinations from line items
    -- Note: Using gold layer tables (line_items, invoices) which are already in platform's gold schema
    -- View layer (v_*) doesn't expose foreign key fields needed for joins
    SELECT DISTINCT
        li.invoice_id,
        li.rental_id
    FROM {{ ref('platform', 'line_items') }} li
    WHERE li.rental_id IS NOT NULL
      AND li._line_items_effective_delete_utc_datetime IS NULL
    
    {% if is_incremental() -%}
    AND {{ filter_incremental_with_buffer_day('li._line_items_update_utc_datetime', 1) }}
    {%- endif -%}
),

invoices AS (
    -- Get invoice period dates from platform's gold layer
    SELECT 
        i.invoice_id,
        ilr.rental_id,
        {{ dbt_utils.generate_surrogate_key(["'ESDB'", 'i.invoice_id']) }} AS invoice_key,
        i.start_date AS invoice_start_date,
        i.end_date AS invoice_end_date,
        DATEDIFF('second', i.start_date, i.end_date) AS invoice_total_seconds
    FROM {{ ref('platform', 'invoices') }} i
    INNER JOIN invoice_line_rentals ilr ON i.invoice_id = ilr.invoice_id
    WHERE i.start_date IS NOT NULL 
      AND i.end_date IS NOT NULL
      AND i._invoices_effective_delete_utc_datetime IS NULL
    
    {% if is_incremental() -%}
    AND {{ filter_incremental_with_buffer_day('i._invoices_update_utc_datetime', 1) }}
    {%- endif -%}
),

rental_locations_raw AS (
    -- Get all non-deleted location assignments from platform
    SELECT 
        rla.rental_id,
        rla.location_id,
        rla.start_date,
        rla.end_date,
        ROW_NUMBER() OVER (
            PARTITION BY rla.rental_id, rla.location_id, rla.start_date, COALESCE(rla.end_date, '9999-12-31'::TIMESTAMP_TZ)
            ORDER BY rla.date_created DESC, rla.rental_location_assignment_id DESC
        ) AS rn
    FROM {{ ref('platform', 'rental_location_assignments') }} rla
    WHERE rla._rental_location_assignments_effective_delete_utc_datetime IS NULL
),

rental_locations AS (
    -- Deduplicate: keep one record for each unique time period
    -- Note: Source table has some true duplicates (same rental, location, times, even same date_created!)
    -- We use rental_location_assignment_id as final tiebreaker
    SELECT 
        rental_id,
        location_id,
        start_date AS rental_location_start_date,
        COALESCE(end_date, CURRENT_TIMESTAMP()) AS rental_location_end_date
    FROM rental_locations_raw
    WHERE rn = 1
),

overlap_calc AS (
    SELECT 
        i.invoice_key,
        i.invoice_id,
        rl.rental_id,
        rl.location_id,
        i.invoice_start_date,
        i.invoice_end_date,
        rl.rental_location_start_date,
        rl.rental_location_end_date,
        i.invoice_total_seconds,
        
        -- Calculate overlap seconds using CASE logic
        CASE 
            -- Case 1: Rental started before invoice, ended during invoice
            WHEN rl.rental_location_start_date < i.invoice_start_date 
                 AND rl.rental_location_end_date BETWEEN i.invoice_start_date AND i.invoice_end_date
            THEN DATEDIFF('second', i.invoice_start_date, rl.rental_location_end_date)
            
            -- Case 2: Rental started before invoice, ended after invoice (full overlap)
            WHEN rl.rental_location_start_date < i.invoice_start_date 
                 AND rl.rental_location_end_date > i.invoice_end_date
            THEN DATEDIFF('second', i.invoice_start_date, i.invoice_end_date)
            
            -- Case 3: Rental started and ended during invoice period
            WHEN rl.rental_location_start_date BETWEEN i.invoice_start_date AND i.invoice_end_date
                 AND rl.rental_location_end_date BETWEEN i.invoice_start_date AND i.invoice_end_date
            THEN DATEDIFF('second', rl.rental_location_start_date, rl.rental_location_end_date)
            
            -- Case 4: Rental started during invoice, ended after invoice
            WHEN rl.rental_location_start_date BETWEEN i.invoice_start_date AND i.invoice_end_date
                 AND rl.rental_location_end_date > i.invoice_end_date
            THEN DATEDIFF('second', rl.rental_location_start_date, i.invoice_end_date)
            
            ELSE 0
        END AS overlap_seconds
        
    FROM invoices i
    INNER JOIN rental_locations rl 
        ON i.rental_id = rl.rental_id  -- JOIN ON RENTAL_ID FIRST!
        AND (rl.rental_location_start_date <= i.invoice_end_date)
        AND (rl.rental_location_end_date >= i.invoice_start_date)
)

SELECT 
    {{ dbt_utils.generate_surrogate_key([
        'invoice_key',
        'rental_id', 
        'location_id',
        'rental_location_start_date',
        'rental_location_end_date'
    ]) }} AS invoice_rental_location_overlap_key,
    
    invoice_key,
    {{ dbt_utils.generate_surrogate_key(["'ESDB'", 'rental_id']) }} AS rental_key,
    {{ dbt_utils.generate_surrogate_key(["'ESDB'", 'location_id']) }} AS location_key,
    invoice_id,
    rental_id,
    location_id,
    invoice_start_date,
    invoice_end_date,
    rental_location_start_date,
    rental_location_end_date,
    invoice_total_seconds,
    overlap_seconds,
    
    -- Calculate allocation percentage
    CASE 
        WHEN invoice_total_seconds = 0 THEN 1.0
        ELSE ROUND(overlap_seconds::FLOAT / invoice_total_seconds, 6)
    END AS allocation_percentage,
    
    {{ get_current_timestamp() }} AS _created_recordtimestamp,
    {{ get_current_timestamp() }} AS _updated_recordtimestamp
    
FROM overlap_calc
WHERE overlap_seconds >= 0  -- Include zero-overlap cases (matching legacy logic)


