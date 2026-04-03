{{ config(
    materialized='incremental',
    unique_key=['asset_key'],
    incremental_strategy='merge',
    merge_exclude_columns = ['_created_recordtimestamp', 'original_purchase_id', 'original_purchase_price']
) }} 

WITH updated_assets as (
    select * 
    from {{ ref('platform', 'asset_purchase_history') }}

    {% if is_incremental() -%}
    WHERE {{ filter_incremental_with_buffer_minute('_asset_purchase_history_effective_start_utc_datetime', 60) }}
    {%- endif -%}
),

    asset_purchase_min_max_price as (
        SELECT
            asset_id,
            purchase_history_id,
            COALESCE(oec, purchase_price) AS purchase_value,
            ROW_NUMBER() OVER (PARTITION BY asset_id ORDER BY purchase_history_id ASC) AS rn_asc,
            ROW_NUMBER() OVER (PARTITION BY asset_id ORDER BY purchase_history_id DESC) AS rn_desc,
            MAX(COALESCE(oec, purchase_price)) OVER (PARTITION BY asset_id) AS highest_purchase_price,
            MIN(COALESCE(oec, purchase_price)) OVER (PARTITION BY asset_id) AS lowest_purchase_price
        FROM {{ ref('platform', 'asset_purchase_history') }}

        {% if is_incremental() -%}
        WHERE asset_id in (select distinct asset_id from updated_assets)
        {%- endif -%} 
    ),

    asset_purchase_summary as (
        SELECT
            p.asset_id,
            MAX(CASE WHEN p.rn_asc = 1 THEN p.purchase_history_id END) AS original_purchase_id,
            MAX(CASE WHEN p.rn_asc = 1 THEN p.purchase_value END) AS original_purchase_price,
            MAX(CASE WHEN p.rn_desc = 1 THEN p.purchase_history_id END) AS latest_purchase_id,
            MAX(CASE WHEN p.rn_desc = 1 THEN p.purchase_value END) AS latest_purchase_price,
            MAX(p.highest_purchase_price) AS highest_purchase_price,
            MAX(p.lowest_purchase_price) AS lowest_purchase_price
        FROM asset_purchase_min_max_price p
        GROUP BY p.asset_id
    ),

    cte_assets as (
        select asset_key, asset_id
        from {{ ref('platform', 'dim_assets') }}
    )

    select 
        COALESCE(cte_assets.asset_key, 
            {{ get_default_key_from_dim(model_name='dim_assets') }}
        ) as asset_key
        , a.original_purchase_id
        , a.latest_purchase_id
        , CAST(a.original_purchase_price AS NUMBER(14,4)) as original_purchase_price
        , CAST(a.latest_purchase_price AS NUMBER(14,4)) AS latest_purchase_price
        , CAST(a.highest_purchase_price AS NUMBER(14,4)) AS highest_purchase_price
        , CAST(a.lowest_purchase_price AS NUMBER(14,4)) AS lowest_purchase_price

        , {{ get_current_timestamp() }} AS _created_recordtimestamp
        , {{ get_current_timestamp() }} AS _updated_recordtimestamp

    from asset_purchase_summary a
    JOIN cte_assets
    ON a.asset_id = cte_assets.asset_id
