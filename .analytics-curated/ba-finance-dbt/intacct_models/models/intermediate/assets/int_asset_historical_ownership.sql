with asset_dates as (
    select
        dc.asset_id,
        dc.daily_timestamp
    from
        {{ ref("int_asset_date_cross") }} as dc
    where 1 = 1
        {% if is_incremental() %}
            and dc.daily_timestamp >= dateadd(days, -15, current_date)::timestamp_tz
        {% endif %}
),

out as (
    select
        md5(concat(adc.asset_id, adc.daily_timestamp)) as pk_asset_daily_timestamp_id,
        adc.asset_id,
        ts.status as transfer_status,
        iff(ts.status = 'Approved', TRUE, FALSE) as is_in_transit,
        adc.daily_timestamp,
        sar.rental_branch_id,
        imr.market_name as rental_branch_name,
        sam.service_branch_id,
        ims.market_name as service_branch_name,
        sai.inventory_branch_id,
        imi.market_name as inventory_branch_name,
        -- Commonly understood to be owner of asset.
        -- If there's a rental branch set, they're using it to invoice and gain revenue, 
        --    so this is highly likely to be accurate.
        -- If there is no rental branch (non-rental assets like service trucks), inventory branch tells us who owns it.
        coalesce(sar.rental_branch_id, sai.inventory_branch_id) as market_id,
        coalesce(imr.market_name, imi.market_name) as market_name,
        sac.company_id as asset_company_id,
        c.company_name as owning_company_name,

        sais.asset_inventory_status, -- Not populated before 2019-12-04
        -- should we check historical RR state?
        (
            coalesce(aa.custom_name, '') ilike 'RR%'
            or coalesce(aa.serial_number, '') ilike 'RR%'
            or coalesce(aa.vin, '') ilike 'RR%'
            or coalesce(market_company_id, -1) = 11606 /* re-rent company */
        ) as is_rerent_asset,
        --cpoli_scd.order_status as fleet_track_order_status,
        --cpoli_scd.order_status = 'Received' as is_fleet_track_received,
        case
            when last_day(adc.daily_timestamp) = adc.daily_timestamp::date
                or adc.daily_timestamp::date = current_date
                then date_trunc(month, adc.daily_timestamp)
        end as month_end_date, -- This will be not-null for EOM dates.
        aa.oec as oec,
        m.company_id as market_company_id,
        ec.company_id is not null as is_managed_by_es_owned_market,
        /* todo:
            - in rental fleet
            - es owned
            - finance status
            - financial schedule
            - contractor owned flag
            - op lease
            ---- HISTORICAL UTILIZATION
            - ? aged out of fleet thing?
            - ? equipment assignment to get on rent status? why do we need this over asset inventory status?
            -     equipment assignment goes back to 2015, ais starts in 2019.
            -     ? does an asset assigned to rental => on rent status already (thinking about rental status 1-4, 8)
            - ? daily rate (line_items amount / days rented) - seems like there may be a better way to do this
            ---- HAM TABLE
            - ? equipment assignment - used to find asset on rent->market from order?
        */
        sais.asset_inv_status_seq,
        sais.inventory_status_duration_days,
        datediff('day', sais.date_start::date, adc.daily_timestamp::date) as days_in_status -- counting the number of days an asset has been in a specific status in ascending order.
    from asset_dates as adc
        left join {{ ref("int_assets") }} as aa
            on adc.asset_id = aa.asset_id
        left join {{ ref("stg_es_warehouse_scd__scd_asset_rsp") }} as sar
            on adc.asset_id = sar.asset_id
                and adc.daily_timestamp >= sar.date_start
                and adc.daily_timestamp < sar.date_end
        left join {{ ref("stg_es_warehouse_scd__scd_asset_inventory") }} as sai
            on adc.asset_id = sai.asset_id
                and adc.daily_timestamp >= sai.date_start
                and adc.daily_timestamp < sai.date_end
        left join {{ ref("stg_es_warehouse_scd__scd_asset_msp") }} as sam
            on adc.asset_id = sam.asset_id
                and adc.daily_timestamp >= sam.date_start
                and adc.daily_timestamp < sam.date_end
        left join {{ ref("stg_es_warehouse_scd__scd_asset_company") }} as sac
            on adc.asset_id = sac.asset_id
                and adc.daily_timestamp >= sac.date_start
                and adc.daily_timestamp < sac.date_end
        left join {{ ref("stg_es_warehouse_public__companies") }} as c
            on sac.company_id = c.company_id
        left join {{ ref("stg_es_warehouse_scd__scd_asset_inventory_status") }} as sais
            on adc.asset_id = sais.asset_id
                and adc.daily_timestamp >= sais.date_start
                and adc.daily_timestamp < sais.date_end
        left join {{ ref("stg_es_warehouse_public__markets") }} as m
            on coalesce(sar.rental_branch_id, sai.inventory_branch_id) = m.market_id
        left join {{ ref("int_markets") }} as imr
            on sar.rental_branch_id = imr.market_id
        left join {{ ref("int_markets") }} as imi
            on sai.inventory_branch_id = imi.market_id
        left join {{ ref("int_markets") }} as ims
            on sam.service_branch_id = ims.market_id
        left join {{ ref("stg_analytics_public__es_companies") }} as ec
            on m.company_id = ec.company_id
                and ec.owned
        left join {{ ref('transfer_orders_snapshot') }} as ts
            on adc.asset_id = ts.asset_id
            and adc.daily_timestamp between date_trunc('day', ts.dbt_valid_from) and date_trunc('day', coalesce(ts.dbt_valid_to, '9999-12-31'))
            and ts.status = 'Approved' -- only care about Approved (in_transit) status transfers for now
--left join
---- this is a bad table to use. not working >= September 2024
--     "stg_business_data_vault_es_warehouse_public__vw_company_purchase_order_line_items_scd2") 
--        as cpoli_scd
--    on adc.asset_id = cpoli_scd.asset_id
--        and adc.daily_timestamp
--        >= cpoli_scd.__company_purchase_order_line_items_effective_start_utc_datetime
--        and adc.daily_timestamp
--        < cpoli_scd.__company_purchase_order_line_items_effective_end_utc_datetime

)

select *
from out
