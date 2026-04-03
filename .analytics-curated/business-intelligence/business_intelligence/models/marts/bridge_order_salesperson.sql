{{ config(
    materialized='incremental'
    , incremental_strategy='delete+insert'
    , unique_key = ['order_key']
    , post_hook = [
        "
        delete from {{ this }} as t
        where exists (
            select 1
            from {{ ref('platform','dim_orders') }} o
            where o.order_key = t.order_key
                and o.order_id = -1
        )
        "
    ]
) }}

-- all salespeople for orders are captured in order_salespersons; salesperson_user_id in orders table is inaccurate
 -- flag any updated orders
WITH updated_orders as (
    select distinct order_id
    from {{ ref('platform', 'order_salespersons')}} 
    {% if is_incremental() -%}
    WHERE (
        {{ filter_incremental_with_buffer_day('_order_salespersons_effective_start_utc_datetime', buffer_days=1) }})
        OR (_order_salespersons_effective_delete_utc_datetime IS NOT NULL
            AND {{ filter_incremental_with_buffer_day('_order_salespersons_effective_delete_utc_datetime', buffer_days=1) }}
    )
    {%- endif -%}
)
    -- ensure we don't bring in any deleted records
    , updated_order_salesperson as (
        select
            order_salesperson_id
            , order_id
            , user_id as salesperson_user_id
            , case when salesperson_type_id = 1 then 'Primary' else 'Secondary' end as salesperson_type
            , _order_salespersons_effective_start_utc_datetime as salesperson_updated_at
        from {{ ref('platform', 'order_salespersons')}} os
        where order_id in (select order_id from updated_orders)
        and _order_salespersons_effective_delete_utc_datetime is null
    )

    , cte_users as (
        select user_key, user_id
        from {{ ref('platform', 'dim_users') }}
    )

    , cte_salesperson as (
        select salesperson_key, user_id, _valid_from, _valid_to
        from {{ ref('dim_salesperson_enhanced') }}
    )

    , cte_orders as (
        select order_key, order_id
        from {{ ref('platform', 'dim_orders') }}
    )

    , cte_full_list as (
        SELECT 
            os.order_id
            , o.order_key
            , os.salesperson_user_id 
            , u.user_key as salesperson_user_key
            , s.salesperson_key
            , os.order_salesperson_id
            , os.salesperson_type
            , os.salesperson_updated_at
            , s._valid_from
            , s._valid_to
        FROM updated_order_salesperson os
        LEFT JOIN cte_orders o
            ON o.order_id = os.order_id
        LEFT JOIN cte_users u
            ON u.user_id = os.salesperson_user_id
        LEFT JOIN cte_salesperson s
            ON s.user_id = os.salesperson_user_id AND os.salesperson_updated_at BETWEEN s._valid_from and s._valid_to
    )

SELECT 
    {{ dbt_utils.generate_surrogate_key(
        ['order_id', 'salesperson_user_id']) 
    }} AS order_salesperson_key
    , COALESCE(order_key
        , {{ get_default_key_from_dim(model_name='dim_orders') }}
    ) AS order_key
    , order_salesperson_id
    , COALESCE(salesperson_user_key
        , {{ get_default_key_from_dim(model_name='dim_users') }}
    ) AS salesperson_user_key
    , COALESCE(salesperson_key 
        , {{ get_default_key_from_dim(model_name='dim_salesperson_enhanced') }}
    ) AS salesperson_key

    , salesperson_type
    , {{ get_current_timestamp() }} AS _updated_recordtimestamp

FROM cte_full_list