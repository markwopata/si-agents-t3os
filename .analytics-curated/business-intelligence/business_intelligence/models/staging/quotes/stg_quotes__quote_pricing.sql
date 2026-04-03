with 

source as (

    select * from {{ source('quotes', 'quote_pricing') }}

),

renamed as (

    select
        id as quote_pricing_id
        ,created_by
        ,created_date
        ,CAST(equipment_charges AS NUMBER(18,2)) AS equipment_charges
        ,quote_id
        ,CAST(rental_subtotal AS NUMBER(18,2)) AS rental_subtotal
        ,CAST(rpp AS NUMBER(18,2)) as rpp_price
        ,CAST(rpp_tax AS NUMBER(18,2)) as rpp_tax
        ,CAST(sales_tax AS NUMBER(18,2)) AS sales_tax
        ,CAST(sale_items_subtotal AS NUMBER(18,2)) AS sale_items_subtotal
        ,CAST(total AS NUMBER(18,2)) as total
        ,_es_update_timestamp

    from source

)

select * from renamed
