select 
        quote_escalation_key
        , quote_key
        , quote_created_date_key
        , quote_escalated_date_key
        , escalated_by_user_key
        , quote_customer_key

        , quote_escalation_id
        , num_days_to_escalation
        , escalation_reason
        , has_attachment
        , attachment_filepath
        
        , _created_recordtimestamp
        , _updated_recordtimestamp

FROM {{ ref('fact_quote_escalations') }}