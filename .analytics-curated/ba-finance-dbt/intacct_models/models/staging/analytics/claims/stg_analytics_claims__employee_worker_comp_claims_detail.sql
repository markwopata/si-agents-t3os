with source as (

    select * from {{ source('analytics_claims', 'employee_worker_comp_claims_detail') }}

),

renamed as (

    select

        -- ids
        upper(claim_number) as claim_number,
        market_id,
        employee_ as employee_id,

        -- strings
        upper(employee_name_) as employee_name,

        -- dates
        date_of_injury,

        -- timestamps
        _fivetran_synced as fivetran_synced_date

    from source

)

select * from renamed
where date_of_injury is not null --exclude break lines in Excel Sheet
