SELECT 
    quote_line_item_key
    , quote_key
    , created_date_key
    , quote_customer_key
    , market_key
    , order_key
    , part_key
    , equipment_class_key

    , requested_start_date_key
    , requested_start_time_key
    , requested_end_date_key
    , requested_end_time_key
    , expiration_date_key
    , expiration_time_key

    , quote_line_item_id
    , line_item_description
    , selected_rate_type_name
    , line_item_type_name
    , note
    , num_days_quoted
    , quantity
    , shift_id
    , multiplier
    , shift_name
    , day_rate
    , week_rate
    , four_week_rate
    , flat_rate
    
    , _updated_recordtimestamp

FROM {{ ref('fact_quote_line_items') }}
