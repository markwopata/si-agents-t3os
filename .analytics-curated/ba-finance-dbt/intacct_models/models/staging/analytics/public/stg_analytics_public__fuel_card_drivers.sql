with source as (

    select * from {{ source('analytics_public', 'fuel_card_drivers') }}

),

renamed as (

    select
        -- ids
        employee_id
        , driver_id

        -- strings
        , account_number
        , account_name
        , driver_status
        , trim(upper(driver_last_name)) as last_name
        , trim(upper(driver_first_name)) as first_name
        , trim(upper(concat(driver_first_name, ' ', driver_last_name))) as full_name
        , trim(upper(driver_middle_initial))
        , email_address
        , iff(driver_status = 'ACTIVE','Open','Closed') as card_status_description

        -- booleans
        , coalesce(driver_status = 'ACTIVE', false) as is_card_open

        -- timestamps
        , driver_status_date
        , driver_status_date as account_open_or_closed_date



    from source

)

select * from renamed
