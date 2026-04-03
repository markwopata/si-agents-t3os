with source as (
  select *
  from {{ source('quotes_quotes', 'request_source') }}
),

renamed as (
  select
    _es_update_timestamp,
    _es_load_timestamp,

    request_source_id,
    name
  from source
)

select * from renamed