with 

source as (

    select * from {{ source('quotes', 'secondary_sales_rep') }}

),

renamed as (

    select
        id as quote_secondary_sales_rep_id,
        quote_id,
        user_id as salesperson_user_id,
        _es_update_timestamp

    from source

)

select * from renamed
