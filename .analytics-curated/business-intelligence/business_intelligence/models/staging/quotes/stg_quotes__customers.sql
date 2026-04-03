with source as (

    select * from {{ source('quotes', 'customer') }}

),

renamed as (

    select
        customer_id as quote_customer_id

        , created_at as created_date
        , created_by
        , updated_at as updated_date
        , updated_by
        , archived_at

        , esdb_company_id as company_id
        , name as company_name

        -- company attributes that are redundant
        , esdb_billing_location_id as company_billing_location_id
        , net_terms_id as company_net_terms_id
        , do_not_rent as company_do_not_rent

        , _es_update_timestamp

    from source

)

select * from renamed