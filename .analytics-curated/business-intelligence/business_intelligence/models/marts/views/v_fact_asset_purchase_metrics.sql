SELECT 
    asset_key
    , original_purchase_id
    , latest_purchase_id
    , original_purchase_price
    , latest_purchase_price
    , highest_purchase_price
    , lowest_purchase_price
    , _created_recordtimestamp
    , _updated_recordtimestamp

FROM {{ ref('fact_asset_purchase_metrics') }}
