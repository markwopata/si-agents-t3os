with source as (

    select * from {{ source('analytics_vsg_postgres__public', 'vehicle_rack_rates') }}

),

renamed as (

    select
        vin,
        date,
        rack_rate / 100 as rack_rate, -- convert from cents to dollars,
        _fivetran_deleted as is_fivetran_deleted,
        _fivetran_synced
    from source

)

select * from renamed
order by vin, date
