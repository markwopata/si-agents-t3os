select 
    quote_customer_key
    , quote_key
    , company_key
    , converted_date_key
    , converted_time_key

    , _created_recordtimestamp
    , _updated_recordtimestamp
    
FROM {{ ref('fact_quote_customer_conversion') }}