with source as (

    select * from {{ source('analytics_payroll', 'all_company_cost_centers') }}

),

renamed as (

    select
    
        -- ids
        intaact,

        -- strings
        full_name,
        location,
        abbrev,
        name,

        -- timestamps
        _es_update_timestamp


    from source

)

select * from renamed
