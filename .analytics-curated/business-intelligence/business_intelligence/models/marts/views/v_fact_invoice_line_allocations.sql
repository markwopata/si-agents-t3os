SELECT
    invoice_line_allocation_key
    , invoice_line_item_key
    , invoice_key
    , rental_key
    , asset_key
    , location_key
    , purchase_order_key
    , company_key
    , billing_approved_date_key

    , invoice_line_item_id
    , invoice_id
    , rental_id
    , asset_id
    , location_id
    , invoice_line_item_type_name
    , invoice_line_item_rental_revenue

    , line_item_amount
    , line_item_tax_amount
    , purchase_order_id
    , company_id
    , invoice_no
    , billing_approved_date
    , invoice_start_date
    , invoice_end_date

    , rental_location_start_date
    , rental_location_end_date
    , overlap_seconds
    , invoice_total_seconds
    , allocation_percentage

    , original_line_item_amount
    , original_line_item_tax
    , total_line_item_count
    , prorated_amount

    , allocated_line_item_amount
    , allocated_tax_amount
    , allocated_total_amount

    , _created_recordtimestamp
    , _updated_recordtimestamp

from {{ ref('fact_invoice_line_allocations') }}

