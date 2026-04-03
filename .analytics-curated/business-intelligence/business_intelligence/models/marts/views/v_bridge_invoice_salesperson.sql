SELECT
    invoice_salesperson_key
    , invoice_key
    , salesperson_user_key
    , salesperson_key
    , salesperson_type

    , _updated_recordtimestamp
    
FROM {{ ref('bridge_invoice_salesperson') }}