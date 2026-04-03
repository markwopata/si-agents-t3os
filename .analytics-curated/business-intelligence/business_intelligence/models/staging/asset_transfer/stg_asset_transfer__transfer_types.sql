with 

source as (

    select * from {{ source('asset_transfer', 'transfer_types') }}

),

renamed as (

    select
        _es_update_timestamp,
        id as transfer_type_id,
        name as transfer_type_name

    from source

)

select * from renamed
