{{ config(
    materialized='incremental',
    unique_key=['quote_key'],
    incremental_strategy='merge',
    merge_exclude_columns = ['_created_recordtimestamp']
) }}

WITH 
    -- isolate fields from staging layer
    quotes as (
        select 
            quote_id
            , COALESCE(quote_customer_id, 'Unknown') as quote_customer_id
            , quote_contact_user_id
            , created_date
            , updated_date
            , branch_id
            , quote_created_by
            , order_created_by
            , order_id
            , requested_start_datetime::date as requested_start_date
            , requested_start_datetime::time as requested_start_time
            , requested_end_datetime::date as requested_end_date
            , requested_end_datetime::time as requested_end_time
            , expiration_datetime::date as expiration_date
            , expiration_datetime::time as expiration_time
            , num_days_quoted

        FROM {{ ref('int_quotes') }}
        WHERE ({{ filter_transformation_updates('_updated_recordtimestamp') }})
    )

    , quote_prices as (
        select 
            quote_pricing_id,
            quote_id,
            delivery_fee,
            pickup_fee,
            rental_subtotal,
            sale_items_subtotal,
            equipment_charges,
            sales_tax,
            total_rpp_price,
            total_price

        from {{ ref('int_quote_prices') }}
        where ({{ filter_transformation_updates('_updated_recordtimestamp') }})
    )

    , combined as (
        SELECT 
            q.quote_id
            , q.quote_customer_id
            , q.quote_contact_user_id
            , q.created_date
            , q.updated_date
            , q.requested_start_date
            , q.requested_start_time
            , q.requested_end_date
            , q.requested_end_time
            , q.expiration_date
            , q.expiration_time
            , q.branch_id
            , q.quote_created_by
            , q.order_created_by
            , q.order_id
            , q.num_days_quoted
            , COALESCE(qp.rental_subtotal, 0.00) AS rental_subtotal
            , COALESCE(qp.sale_items_subtotal, 0.00) AS sale_items_subtotal
            , COALESCE(qp.equipment_charges, 0.00) AS equipment_charges
            , COALESCE(qp.delivery_fee, 0.00) AS delivery_fee
            , COALESCE(qp.pickup_fee, 0.00) AS pickup_fee
            , COALESCE(qp.sales_tax, 0.00) AS sales_tax
            , COALESCE(qp.total_rpp_price, 0.00) AS total_rpp_price
            , COALESCE(qp.total_price, 0.00) AS total_price
        FROM quotes q
        LEFT JOIN quote_prices qp
        ON q.quote_id = qp.quote_id
    )

    , cte_quotes as (
        select quote_key, quote_id
        from {{ ref('dim_quotes') }}
    )

    , cte_quote_customers as (
        select  quote_customer_key, quote_customer_id
        from {{ ref('dim_quote_customers') }}
    )

    , cte_dates as (
        select dt_key, dt_date
        from {{ ref('platform', 'dim_dates') }}
    )

    , cte_orders as (
        select order_key, order_id
        from {{ ref('platform', 'dim_orders') }}
    )

    , cte_markets as (
        select market_key, market_id
        from {{ ref('platform', 'dim_markets') }}
    )

    , cte_users as (
        select user_key, user_id
        from {{ ref('platform', 'dim_users') }}
    )

    , cte_quote_contact_users as (
        select user_key, user_id  
        from {{ ref('platform', 'dim_users') }}
    )

    , cte_times as (
        SELECT  tm_key, tm_time_24
        FROM  {{ ref('platform', 'dim_times') }}
    )

SELECT
    {{ dbt_utils.generate_surrogate_key([
            'qs.quote_source', 
            'q.quote_id'
    ]) }} AS quote_key
    ,COALESCE(creation_date.dt_key, 
        {{ get_default_key_from_dim(model_name='dim_dates') }}
    ) as created_date_key
    ,COALESCE(updated_date.dt_key, 
        {{ get_default_key_from_dim(model_name='dim_dates') }}
    ) as updated_date_key
    , COALESCE(quote_customer.quote_customer_key,
        {{ get_default_key_from_dim(model_name='dim_quote_customers') }}
    ) as quote_customer_key
    ,COALESCE(m.market_key, 
        {{ get_default_key_from_dim(model_name='dim_markets') }}
    ) as market_key
    ,COALESCE(quote_created_by.user_key, 
        {{ get_default_key_from_dim(model_name='dim_users') }}
    ) as quote_created_by_user_key
    ,COALESCE(quote_contact_user.user_key, 
        {{ get_default_key_from_dim(model_name='dim_users') }}
    ) as quote_contact_user_key
    ,COALESCE(order_created_by.user_key,
        {{ get_default_key_from_dim(model_name='dim_users') }}
    ) as converted_to_order_by_user_key
    ,COALESCE(o.order_key, 
        {{ get_default_key_from_dim(model_name='dim_orders') }}
    ) as order_key

    ,COALESCE(start_date.dt_key, 
        {{ get_default_key_from_dim(model_name='dim_dates') }}
    ) as requested_start_date_key
    ,COALESCE(start_time.tm_key, 
        {{ get_default_key_from_dim(model_name='dim_times') }}
    ) as requested_start_time_key
    ,COALESCE(end_date.dt_key, 
        {{ get_default_key_from_dim(model_name='dim_dates') }}
    ) as requested_end_date_key
    ,COALESCE(end_time.tm_key, 
        {{ get_default_key_from_dim(model_name='dim_times') }}
    ) as requested_end_time_key
    ,COALESCE(expiration_date.dt_key, 
        {{ get_default_key_from_dim(model_name='dim_dates') }}
    ) as expiration_date_key
    ,COALESCE(expiration_time.tm_key, 
        {{ get_default_key_from_dim(model_name='dim_times') }}
    ) as expiration_time_key

    ,q.num_days_quoted
    ,q.rental_subtotal
    ,q.sale_items_subtotal
    ,q.equipment_charges
    ,q.delivery_fee
    ,q.pickup_fee
    ,q.sales_tax
    ,q.total_rpp_price
    ,q.total_price
    
    ,{{ get_current_timestamp() }} AS _created_recordtimestamp
    ,{{ get_current_timestamp() }} AS _updated_recordtimestamp

    from combined q
    left join {{ ref('int_quote_sources') }} qs
        on q.quote_id = qs.quote_id

    join cte_quotes qkey
        on q.quote_id = qkey.quote_id
    left join cte_quote_customers quote_customer
         on quote_customer.quote_customer_id = q.quote_customer_id
    join cte_dates creation_date
        on q.created_date::date = creation_date.dt_date
    left join cte_users quote_created_by
        on q.quote_created_by = quote_created_by.user_id
    left join cte_quote_contact_users quote_contact_user
        on q.quote_contact_user_id = quote_contact_user.user_id

    left join cte_dates updated_date
        on q.updated_date::date = updated_date.dt_date
    left join cte_dates start_date 
        on q.requested_start_date = start_date.dt_date
    left join cte_dates end_date 
        on q.requested_end_date = end_date.dt_date
    left join cte_dates expiration_date 
        on q.expiration_date = expiration_date.dt_date
    left join cte_times start_time
        on CAST(q.requested_start_time AS string) = start_time.tm_time_24
    left join cte_times end_time
        on CAST(q.requested_end_time AS string) = end_time.tm_time_24
    left join cte_times expiration_time
        on CAST(q.expiration_time AS string) = expiration_time.tm_time_24

    left join cte_markets m 
        on q.branch_id = m.market_id
    left join cte_users order_created_by
        on q.order_created_by = order_created_by.user_id 
    left join cte_orders o 
        on q.order_id = o.order_id