{{ config( 
    materialized='incremental',
    unique_key=['quote_customer_key'],
    incremental_strategy='merge',
    merge_exclude_columns = ['_created_recordtimestamp']
) }}

WITH quote_customer AS (
    SELECT 
        quote_customer_id
        , quote_customer_is_archived
        , company_id 
        -- if company_id does not exist, we need the raw name from the quote
        , company_name
    FROM {{ ref('int_quote_customers') }}
    WHERE ({{ filter_transformation_updates('_updated_recordtimestamp') }})
    
)
    , cte_full_list AS (
        {% if not is_incremental() -%}
        SELECT 
            'Unknown' as quote_customer_id
            , FALSE as quote_customer_is_archived
            , -1 as company_id 
            , 'Unknown' as company_name
        UNION ALL
        {%- endif %}
        SELECT
            quote_customer_id
            , quote_customer_is_archived
            , coalesce(company_id, -1) as company_id
            , COALESCE(company_name, 'Unknown') as company_name
        FROM quote_customer
    )

    , cte_companies as (
        select company_key, company_id
        from {{ ref('platform', 'dim_companies') }}
    )


SELECT 
    {{ dbt_utils.generate_surrogate_key(
        ['quote_customer_id']
    ) }} AS quote_customer_key
    , cte.quote_customer_id
    , cte.quote_customer_is_archived

    , COALESCE( 
        quote_company.company_key, 
        {{ get_default_key_from_dim(model_name='dim_companies') }}
    ) as quote_company_key
    , cte.company_id as quote_company_id
    , cte.company_name as quote_company_name

    , {{ get_current_timestamp() }} AS _created_recordtimestamp
    , {{ get_current_timestamp() }} AS _updated_recordtimestamp

FROM cte_full_list cte

LEFT JOIN cte_companies quote_company 
    ON quote_company.company_id = cte.company_id