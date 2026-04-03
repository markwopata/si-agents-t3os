SELECT
    company_key
    , salesperson_user_key
    , salesperson_key
    , first_account_date_ct_key
    , credit_application_type
    , first_account_source
    , notes
    , is_locked

    , _created_recordtimestamp
    , _updated_recordtimestamp

FROM {{ ref('fact_company_customer_start') }} 