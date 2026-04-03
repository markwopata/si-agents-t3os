{{ config(
    materialized='incremental'
    , incremental_strategy='delete+insert'
    , unique_key=['quote_key']
) }}

WITH 
    quotes as (
        select 
            quote_id
            , branch_id
            , order_id
            , COALESCE(quote_customer_id, 'Unknown') as quote_customer_id
            , quote_contact_user_id
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

    , quote_line_items AS (
        SELECT
            ql.quote_id
            , q.branch_id
            , q.order_id
            , q.quote_customer_id
            , q.quote_contact_user_id
            , q.requested_start_date
            , q.requested_start_time
            , q.requested_end_date
            , q.requested_end_time
            , q.expiration_date
            , q.expiration_time
            , q.num_days_quoted
            , ql.created_date
            , ql.quote_line_item_id
            , ql.equipment_class_id
            , ql.part_id
            , ql.line_item_description
            , ql.selected_rate_type_id
            , COALESCE(ql.selected_rate_type_name, 'Not Applicable') AS selected_rate_type_name
            , COALESCE(ql.line_item_type_id, -1) as line_item_type_id
            , COALESCE(ql.line_item_type_name, 'Unknown') AS line_item_type_name
            , COALESCE(ql.note, 'Not Applicable') AS note
            , COALESCE(ql.quantity, -1) AS quantity
            , COALESCE(ql.shift_id, 'Not Applicable') AS shift_id
            , COALESCE(ql.multiplier, -1) AS multiplier
            , COALESCE(ql.shift_name, 'Not Applicable') AS shift_name
            , COALESCE(ql.day_rate, 0.00) AS day_rate
            , COALESCE(ql.week_rate, 0.00) AS week_rate
            , COALESCE(ql.four_week_rate, 0.00) AS four_week_rate
            , COALESCE(ql.flat_rate, 0.00) AS flat_rate

        FROM {{ ref('int_quote_line_items')}} ql
        left join quotes q 
        on q.quote_id = ql.quote_id
        where ({{ filter_transformation_updates('_updated_recordtimestamp') }})

    )

    , cte_quotes as (
        select quote_key, quote_id
        from {{ ref('dim_quotes') }}
    )

    , cte_dates as (
        select dt_key, dt_date
        from {{ ref('platform', 'dim_dates') }}
    )

    , cte_times as (
        SELECT  tm_key, tm_time_24
        FROM {{ ref('platform', 'dim_times') }}
        where tm_hour <> -1
    )

    , cte_orders as (
        select order_key, order_id
        from {{ ref('platform', 'dim_orders') }}
    )

    , cte_markets as (
        select market_key, market_id
        from {{ ref('platform', 'dim_markets') }}
    )

    , cte_parts as (
        select part_key, part_id
        from {{ ref('platform', 'dim_parts') }}
    )

    , cte_equipment_classes as (
        select equipment_class_key, equipment_class_id
        from {{ ref('dim_equipment_classes') }}
    )

    , cte_quote_customers as (
        select  quote_customer_key, quote_customer_id
        from {{ ref('dim_quote_customers') }}
    )

    , cte_quote_contact_users as (
        select user_key, user_id  
        from {{ ref('platform', 'dim_users') }}
    )

    SELECT 
        {{ dbt_utils.generate_surrogate_key([
            'qs.quote_source','q.quote_id', 'q.quote_line_item_id']) 
        }} AS quote_line_item_key
        ,COALESCE(qkey.quote_key, 
            ({{ get_default_key_from_dim(model_name='dim_quotes') }})
        ) as quote_key
        ,COALESCE(creation_date.dt_key, 
            ({{ get_default_key_from_dim(model_name='dim_dates') }})
        ) as created_date_key
        , COALESCE(quote_customer.quote_customer_key,
            {{ get_default_key_from_dim(model_name='dim_quote_customers') }}
        ) as quote_customer_key
        ,COALESCE(quote_contact_user.user_key, 
            {{ get_default_key_from_dim(model_name='dim_users') }}
        ) as quote_contact_user_key
        ,COALESCE(m.market_key, 
            ({{ get_default_key_from_dim(model_name='dim_markets') }})
        ) as market_key
        ,COALESCE(o.order_key, 
            ({{ get_default_key_from_dim(model_name='dim_orders') }})
        ) as order_key
        ,COALESCE(p.part_key, 
            ({{ get_default_key_from_dim(model_name='dim_parts') }})
        ) as part_key
        ,COALESCE(ec.equipment_class_key, 
            ({{ get_default_key_from_dim(model_name='dim_equipment_classes') }})
        ) as equipment_class_key

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

        ,quote_line_item_id
        ,line_item_description
        ,selected_rate_type_name
        ,line_item_type_name
        ,note
        ,quantity
        ,shift_id
        ,multiplier
        ,shift_name
        ,day_rate
        ,week_rate
        ,four_week_rate
        ,flat_rate
        , num_days_quoted
        
        ,{{ get_current_timestamp() }} AS _updated_recordtimestamp

    from quote_line_items q
    left join {{ ref('int_quote_sources') }} qs
        on q.quote_id = qs.quote_id    

    join cte_quotes qkey
        on q.quote_id = qkey.quote_id
    join cte_dates creation_date
        on q.created_date::date = creation_date.dt_date
    left join cte_quote_customers quote_customer
         on quote_customer.quote_customer_id = q.quote_customer_id
    left join cte_quote_contact_users quote_contact_user
        on q.quote_contact_user_id = quote_contact_user.user_id

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
    left join cte_orders o 
        on q.order_id = o.order_id
    left join cte_parts p 
        on q.part_id = p.part_id
    left join cte_equipment_classes ec 
        on q.equipment_class_id = ec.equipment_class_id