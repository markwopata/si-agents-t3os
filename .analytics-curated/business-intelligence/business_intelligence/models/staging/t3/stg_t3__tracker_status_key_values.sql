{{ config(
    materialized='table'
    , cluster_by=['tracker_id']
) }}

with latest_tracker_install_date as (
    select
        asset_id,
        date_installed,
        tracker_id
    from
        {{ ref('platform', 'es_warehouse__public__asset_tracker_assignments') }}
    where
        date_uninstalled is null QUALIFY ROW_NUMBER() OVER (
            PARTITION BY asset_id
            ORDER BY
                date_installed desc
        ) = 1
),

ble_last_contacts as (
    select
        ble_asset_id,
        max(message_date)
    from
        {{ ref('platform', 'es_warehouse__public__ble_message_logs') }}
    group by
        ble_asset_id
),

askv as (
    select
        asset_id,
        name,
        value,
        case
            when name = 'out_of_lock' then value_timestamp
            else null
        end out_of_lock_timestamp,
        case
            when name = 'rssi' then value_timestamp
            else null
        end rssi_timestamp,
        case
            when name = 'hdop' then value_timestamp
            else null
        end hdop_timestamp
    from
        {{ ref('platform', 'es_warehouse__public__asset_status_key_values') }}
),

askv_pivot as (
    select
        max(ASSET_ID) ASSET_ID,
        max(OUT_OF_LOCK_TIMESTAMP) OUT_OF_LOCK_TIMESTAMP,
        max(RSSI_TIMESTAMP) RSSI_TIMESTAMP,
        max(HDOP_TIMESTAMP) HDOP_TIMESTAMP,
        max(IS_BLE_NODE) IS_BLE_NODE,
        max(OUT_OF_LOCK_REASON) OUT_OF_LOCK_REASON,
        max(UNPLUGGED) UNPLUGGED,
        max(STREET) STREET,
        max(CITY) CITY,
        max(STATE) STATE,
        max(ZIP_CODE) ZIP_CODE,
        max(LOCATION) LOCATION,
        max(LAST_CHECKIN_TIMESTAMP) LAST_CHECKIN_TIMESTAMP,
        max(ASSET_BATTERY_VOLTAGE) ASSET_BATTERY_VOLTAGE,
        max(START_STALE_GPS_FIX_TIMESTAMP) START_STALE_GPS_FIX_TIMESTAMP,
        max(LAST_LOCATION_TIMESTAMP) LAST_LOCATION_TIMESTAMP,
        max(RSSI) RSSI,
        max(HOURS) HOURS,
        max(ODOMETER) ODOMETER,
        max(HDOP) HDOP
    from
        askv pivot (
            max(value) for name in (
                'is_ble_node',
                'out_of_lock',
                'unplugged',
                'street',
                'city',
                'state_id',
                'zip_code',
                'location',
                'last_checkin_timestamp',
                'battery_voltage',
                'start_stale_gps_fix_timestamp',
                'last_location_timestamp',
                'rssi',
                'hours',
                'odometer',
                'hdop'
            )
        ) p (
            ASSET_ID,
            OUT_OF_LOCK_TIMESTAMP,
            RSSI_TIMESTAMP,
            HDOP_TIMESTAMP,
            IS_BLE_NODE,
            OUT_OF_LOCK_REASON,
            UNPLUGGED,
            STREET,
            CITY,
            STATE,
            ZIP_CODE,
            LOCATION,
            LAST_CHECKIN_TIMESTAMP,
            ASSET_BATTERY_VOLTAGE,
            START_STALE_GPS_FIX_TIMESTAMP,
            LAST_LOCATION_TIMESTAMP,
            RSSI,
            HOURS,
            ODOMETER,
            HDOP
        )
    group by
        asset_id
    order by
        asset_id
)

select
    t.tracker_id,
    t.device_serial,
    t.phone_number,
    ttypes.name tracker_type,
    tvendors.name tracker_vendor,
    ltid.asset_id,
    ltid.date_installed tracker_last_date_installed,
    ts.latest_report_timestamp,
    tsc.battery_voltage,
    coalesce(
        tt.firmware_version,
        tt.OBD2_FIRMWARE_VERSION,
        'Unknown'
    ) tracker_firmware_version,
    case
        when c1.field_value = '1'
        and c1.configuration_eid = '431'
        AND c2.field_value = '1'
        and c2.configuration_eid = '4d6' then 'ON'
        when c1.field_value = '0'
        and c1.configuration_eid = '431'
        OR c2.field_value = '0'
        and c2.configuration_eid = '4d6' then 'OFF'
        else 'N/A'
    end as BLE_on_off,
    ll.geofences,
    ll.location as last_location,
    ll.address,
    askvp.is_ble_node,
    askvp.out_of_lock_reason,
    askvp.out_of_lock_timestamp,
    askvp.unplugged,
    askvp.street,
    askvp.city,
    s.ABBREVIATION as state,
    askvp.zip_code,
    askvp.location,
    askvp.last_checkin_timestamp,
    askvp.asset_battery_voltage,
    askvp.start_stale_gps_fix_timestamp,
    askvp.last_location_timestamp,
    tsc.latest_gps_fix_timestamp,
    tsc.latest_satellites,
    askvp.rssi,
    askvp.rssi_timestamp,
    askvp.hours,
    askvp.odometer,
    askvp.hdop,
    askvp.hdop_timestamp
from
    {{ ref('platform', 'es_warehouse__public__trackers') }} t
    left join {{ ref('platform', 'es_warehouse__public__tracker_types') }} ttypes on t.tracker_type_id = ttypes.tracker_type_id
    left join {{ ref('platform', 'es_warehouse__public__tracker_vendors') }} tvendors on t.vendor_id = tvendors.tracker_vendor_id
    left join latest_tracker_install_date ltid on t.tracker_id = ltid.tracker_id
    left join {{ ref('platform', 'es_warehouse__public__tracker_state_cache') }} tsc on t.tracker_id = tsc.tracker_id
    left join {{ ref('platform', 'trackers_trackers') }} tt on t.device_serial = tt.device_serial
    left join {{ ref('platform', 'current_morey_device_field_configurations') }} c1
        on c1.tracker_id = t.tracker_id and (c1.configuration_eid = '431')
    left join {{ ref('platform', 'current_morey_device_field_configurations') }} c2 
        on c2.tracker_id = t.tracker_id and (c2.configuration_eid = '4d6')
    left join {{ ref('platform', 'es_warehouse__public__asset_last_location') }} ll on ltid.asset_id = ll.asset_id
    left join ble_last_contacts ble on ltid.asset_id = ble.ble_asset_id
    left join {{ ref('platform', 'es_warehouse__public__tracker_state_cache') }} ts on ts.tracker_id = tt.tracker_id
    left join askv_pivot askvp on ltid.asset_id = askvp.asset_id
    left join {{ ref('platform', 'es_warehouse__public__states') }} s on try_to_number(askvp.state) = s.STATE_ID