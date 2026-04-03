  select
    quote_salesperson_key
    , quote_key
    , salesperson_user_key
    , salesperson_key
    , salesperson_type

    , _updated_recordtimestamp

  from {{ ref('bridge_quote_salesperson') }}