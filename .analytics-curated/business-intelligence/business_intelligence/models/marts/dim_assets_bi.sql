{{ config(
    materialized='incremental',
    unique_key=['asset_key'],
    incremental_strategy='merge',
    merge_exclude_columns = ['_created_recordtimestamp']
) }} 

with asset_ownership_details as (
    SELECT *
        , case
            when a.ASSET_COMPANY_ID in (1854, 1855, 62875) then 'ES'
            when a.ASSET_COMPANY_ID = 11606 OR (a.ASSET_COMPANY_ID = 1854 AND (SUBSTR(TRIM(a.ASSET_SERIAL_NUMBER), 1, 2) = 'RR')) then 'RR'
            when a.ASSET_ACTIVE = FALSE OR a.ASSET_COMPANY_ID in (155) then 'DELETED'
            when a.ASSET_COMPANY_ID in
                    (10859, 16184, 420, 155, 23515, 11606, 77198, 5383, 4110, 88180, 37906, 36810, 42268, 84297, 58589)
                then 'DEMO'
            when ((SUBSTR(c.company_name, 1, 3) = 'IES' AND CONTAINS(c.company_name, '-'))
                OR m.MARKET_NAME ILIKE '%VLP%') 
                AND a.ASSET_COMPANY_ID NOT IN (31003, 66681, 82785) 
                then 'RETAIL'
            when a.ASSET_COMPANY_ID in (31712, 32365) then 'STOLEN'
            when a.ASSET_COMPANY_ID = 6302 then 'EQUIPT'
            when c.company_name ilike 'ES Owned%' then 'ES-DNR'
            when a.ASSET_PAYOUT_PROGRAM not in ('N/A', 'Default Asset Record')
                OR a.ASSET_COMPANY_ID in (111143, 102983, 55524, 142180) -- OWN only companies
                then 'OWN'
            else 'CUSTOMER'
            end as asset_ownership

    FROM {{ ref('platform', 'dim_assets') }} a 
    JOIN {{ ref('platform', 'dim_markets') }} m 
    ON a.asset_market_key = m.market_key
    JOIN {{ ref('platform', 'dim_companies') }} c
    ON a.asset_company_key = c.company_key

    {% if is_incremental() -%}
    WHERE {{ filter_incremental_with_buffer_day('asset_date_updated', 1) }}
    {%- endif -%}
)

select ASSET_KEY
    , ASSET_SOURCE
    , ASSET_ID
    , ASSET_ACTIVE
    , ASSET_YEAR
    , ASSET_DESCRIPTION
    , ASSET_VIN
    , ASSET_SERIAL_NUMBER
    , ASSET_INVENTORY_MARKET_ID
    , ASSET_INVENTORY_MARKET_KEY
    , ASSET_RENTAL_MARKET_ID
    , ASSET_RENTAL_MARKET_KEY
    , ASSET_SERVICE_MARKET_ID
    , ASSET_SERVICE_MARKET_KEY
    , ASSET_MARKET_ID
    , ASSET_MARKET_KEY
    , ASSET_COMPANY_ID
    , ASSET_COMPANY_KEY
    , ASSET_TRACKER_ID
    , ASSET_EQUIPMENT_MAKE
    , ASSET_EQUIPMENT_TYPE
    , ASSET_EQUIPMENT_MODEL_NAME
    , ASSET_EQUIPMENT_CLASS_NAME
    , ASSET_EQUIPMENT_SUBCATEGORY_NAME
    , ASSET_EQUIPMENT_CATEGORY_NAME
    , ASSET_EQUIPMENT_CONTRACTOR_OWNED
    , ASSET_PAYOUT_PROGRAM
    , ASSET_PAYOUT_PROGRAM_TYPE
    , ASSET_PAYOUT_PROGRAM_BILLING_TYPE
    , ASSET_PAYOUT_PROGRAM_PERCENTAGE
    , ASSET_OEM_DELIVERY_DATE
    , ASSET_PURCHASE_DATE
    , ASSET_DATE_CREATED
    , ASSET_DATE_UPDATED
    , ASSET_CURRENT_OEC
    , ASSET_RENTABLE
    , ASSET_FIRST_RENTAL_START_DATE
    , ASSET_MOST_RECENT_ON_RENT_DATE
    , ASSET_INVENTORY_STATUS
    , ASSET_INVENTORY_STATUS_DATE
    , ASSET_HOURS
    , ASSET_ODOMETER
    , ASSET_UNDERPERFORMING_FLAG
    , ASSET_NEVER_RENTED
    , ASSET_NET_BOOK_VALUE
    , ASSET_IFTA_REPORTING
    , ASSET_ALERT_ENTER_GEOFENCE
    , ASSET_ALERT_EXIT_GEOFENCE
    , ASSET_LAST_LOCATION
    , asset_ownership
    
    , {{ get_current_timestamp() }} AS _created_recordtimestamp
    , {{ get_current_timestamp() }} AS _updated_recordtimestamp 
from asset_ownership_details