with source as (

    select * from {{ source('rental_order_request', 'self_signup_accounts') }}

),

renamed as (

    select
        _es_update_timestamp,
        account_id,
        created_at,
        user_id,
        registration_type,
        company_id

    from source

)

select * from renamed
