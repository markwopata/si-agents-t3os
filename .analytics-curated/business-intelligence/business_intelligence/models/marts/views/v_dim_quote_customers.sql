
SELECT 
    quote_customer_key
    , quote_customer_id
    , quote_customer_is_archived

    , quote_company_key
    , quote_company_id
    , quote_company_name

    , _created_recordtimestamp
    , _updated_recordtimestamp

FROM {{ ref('dim_quote_customers') }}