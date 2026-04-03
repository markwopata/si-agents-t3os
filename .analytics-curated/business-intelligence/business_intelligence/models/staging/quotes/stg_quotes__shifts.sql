with 

source as (

    select * from {{ source('quotes', 'shift') }}

),

renamed as (

    select
        id as shift_id,
        multiplier as multiplier,
        name as shift_name,
        _es_update_timestamp

    from source

)

select * from renamed
