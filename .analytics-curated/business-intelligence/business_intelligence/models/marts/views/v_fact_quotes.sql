SELECT 
    quote_key
    , created_date_key
    , updated_date_key
    , quote_customer_key
    , market_key
    , quote_created_by_user_key
    , quote_contact_user_key
    , converted_to_order_by_user_key
    , order_key

    , requested_start_date_key
    , requested_start_time_key
    , requested_end_date_key
    , requested_end_time_key
    , expiration_date_key
    , expiration_time_key

    , num_days_quoted
    , rental_subtotal
    , sale_items_subtotal
    , equipment_charges
    , delivery_fee
    , pickup_fee
    , sales_tax
    , total_rpp_price
    , total_price
    
    , _created_recordtimestamp
    , _updated_recordtimestamp

FROM {{ ref('fact_quotes') }}