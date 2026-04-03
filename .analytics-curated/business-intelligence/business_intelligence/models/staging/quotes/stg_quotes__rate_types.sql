with 

source as (

    select * from {{ source('quotes', 'rate_type') }}

),

renamed as (

    select
        id as rate_type_id,
        name as rate_type_name,
        _es_update_timestamp

    from source

)

select * from renamed
