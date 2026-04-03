with source as (

    select * from {{ source('analytics_vehicle_solutions', 'turo_earnings') }}

),

renamed as (

    select
        host_account_id,
        first_name as host_account_name,
        substring(first_name, 7, 5) as turo_account_code,
        adj_created as earning_date,
        balanced_credit_id as stripe_payout_id,
        batch_value as batch_amount,
        vehicle_id,
        make,
        model,
        model_year,
        reservation_id,
        adjustment_value::float as amount,
        reason,
        credit_date,
        date_trunc('day', credit_date) as bank_deposit_date,
        date_trunc('month', credit_date) as bank_deposit_month,
        _es_update_timestamp

    from source

)

select * from renamed
