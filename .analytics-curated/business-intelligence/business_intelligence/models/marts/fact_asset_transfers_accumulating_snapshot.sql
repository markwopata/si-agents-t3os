{{ config(
    materialized='incremental'
    , unique_key='asset_transfer_order_key'
    , incremental_strategy='merge'
    , merge_exclude_columns = ['_created_recordtimestamp']
) }}

with latest_transfer_requests as (
    select *
    from {{ ref('stg_asset_transfer__transfer_orders') }}
    {% if is_incremental() -%}
    WHERE (
        {{ filter_incremental_with_buffer_day('date_created', buffer_days=1) }}
        OR {{ filter_incremental_with_buffer_day('date_updated', buffer_days=1) }}
    )
    {%- endif -%}

)
    , transfer_requests as (
        select 
            o.asset_transfer_order_id
            , o.asset_transfer_order_number
            , o.asset_id
            , o.company_id
            , o.from_branch_id
            , o.to_branch_id
            , o.transfer_status
            , t.transfer_type_name as transfer_type
            , o.is_rental_transfer
            , o.is_active_transfer

            , o.date_created
            , o.requester_user_id
            , o.requester_note
            , o.date_request_cancelled
            , o.date_rejected
            , o.date_approved
            , o.approver_note
            , o.approver_user_id
            , o.date_transfer_cancelled
            , o.cancellation_note
            , o.date_received
            , o.receiver_user_id
            , o.date_updated
        from latest_transfer_requests o 
        join {{ ref('stg_asset_transfer__transfer_types') }} t
        on o.transfer_type_id = t.transfer_type_id
    )

    , cte_dates as (
        select dt_key, dt_date
        from {{ ref('platform', 'dim_dates') }}
    )

    , cte_times as (
        SELECT  tm_key, tm_time_24
        FROM  {{ ref('platform', 'dim_times') }}
        where tm_hour <> -1
    )
    
    , cte_markets as (
        select market_key, market_id
        from {{ ref('platform', 'dim_markets') }}
    )

    , cte_users as (
        select user_key, user_id
        from {{ ref('platform', 'dim_users') }}
    )

    , cte_assets as (
        select asset_key, asset_id
        from {{ ref('platform', 'dim_assets') }}
    )
    
    , cte_companies as (
        select company_key, company_id
        from {{ ref('platform', 'dim_companies') }}
    )

select 
    {{ dbt_utils.generate_surrogate_key(
        ['asset_transfer_order_id']) 
    }} AS asset_transfer_order_key
    , asset_transfer_order_id
    , asset_transfer_order_number
    , COALESCE(a.asset_key, 
        {{ get_default_key_from_dim(model_name='dim_assets') }}
    ) as asset_transfer_order_asset_key
    , COALESCE(c.company_key, 
        {{ get_default_key_from_dim(model_name='dim_companies') }}
    ) as asset_transfer_order_company_key
    , COALESCE(from_market.market_key, 
        {{ get_default_key_from_dim(model_name='dim_markets') }}
    ) as asset_transfer_order_from_market_key
    , COALESCE(to_market.market_key, 
        {{ get_default_key_from_dim(model_name='dim_markets') }}
    ) as asset_transfer_order_to_market_key

    , transfer_status as asset_transfer_status
    , transfer_type as asset_transfer_type
    , is_rental_transfer as is_rental_transfer
    , is_active_transfer as is_active_transfer

    , COALESCE(created_date.dt_key, 
        {{ get_default_key_from_dim(model_name='dim_dates') }}
    ) as asset_transfer_order_created_date_key
    , COALESCE(created_time.tm_key, 
        {{ get_default_key_from_dim(model_name='dim_times') }}
    ) as asset_transfer_order_created_time_key
    , COALESCE(requester_user.user_key, 
        {{ get_default_key_from_dim(model_name='dim_users') }}
    ) as asset_transfer_order_requester_user_key
    , requester_note

    , COALESCE(request_cancelled_date.dt_key, 
        {{ get_default_key_from_dim(model_name='dim_dates') }}
    ) as asset_transfer_order_request_cancelled_date_key
    , COALESCE(request_cancelled_time.tm_key, 
        {{ get_default_key_from_dim(model_name='dim_times') }}
    ) as asset_transfer_order_request_cancelled_time_key

    , COALESCE(rejected_date.dt_key, 
        {{ get_default_key_from_dim(model_name='dim_dates') }}
    ) as asset_transfer_order_rejected_date_key
    , COALESCE(rejected_time.tm_key, 
        {{ get_default_key_from_dim(model_name='dim_times') }}
    ) as asset_transfer_order_rejected_time_key

    , COALESCE(approved_date.dt_key, 
        {{ get_default_key_from_dim(model_name='dim_dates') }}
    ) as asset_transfer_order_approved_date_key
    , COALESCE(approved_time.tm_key, 
        {{ get_default_key_from_dim(model_name='dim_times') }}
    ) as asset_transfer_order_approved_time_key
    , approver_note
    , COALESCE(approver_user.user_key, 
        {{ get_default_key_from_dim(model_name='dim_users') }}
    ) as asset_transfer_order_approver_user_key

    , COALESCE(transfer_cancelled_date.dt_key, 
        {{ get_default_key_from_dim(model_name='dim_dates') }}
    ) as asset_transfer_order_transfer_cancelled_date_key
    , COALESCE(transfer_cancelled_time.tm_key, 
        {{ get_default_key_from_dim(model_name='dim_times') }}
    ) as asset_transfer_order_transfer_cancelled_time_key
    , cancellation_note

    , COALESCE(received_date.dt_key, 
        {{ get_default_key_from_dim(model_name='dim_dates') }}
    ) as asset_transfer_order_received_date_key
    , COALESCE(received_time.tm_key, 
        {{ get_default_key_from_dim(model_name='dim_times') }}
    ) as asset_transfer_order_received_time_key
    , COALESCE(receiver_user.user_key, 
        {{ get_default_key_from_dim(model_name='dim_users') }}
    ) as asset_transfer_order_receiver_user_key

    , {{ get_current_timestamp() }} AS _created_recordtimestamp
    , {{ get_current_timestamp() }} AS _updated_recordtimestamp

from transfer_requests tr 
LEFT JOIN cte_assets a 
    ON tr.asset_id = a.asset_id
LEFT JOIN cte_companies c 
    ON tr.company_id = c.company_id
LEFT JOIN cte_markets from_market
    ON tr.from_branch_id = from_market.market_id
LEFT JOIN cte_markets to_market
    ON tr.to_branch_id = to_market.market_id

LEFT JOIN cte_users requester_user 
    ON tr.requester_user_id = requester_user.user_id
LEFT JOIN cte_users receiver_user 
    ON tr.receiver_user_id = receiver_user.user_id
LEFT JOIN cte_users approver_user
    ON tr.approver_user_id = approver_user.user_id

LEFT JOIN cte_dates created_date
    ON tr.date_created::date = created_date.dt_date
LEFT JOIN cte_times created_time
    ON CAST(tr.date_created::time AS string) = created_time.tm_time_24

LEFT JOIN cte_dates request_cancelled_date
    ON tr.date_request_cancelled::date = request_cancelled_date.dt_date
LEFT JOIN cte_times request_cancelled_time
    ON CAST(tr.date_request_cancelled::time as string) = request_cancelled_time.tm_time_24

LEFT JOIN cte_dates rejected_date
    ON tr.date_rejected::date = rejected_date.dt_date
LEFT JOIN cte_times rejected_time
    ON CAST(tr.date_rejected::time AS string) = rejected_time.tm_time_24

LEFT JOIN cte_dates approved_date
    ON tr.date_approved::date = approved_date.dt_date
LEFT JOIN cte_times approved_time
    ON CAST(tr.date_approved::time AS string) = approved_time.tm_time_24

LEFT JOIN cte_dates transfer_cancelled_date
    ON tr.date_transfer_cancelled::date = transfer_cancelled_date.dt_date
LEFT JOIN cte_times transfer_cancelled_time
    ON CAST(tr.date_transfer_cancelled::time AS string) = transfer_cancelled_time.tm_time_24

LEFT JOIN cte_dates received_date
    ON tr.date_received::date = received_date.dt_date
LEFT JOIN cte_times received_time
    ON CAST(tr.date_received::time AS string) = received_time.tm_time_24