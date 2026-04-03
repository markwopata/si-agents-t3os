  select
    order_salesperson_key
    , order_key
    , order_salesperson_id
    , salesperson_user_key
    , salesperson_key
    , salesperson_type

    , _updated_recordtimestamp

  from {{ ref('bridge_order_salesperson') }}