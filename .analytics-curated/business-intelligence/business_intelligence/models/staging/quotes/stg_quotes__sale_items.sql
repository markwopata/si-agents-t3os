with 

source as (

    select * from {{ source('quotes', 'sale_item') }}

),

renamed as (

    select
        id as sale_line_item_id,
        line_item_type_id,
        CAST(price AS NUMBER(18,2)) as price,
        quantity,
        quote_id,
        sale_item as sale_item_description,
        part_id,
        _es_update_timestamp

    from source

)

select * from renamed
