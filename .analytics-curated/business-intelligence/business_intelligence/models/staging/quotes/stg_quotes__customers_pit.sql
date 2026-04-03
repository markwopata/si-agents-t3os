with source as (

    select * from {{ source('quotes', 'customer_pit') }}

),

    renamed as (
        select 
            customer_id as quote_customer_id

            , created_at
            , created_by
            , updated_at
            , updated_by
            , archived_at

            , esdb_company_id as company_id
            , name as company_name

            -- company attributes that are redundant
            , esdb_billing_location_id as company_billing_location_id
            , net_terms_id as company_net_terms_id
            , do_not_rent as company_do_not_rent

            -- metadata fields
            , _customer_last_instance_indicator
            , _customer_effective_start_utc_datetime as _valid_from
            , _customer_effective_end_utc_datetime as _valid_to
            , _customer_effective_delete_utc_datetime as _deleted_at
            , (_customer_effective_delete_utc_datetime is not null) as _is_deleted
            
        from source
    )

select * from renamed