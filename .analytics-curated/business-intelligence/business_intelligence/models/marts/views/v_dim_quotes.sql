select 
    quote_key
    , quote_source
    , quote_id
    , quote_number
    , quote_status
    , missed_quote_reason
    , missed_quote_reason_other
    , po_id
    , po_name
    , project_type
    , delivery_type
    , has_pdf
    , is_tax_exempt
    , quote_source
    , is_guest_request

    , has_equipment_rentals
    , has_accessories
    , has_sale_items
    
    , _created_recordtimestamp
    , _updated_recordtimestamp

from {{ ref('dim_quotes') }}