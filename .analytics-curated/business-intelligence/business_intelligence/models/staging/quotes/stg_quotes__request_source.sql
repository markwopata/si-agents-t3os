with 

source as (

    select * from {{ source('quotes', 'request_source') }}

),

renamed as (

    select
        request_source_id
        , case 
            when name = 'ESMAX' then 'ESMax'
            else initcap(lower(name))
         end as request_source_name
        , _es_update_timestamp

    from source

)

select * from renamed
