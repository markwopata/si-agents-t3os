with source as (

    select * from {{ source('analytics_public', 'es_companies') }}

),

renamed as (

    select
        -- ids
        _row as row_number,
        company_id,

        -- strings
        note,
        company_name,

        -- numerics
        
        -- booleans
        rental_fleet,
        wide_search_allowed,
        abl_eligible,
        balance_sheet,
        owned,

        -- timestamps
        _fivetran_synced

    from source

)

select * from renamed
