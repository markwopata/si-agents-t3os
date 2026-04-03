{{ config(
    materialized='incremental',
    unique_key=['quote_customer_id'], 
    incremental_strategy='merge',
    merge_exclude_columns = ['_created_recordtimestamp']
) }} 


with updated_customers_with_companies as (
        select
            quote_customer_id
            , company_id
            , _valid_from
            , _valid_to
        from {{ ref('stg_quotes__customers_pit') }}
        where _is_deleted = false
        and company_id is not null 
        and ({{ filter_source_updates('_valid_from', buffer_amount=1, time_unit='day') }})
        {% if is_incremental() -%}
        -- exclude companies that already exist in the target table
        and company_id not in (select company_id from {{ this }})
        {%- endif -%}
    )
    
    -- pull in the full PIT records for the customers that now have a company_id populated
    , customers_pit as (
        select
            quote_customer_id
            , company_id
            , _valid_from
            , _valid_to
        from {{ ref('stg_quotes__customers_pit') }}
        where quote_customer_id in (select quote_customer_id from updated_customers_with_companies)
    )

   -- match up changes in time for company_id per customer
    , customers_with_next_company as (
        select
            quote_customer_id
            , company_id
            , lead(company_id) over (
                partition by quote_customer_id
                order by _valid_from
            ) as next_company_id
            , _valid_from
            , _valid_to
        from customers_pit
    )
    
    -- identify when company_id is updated from null to non-null
    , quote_customer_updated_company as (
        select
            quote_customer_id
            , next_company_id as company_id
            , _valid_from
            , _valid_to
        from customers_with_next_company
        where company_id is null and next_company_id is not null
    )

    -- use companies PIT table to figure out when the company first showed up
    , company_creation as (
        select
            company_id
            , _companies_effective_start_utc_datetime as created_timestamp

        from {{ ref('platform', 'companies_pit') }}
        where company_id in (
            select distinct company_id
            from quote_customer_updated_company 
        )
        qualify row_number() over (
            partition by company_id
            order by _companies_effective_start_utc_datetime asc
        ) = 1
    )

    -- isolate companies that were created after the quote customer was updated
    , converted_customers as (
        select
            uc.quote_customer_id
            , uc.company_id
            , c.created_timestamp as converted_timestamp
            , uc._valid_from
            , uc._valid_to

        from quote_customer_updated_company uc
        join company_creation c
            on uc.company_id = c.company_id
            and c.created_timestamp >= uc._valid_from
            and c.created_timestamp < uc._valid_to
    )

     -- pre-filter and rank quotes for all converted customers (scans int_quotes only once)
    , relevant_quotes as (
        select
            q.quote_id
            , q.quote_customer_id
            , q.created_date
            , q.quote_source
            , row_number() over (
                partition by q.quote_customer_id
                order by q.created_date desc
            ) as rn
        from converted_customers cc
        left join {{ ref('int_quotes') }} q
            on COALESCE(q.quote_customer_id, 'Unknown') = COALESCE(cc.quote_customer_id, 'Unknown')
            and q.created_date <= cc.converted_timestamp -- Quote created before company was created
            and q.created_date >= cc._valid_from  -- Quote created after customer updated with company
            and q.created_date < cc._valid_to     -- Quote created before the next update or end of validity
    )

    , converted_quote_customers as (
        select
            rq.quote_source
            , rq.quote_id
            , cc.quote_customer_id
            , cc.company_id
            , cc.converted_timestamp

        from converted_customers cc 
        join relevant_quotes rq 
            ON cc.quote_customer_id = rq.quote_customer_id and rq.rn = 1
    )


select 
    quote_source
    , quote_id
    , quote_customer_id
    , company_id
    , converted_timestamp

    , {{ get_current_timestamp() }} AS _created_recordtimestamp
    , {{ get_current_timestamp() }} AS _updated_recordtimestamp
    
from converted_quote_customers c