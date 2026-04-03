with source as (

    select * from {{ source('analytics_corporate_budget', 'unverified_cc_reallocations') }}

),

renamed as (

    select
        -- ids
        transaction_id,
        _row,

        -- numerics
        debit,
        employee_id,

        -- timestamp
        _fivetran_synced,

    from source

)

select * from renamed
