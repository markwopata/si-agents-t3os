{{ config(
    materialized='table'
    , cluster_by=['company_id', 'asset_id']
) }}

with
    asset_list as ( 
        select
            a.asset_id,
       a.custom_name                         as custom_name,
       coalesce(a.serial_number, a.vin)      as serial_vin,
       a.make,
       a.model,
       a.year,
       a.asset_class,
       a.asset_type_id,
       a.company_id,
       a.rental_branch_id,
       a.inventory_branch_id,
       m.name                                as inventory_branch,
       a.tracker_id,
       a.battery_voltage_type_id,
       a.category_id,
       atyp.name                             as asset_type,
       concat(
               upper(substring(atyp.name, 1, 1)),
               substring(atyp.name, 2, length(atyp.name))
           )                                 as asset_type_thr,
       COALESCE(PARENTCAT.NAME, SUBCAT.NAME) AS category,
       c.name                                as company_name,
       m.market_id,
       m.name                                as market_name,
       xw.district,
       xw.region_name                        as region,
       sais.asset_inventory_status,
       ao.ownership,
       tr.telematics_region_name             as telematics_region
from es_warehouse.public.assets a
         left join
     es_warehouse.public.asset_types atyp
     on a.asset_type_id = atyp.asset_type_id
         left join
     ES_WAREHOUSE.PUBLIC.EQUIPMENT_MODELS EM
     ON A.EQUIPMENT_MODEL_ID = EM.EQUIPMENT_MODEL_ID
         LEFT JOIN
     ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES_MODELS_XREF ECMX
     ON EM.EQUIPMENT_MODEL_ID = ECMX.EQUIPMENT_MODEL_ID
         LEFT JOIN
     ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES EC
     ON ECMX.EQUIPMENT_CLASS_ID = EC.EQUIPMENT_CLASS_ID
         LEFT JOIN
     ES_WAREHOUSE.PUBLIC.CATEGORIES SUBCAT
     ON EC.CATEGORY_ID = SUBCAT.CATEGORY_ID
         LEFT JOIN
     ES_WAREHOUSE.PUBLIC.CATEGORIES PARENTCAT
     ON SUBCAT.PARENT_CATEGORY_ID = PARENTCAT.CATEGORY_ID
         left join
     es_warehouse.public.categories cat
     on a.category_id = cat.category_id
         left join
     es_warehouse.public.companies c
     on a.company_id = c.company_id
         left join
     es_warehouse.public.markets m
     on coalesce(a.rental_branch_id, a.inventory_branch_id) = m.market_id
         left join
     ANALYTICS.PUBLIC.market_region_xwalk xw
     on coalesce(a.rental_branch_id, a.inventory_branch_id) = xw.market_id
         left join
     ANALYTICS.BI_OPS.asset_ownership ao
     on a.asset_id = ao.asset_id
         left join
     ES_WAREHOUSE.SCD.scd_asset_inventory_status sais
     on a.asset_id = sais.asset_id
         and sais.current_flag = 1
         left join
     ANALYTICS.LOOKER_INPUTS.telematics_regions tr
     on coalesce(a.rental_branch_id, a.inventory_branch_id) = tr.market_id
where a.deleted = false
and a.asset_id not in ( 920, 705)
    ),
    tracker_info as (
        SELECT AL.ASSET_ID,
                        T.DEVICE_SERIAL                                  AS TRACKER_SERIAL,
                        COALESCE(T.TRACKER_TYPE_ID, TPT.TRACKER_TYPE_ID) AS TRACKER_TYPE_ID,
                        TV.NAME                                          AS TRACKER_VENDOR,
                        TT.NAME                                          AS TRACKER_MODEL, --USED TO BE TRACKER_TYPE
                        TM.TRACKER_TRACKER_ID,
                        --TRACKER_TYPE IS LATER USED TO DETERMINE TRACKER HEALTH DETAIL PARAMETERS
                        CASE
                            WHEN T.DEVICE_SERIAL IS NULL THEN 'NO TRACKER INSTALLED'
                            WHEN TT.IS_BLE_NODE = TRUE THEN 'BLUETOOTH'
                            WHEN COALESCE(T.TRACKER_TYPE_ID, TPT.TRACKER_TYPE_ID) IN (2, 8, 25, 26, 34, 38, 101)
                                THEN 'BATTERY CELLULAR'
                            ELSE 'WIRED CELLULAR'
                            END                                          AS TRACKER_TYPE,
                        --TRACKER_GROUPING IS USED IN OTHER T3 REPORTS LIKE UTILIZATION
                        CASE
                            WHEN T.DEVICE_SERIAL IS NULL THEN 'No Tracker Installed'
                            WHEN COALESCE(T.TRACKER_TYPE_ID, TPT.TRACKER_TYPE_ID) IN (8, 34, 2, 25, 26, 38, 101)
                                THEN 'Location Only'
                            WHEN COALESCE(T.TRACKER_TYPE_ID, TPT.TRACKER_TYPE_ID) IN
                                 (1, 4, 19, 20, 23, 27, 30, 37, 39, 41, 134, 40)
                                THEN 'Data and Location Only'
                            WHEN COALESCE(T.TRACKER_TYPE_ID, TPT.TRACKER_TYPE_ID) IN (36, 22, 24, 68, 35, 21)
                                THEN 'BLE'
                            WHEN COALESCE(T.TRACKER_TYPE_ID, TPT.TRACKER_TYPE_ID) IN
                                 (28, 31, 29, 3, 5, 6, 7, 11, 12, 13, 14, 15)
                                THEN 'ARCHIVED'
                            ELSE 'AEMP'
                            END
                                                                         AS TRACKER_GROUPING
        from asset_list al
        left join
            {{ ref("platform", "es_warehouse__public__trackers") }} t
            on al.tracker_id = t.tracker_id
        left join
            {{ ref("platform", "es_warehouse__public__tracker_vendors") }} tv
            on t.vendor_id = tv.tracker_vendor_id
        left join
            {{ ref("platform", "es_warehouse__public__trackers_mapping") }} tm
            on al.asset_id = tm.asset_id
        left join
            trackers.public.trackers TPT
            on tm.TRACKER_TRACKER_ID = TPT.Tracker_ID
        left join
            {{ ref("platform", "es_warehouse__public__tracker_types") }} tt
            on coalesce(t.tracker_type_id, tpt.tracker_type_id) = tt.tracker_type_id

    ),
    SECONDARY_TRACKER_INFO AS (SELECT AL.ASSET_ID,
                                  NULLIF(REGEXP_REPLACE(AL.CUSTOM_NAME, '[^0-9]', ''), '') AS CUSTOM_NAME,
                                  AL.TRACKER_ID                 AS SECONDARY_TRACKER_ID,
                                  T.DEVICE_SERIAL               AS SECONDARY_TRACKER_SERIAL, --these need rebuilt to pull from AL
                                  TT.NAME                       AS SECONDARY_TRACKER_TYPE,
                                  TV.NAME                       AS SECONDARY_TRACKER_VENDOR,
                                  THR.LAST_CHECKIN_TIMESTAMP    AS SECONDARY_TRACKER_LAST_CHECKIN
                           FROM ASSET_LIST AL
                                    LEFT JOIN BUSINESS_INTELLIGENCE.triage.stg_t3__tracker_status_key_values THR
                                              ON THR.ASSET_ID = AL.ASSET_ID
                                    LEFT JOIN ES_WAREHOUSE.PUBLIC.TRACKERS T
                                              ON AL.TRACKER_ID = T.TRACKER_ID
                                    LEFT JOIN ES_WAREHOUSE.PUBLIC.TRACKER_TYPES TT
                                              ON T.TRACKER_TYPE_ID = TT.TRACKER_TYPE_ID
                                    LEFT JOIN ES_WAREHOUSE.PUBLIC.TRACKER_VENDORS TV
                                              ON T.VENDOR_ID = TV.TRACKER_VENDOR_ID
                           WHERE AL.COMPANY_ID = 172946 --Uptime Center
                             AND AL.TRACKER_ID IS NOT NULL)
        , camera_info as (
        select
            al.asset_id,
            cam.camera_id,
            cam.date_installed,
            c.device_serial as camera_serial,
            cv.name as camera_vendor
        from asset_list al
        left join
            {{ ref("platform", "es_warehouse__public__asset_camera_assignments") }} cam
            on al.asset_id = cam.asset_id
            and cam.date_uninstalled is null
        left join
            {{ ref("platform", "es_warehouse__public__cameras") }} c
            on cam.camera_id = c.camera_id
        left join
            {{ ref("platform", "es_warehouse__public__camera_vendors") }} cv
            on c.camera_vendor_id = cv.camera_vendor_id
        qualify row_number() over (
                partition by al.asset_id
                order by cam.date_installed desc
        ) = 1
    ),
    GHOST_TRACKER_INFO AS (
        SELECT AL.ASSET_ID,
        NULLIF(REGEXP_REPLACE(AL.CUSTOM_NAME, '[^0-9]', ''), '') AS CUSTOM_NAME,
        AL.TRACKER_ID                 AS GHOST_TRACKER_ID,
        T.DEVICE_SERIAL               AS GHOST_TRACKER_SERIAL, --these need rebuilt to pull from AL
        TT.NAME                       AS GHOST_TRACKER_TYPE,
        TV.NAME                       AS GHOST_TRACKER_VENDOR,
        THR.LAST_CHECKIN_TIMESTAMP    AS GHOST_TRACKER_LAST_CHECKIN
        FROM ASSET_LIST AL
        LEFT JOIN BUSINESS_INTELLIGENCE.triage.stg_t3__tracker_status_key_values THR
                    ON THR.ASSET_ID = AL.ASSET_ID
        LEFT JOIN ES_WAREHOUSE.PUBLIC.TRACKERS T
                    ON AL.TRACKER_ID = T.TRACKER_ID
        LEFT JOIN ES_WAREHOUSE.PUBLIC.TRACKER_TYPES TT
                    ON T.TRACKER_TYPE_ID = TT.TRACKER_TYPE_ID
        LEFT JOIN ES_WAREHOUSE.PUBLIC.TRACKER_VENDORS TV
                    ON T.VENDOR_ID = TV.TRACKER_VENDOR_ID
        WHERE AL.COMPANY_ID = 42268 --PROJECTS - TELEMATICS TEAM ACCOUNT
        AND AL.TRACKER_ID IS NOT NULL
        ),
    keypad_info as (
        select al.asset_id, kpad.keypad_id, k.serial_number as keypad_serial
        from asset_list al
        left join (
            -- ensure an asset has at most one keypad 
            select asset_id, keypad_id, end_date
            from {{ ref("platform", "es_warehouse__public__keypad_asset_assignments") }} 
            where END_DATE is null
            qualify rank() over (partition by asset_id order by date_created desc) = 1
        ) kpad
            on al.asset_id = kpad.asset_id
            and kpad.end_date is null
        left join
            {{ ref("platform", "es_warehouse__public__keypads") }} k
            on kpad.keypad_id = k.keypad_id
    ),
    peripheral_device_info as (
        select *
        from {{ ref("platform", "trackers__public__peripheral_devices") }} pd
        qualify
            row_number() over (
                partition by pd.tracker_id, pd.hardware_name
                order by pd.date_created desc
            )
            = 1
    ),
    devices_required as (
        select
            al.asset_id,
            ifnull(upper(ttr.tracker_req_type), 'UNDEFINED') as tracker_req_type,
            ifnull(upper(ttr.secondary_tracker), 'UNDEFINED') as secondary_tracker_req,
            ifnull(upper(ttr.keypad_req), 'UNDEFINED') as keypad_req,
            ifnull(upper(ttr.keypad_req_type), 'UNDEFINED') as keypad_req_type,
            ifnull(upper(ttr.camera_req), 'UNDEFINED') as camera_req,
            ifnull(upper(ttr.ghost_tracker), 'UNDEFINED') as ghost_tracker_req,
            ttr.has_can
        from asset_list al
        left join (
            select *
            from {{ ref("platform", "analytics__looker_inputs__tracker_type_required") }}
            QUALIFY ROW_NUMBER() OVER (PARTITION BY trim(upper(MAKE)), trim(upper(MODEL)) ORDER BY _ROW DESC) = 1) 
        ttr ON (trim(upper(al.make)) = trim(upper(ttr.make)) and trim(upper(al.model)) = trim(upper(ttr.model)))
    ),
    device_install_status as (
        select
            al.asset_id,
            case
                when dr.tracker_req_type = 'UNDEFINED'
                then 'UNDEFINED'
                when dr.tracker_req_type = 'UN-TRACKABLE'
                then 'UN-TRACKABLE'
                when al.tracker_id is null
                then 'NO TRACKER'
                -- PER BRYAN WALSH MAY 2023 WANTS THESE SPECIFIC MODEL(S) TO SAY
                -- CORRECT TRACKER IF IT HAS ANY KIND OF TRACKER - PB
                when
                    al.tracker_id is not null
                    and (
                        upper(al.model) like upper('E-AIRH250%')
                        or upper(al.make) like upper('SMARTECH')
                        or (
                            upper(al.make) like upper('CAPS')
                            and upper(al.model) like upper('PCHH%')
                        )
                        or (
                            upper(al.make) like upper('PIONEER')
                            and upper(al.model) like upper('EPP66%')
                        )
                    )
                then 'CORRECT TRACKER'
                when
                    upper(dr.tracker_req_type) = 'MC4/5 ONLY'
                    and ti.tracker_type_id in (23, 39, 40, 41)
                then 'CORRECT TRACKER'
                when
                    upper(dr.tracker_req_type) = 'MC4/5 OR FJ'
                    and ti.tracker_type_id in (23, 30, 31, 39, 40, 41)
                then 'CORRECT TRACKER'
                when
                    upper(dr.tracker_req_type) = 'MC4/5 OR FJ'
                    and ti.tracker_type_id in (4)
                    and (
                        upper(dr.has_can) = 'NO'
                        or upper(al.make) like upper('%SMARTECH%')
                    )
                then 'CORRECT TRACKER'
                when
                    upper(dr.tracker_req_type) = 'MCX/LMU'
                    and ti.tracker_type_id in (1, 37, 134)
                then 'CORRECT TRACKER'
                when
                    upper(dr.tracker_req_type) = 'SLAP N TRACK'
                    and ti.tracker_type_id in (25, 26, 34, 38)
                then 'CORRECT TRACKER'
                when
                    upper(dr.tracker_req_type) = 'BLE ATTACHMENT'
                    and ti.tracker_type_id in (24)
                then 'CORRECT TRACKER'
                when
                    upper(dr.tracker_req_type) = 'BLE TOOL'
                    and ti.tracker_type_id in (21, 22, 35, 36, 68)
                then 'CORRECT TRACKER'
                when dr.tracker_req_type = 'NO TRACKER NEEDED'
                then 'NO TRACKER NEEDED'
                else 'INCORRECT TRACKER'
            end as tracker_install_status,
            case
                when ki.keypad_id is not null
                then 'KEYPAD'
                when dr.keypad_req = 'KEYPAD REQUIRED' and ki.keypad_id is null
                then 'MISSING KEYPAD'
                else 'NO KEYPAD REQUIRED'
            end as keypad_install_status,
            case
                when ci.camera_id is not null
                then 'CAMERA'
                when dr.camera_req = 'CAMERA REQUIRED' and ci.camera_id is null
                then 'MISSING CAMERA'
                else 'NO CAMERA REQUIRED'
            end as camera_install_status,
            case
                when sti.secondary_tracker_id is not null
                then 'SECONDARY TRACKER'
                else 'NO SECONDARY TRACKER'
            end as secondary_tracker_install_status,
            case
            when gti.ghost_tracker_id is not null
                then 'GHOST TRACKER'
                else 'NO GHOST TRACKER'
            end as ghost_tracker_install_status
        from asset_list al
        left join tracker_info ti on al.asset_id = ti.asset_id
        left join camera_info ci on al.asset_id = ci.asset_id
        left join keypad_info ki on al.asset_id = ki.asset_id
        left join secondary_tracker_info sti on TO_VARCHAR(al.asset_id) = sti.custom_name
        left join ghost_tracker_info gti on TO_VARCHAR(al.asset_id) = gti.custom_name
        left join devices_required dr on al.asset_id = dr.asset_id
    ),
    camera_heartbeat as (
        with
            heartbeat as (
                select distinct vs.vehicleid, vs.dvrheartbeat
                from {{ source("inbound__ftsgps", "vehicle_status") }} vs
                qualify
                    rank() over (
                        partition by vs.vehicleid order by vs.dvrheartbeat desc
                    )
                    = 1
            )
        select ci.asset_id, afx.device_serial, h.dvrheartbeat
        from camera_info ci
        left join
            {{ ref("platform", "analytics__fleetcam__asset_fleetcam_xwalk") }} afx
            on ci.camera_serial = afx.device_serial
        inner join heartbeat h on afx.fleetcam_vehicle_id = h.vehicleid
    ),
    last_keypad_message as (
        select
            al.asset_id,
            askv.value as last_keypad_entry_date,
            datediff(
                days, askv.value, current_date()
            ) as days_since_most_recent_keypad_entry
        from asset_list al
        left join
            {{ ref("platform", "es_warehouse__public__asset_status_key_values") }} askv
            on al.asset_id = askv.asset_id
        where name = 'last_keypad_message_timestamp'
    ),
    last_delivery_location_clean as (
        select *
        from {{ ref("platform", "es_warehouse__public__last_delivery_location") }}
        where drop_off_or_return is not null
    ),
    last_trip as (
        select
            al.asset_id,
            t.start_timestamp as last_trip_date,
            datediff(
                days, t.start_timestamp, current_date()
            ) as days_since_most_recent_trip,
            abs(
                datediff(day, lkm.last_keypad_entry_date, last_trip_date)
            ) as days_btwn_keypad_entry_and_trip,
            case
                -- WHEN KPAD.KEYPAD_ID IS NULL THEN 'NO KEYPAD'
                when days_btwn_keypad_entry_and_trip is null
                then 'MISSING DATA'
                when days_btwn_keypad_entry_and_trip <= 5
                then 'HEALTHY'
                when
                    days_btwn_keypad_entry_and_trip > 5
                    and lkm.last_keypad_entry_date > last_trip_date
                then 'HEALTHY'
                when
                    days_btwn_keypad_entry_and_trip > 5
                    and last_trip_date > lkm.last_keypad_entry_date
                then 'TRIP WITHOUT KEYPAD'
            end as keypad_vs_trip_health
        from asset_list al
        left join
            {{ ref("platform", "es_warehouse__public__asset_status_key_values") }} askv
            on al.asset_id = askv.asset_id
        left join
            {{ ref("platform", "es_warehouse__public__trips") }} t
            on askv.value = t.trip_id
        left join last_keypad_message lkm on al.asset_id = lkm.asset_id
        where askv.name = 'last_trip_id'
    ),
    last_delivery_location as (
        select
            al.asset_id,
            ldl.drop_off_or_return as last_delivery_drop_off_or_return,
            ldl.last_delivery as last_delivery_date,
            ldl.address as last_delivery_address,
            d.contact_name as last_delivery_contact_name,
            d.contact_phone_number as last_delivery_contact_phone,
            l.latitude as last_delivery_lat,
            l.longitude as last_delivery_long
        from asset_list al
        left join last_delivery_location_clean ldl on al.asset_id = ldl.asset_id
        left join
            {{ ref("platform", "es_warehouse__public__deliveries") }} d
            on ldl.delivery_id = d.delivery_id
        left join
            {{ ref("platform", "es_warehouse__public__locations") }} l
            on d.location_id = l.location_id
    ),
    last_keypad_code_assignment as (
        select
            ki.asset_id,
            kca.date_created as last_keycode_assignment_date,
            kcas.name as last_keycode_assignment_status
        from keypad_info ki
        left join
            {{ ref("platform", "es_warehouse__public__keypad_code_assignments") }} kca
            on ki.keypad_id = kca.keypad_id
        left join
            {{
                ref(
                    "platform",
                    "es_warehouse__public__keypad_code_assignment_statuses",
                )
            }} kcas
            on kca.keypad_code_assignment_status_id
            = kcas.keypad_code_assignment_status_id
        qualify
            rank() over (partition by ki.asset_id order by kca.date_created desc) = 1
    ),
    count_pending_keycodes as (
        select
            ki.asset_id,
            count(kca.keypad_code_assignment_id) as pending_keycode_count,
            count(
                case
                    when kca.start_date < dateadd(day, -3, current_timestamp)
                    then kca.keypad_code_assignment_id
                end
            ) as pending_keycode_aged_count
        from keypad_info ki
        left join
            {{ ref("platform", "es_warehouse__public__keypad_code_assignments") }} kca
            on ki.keypad_id = kca.keypad_id
        left join
            {{
                ref(
                    "platform",
                    "es_warehouse__public__keypad_code_assignment_statuses",
                )
            }} kcas
            on kca.keypad_code_assignment_status_id
            = kcas.keypad_code_assignment_status_id
        where upper(kcas.name) like 'PENDING%'
        group by ki.asset_id
    ),
    TELEMATICS_HEALTH_REPORT_INFO AS (SELECT AL.ASSET_ID,
                                         CONCAT_WS(' ', coalesce(THR.TRACKER_VENDOR,''), coalesce(TI.TRACKER_MODEL,''))          AS TRACKER,
                                         THR.PHONE_NUMBER,
                                         THR.TRACKER_LAST_DATE_INSTALLED ,
                                         THR.LATEST_REPORT_TIMESTAMP     ,
                                         THR.BATTERY_VOLTAGE,
                                         CASE 
                                            WHEN THR.TRACKER_FIRMWARE_VERSION = 'Unknown' THEN NULL
                                            ELSE THR.TRACKER_FIRMWARE_VERSION
                                         END AS TRACKER_FIRMWARE_VERSION,
                                         THR.BLE_ON_OFF,
                                         THR.GEOFENCES,
                                         THR.LAST_LOCATION,
                                         THR.IS_BLE_NODE,
                                         THR.UNPLUGGED,
                                         THR.STREET,
                                         THR.CITY,
                                         THR.STATE,
                                         THR.ZIP_CODE,
                                         THR.LOCATION,
                                        
                                        CAST(THR.LAST_CHECKIN_TIMESTAMP AS TIMESTAMP)       AS LAST_CHECKIN_TIMESTAMP,
                                        TRY_TO_DOUBLE(THR.ASSET_BATTERY_VOLTAGE)            AS ASSET_BATTERY_VOLTAGE,
                                        CAST(THR.START_STALE_GPS_FIX_TIMESTAMP AS TIMESTAMP) AS START_STALE_GPS_FIX_TIMESTAMP,
                                        CAST(THR.LAST_LOCATION_TIMESTAMP AS TIMESTAMP)       AS LAST_LOCATION_TIMESTAMP,
                                        CAST(THR.LATEST_GPS_FIX_TIMESTAMP AS TIMESTAMP)     AS LATEST_GPS_FIX_TIMESTAMP,
                                         THR.LATEST_SATELLITES,
                                         --SLAPNTRACK TYPE TRACKERS USE RSRP NOT RSSI
                                         CASE WHEN TI.TRACKER_TYPE_ID = 38 THEN NULL ELSE THR.RSSI END          AS RSSI,
                                         THR.RSSI_TIMESTAMP                                     AS LAST_CELLULAR_CONTACT,
                                         THR.HOURS                                                              AS HOURS,
                                         THR.ODOMETER                                                           AS ODOMETER,
                                         SUBSTRING(LAST_LOCATION, 1, CHARINDEX(',', LAST_LOCATION) - 1)         AS LAT,
                                         SUBSTRING(LAST_LOCATION, CHARINDEX(',', LAST_LOCATION) + 1,
                                                   LEN(LAST_LOCATION))                                          AS LONG,
                                                             
                                        THR.address AS LAST_ADDRESS,
                                        THR.hdop,
                                        THR.hdop_timestamp
                                        
                                  FROM ASSET_LIST AL
                                LEFT JOIN {{ ref('stg_t3__tracker_status_key_values') }} THR
                                            ON AL.ASSET_ID = THR.ASSET_ID
                                LEFT JOIN TRACKER_INFO TI
                                            ON AL.ASSET_ID = TI.ASSET_ID),
        --      AS OF SPRING 2025 SLAPNTRACK FIRMWARE IS NOT MAKING IT TO DB SO WE ARE PULLING FROM MESSAGES
     SNT_FIRMWARE AS (
        SELECT TI.ASSET_ID,
            TI.TRACKER_SERIAL,
            M.DECODED_MESSAGE[0]:app_version::STRING AS TRACKER_FIRMWARE_VERSION
        FROM TRACKER_INFO TI
        JOIN TRACKERS.PUBLIC.MESSAGES M
            ON TI.TRACKER_SERIAL = M.DEVICE_SERIAL
                AND M.DECODED_MESSAGE[0]:type NOT IN ('syslog')
                AND M.DATE_CREATED >= DATEADD(DAY, -60, CURRENT_DATE)
        WHERE TI.TRACKER_TYPE_ID = 38
        QUALIFY ROW_NUMBER() OVER (PARTITION BY M.DEVICE_SERIAL ORDER BY M.MESSAGE_ID DESC) = 1
    ),
    max_voltage as (
        with
            most_recent as (
                select
                    sasbv.asset_id, max(cast(sasbv.date_start as date)) as recent_date
                from
                    {{
                        ref(
                            "platform",
                            "es_warehouse__scd__scd_asset_statuses_battery_voltage",
                        )
                    }} sasbv
                where sasbv.date_start > dateadd(day, -30, current_timestamp)
                group by sasbv.asset_id
            )
        select
            al.asset_id,
            avg(sasbv.battery_voltage) as recent_avg_battery_voltage,
            mr.recent_date as recent_batt_voltage_date
        from asset_list al
        left join
            {{
                ref(
                    "platform",
                    "es_warehouse__scd__scd_asset_statuses_battery_voltage",
                )
            }} sasbv on al.asset_id = sasbv.asset_id
        inner join
            most_recent mr
            on sasbv.asset_id = mr.asset_id
            and cast(sasbv.date_start as date) = mr.recent_date
        group by al.asset_id, mr.recent_date
        order by al.asset_id
    ),
    asset_battery_info as (
        select
            al.asset_id,
            bvt.name as battery_voltage_type,
            TRY_TO_DOUBLE(json_extract_path_text(threshold, 'lower_bound')) as lower_bound,
            TRY_TO_DOUBLE(json_extract_path_text(threshold, 'upper_bound')) as upper_bound,
            case
                when ti.tracker_type <> 'WIRED CELLULAR'
                then 'NON-WIRED TRACKER'
                /* Even when a battery is disconnected (switch is off), electricity can still "leak" across the wires
                    creating small phantom voltage readings. Higher voltage systems (like 48V, 72V) 
                    have more leakage than lower voltage systems (like 12V, 24V).
                    1. The current battery voltage is near zero
                    The cutoff depends on the machine’s battery system (12V, 24V, 48V, or 72V).
                    A voltage this low means the battery is not actively powering the machine.
                    2. The machine reported a normal battery voltage recently
                    We look at the most recent average battery voltage from the history table.
                    That reading must be from within the last 24 hours.
                    3. That recent voltage was within the expected operating range
                    This confirms the battery was healthy and connected recently.
                    It rules out a long-term dead or failed battery.
                    These thresholds account for that natural leakage to properly detect when
                    someone has activated the kill switch vs. normal electrical behavior. 
                */
                when
                    thri.asset_battery_voltage <
                        case bvt.battery_voltage_type_id
                            when 1 then 1.0  -- 12V
                            when 2 then 2.0  -- 24V
                            when 34 then 4.0 -- 48V
                            when 35 then 6.0 -- 72V
                            else 1.0 -- Conservative default
                        end
                        and mv.recent_batt_voltage_date
                        >= dateadd(hour, -24, current_timestamp())
                        and mv.recent_avg_battery_voltage
                        between lower_bound and upper_bound
                then 'MASTER CUTOFF SWITCH/TRACKER DISCONNECTED'
                when thri.asset_battery_voltage is null
                then 'NO ASSET BATTERY VOLTAGE READINGS'
                when thri.asset_battery_voltage between lower_bound and upper_bound
                then 'NO'
                when thri.asset_battery_voltage > upper_bound
                then 'CHECK ASSET VOLTAGE TYPE'
                when thri.asset_battery_voltage between lower_bound * .9 and lower_bound
                then 'DRAINED ASSET BATTERY'
                -- SOME ASSETS ARE MISSING BATTERY VOLTAGE TYPE
                when battery_voltage_type is null
                then 'UNKNOWN BATTERY VOLTAGE TYPE'
                else 'YES'
            end as dead_battery
        from asset_list al
        inner join tracker_info ti on al.asset_id = ti.asset_id
        left join
            {{ ref("platform", "es_warehouse__public__battery_voltage_types") }} bvt
            on al.battery_voltage_type_id = bvt.battery_voltage_type_id
        left join telematics_health_report_info thri on al.asset_id = thri.asset_id
        left join max_voltage mv on al.asset_id = mv.asset_id
    ),
    TRACKER_HEALTH AS (SELECT AL.ASSET_ID,
                         CASE
                             WHEN AL.TRACKER_ID IS NULL THEN 'NO TRACKER INSTALLED'
                             WHEN THRI.UNPLUGGED = 'TRUE' THEN 'UNPLUGGED TRACKER'
                             --Battery powered cellular trackers
                             WHEN TI.TRACKER_TYPE = 'BATTERY CELLULAR'
                                 AND LAST_CHECKIN_TIMESTAMP IS NULL
                                 THEN 'NO CHECKIN'
                             WHEN TI.TRACKER_TYPE = 'BATTERY CELLULAR'
                                 AND LATEST_GPS_FIX_TIMESTAMP IS NULL
                                 THEN 'NO GPS'
                             WHEN TI.TRACKER_TYPE = 'BATTERY CELLULAR'
                                 AND LAST_CHECKIN_TIMESTAMP < DATEADD(DAY, -60, CURRENT_TIMESTAMP())
                                 THEN 'LAST COMM > 60 DAYS'
                             WHEN TI.TRACKER_TYPE = 'BATTERY CELLULAR'
                                 AND LATEST_GPS_FIX_TIMESTAMP < DATEADD(DAY, -90, CURRENT_TIMESTAMP())
                                 THEN 'STALE GPS > 90 DAYS'
                             WHEN TI.TRACKER_TYPE = 'BATTERY CELLULAR'
                                 AND LAST_CHECKIN_TIMESTAMP <= DATEADD(HOUR, -96, CURRENT_TIMESTAMP())
                                 AND TI.TRACKER_TYPE_ID <> 38
                                 --Tracker type 38 SlapNTracks don't use RSSI
                                 AND ABS(THRI.RSSI) >= 90
                                 THEN 'LIKELY IN LOW CELL COVERAGE AREA'
                             WHEN TI.TRACKER_TYPE = 'BATTERY CELLULAR'
                                 AND LAST_CHECKIN_TIMESTAMP <= DATEADD(HOUR, -96, CURRENT_TIMESTAMP())
                                 AND THRI.LATEST_SATELLITES < 4
                                 THEN 'LIKELY UNDER COVER OR INSIDE BUILDING'
                             WHEN TI.TRACKER_TYPE = 'BATTERY CELLULAR'
                                 AND LAST_CHECKIN_TIMESTAMP <= DATEADD(HOUR, -96, CURRENT_TIMESTAMP())
                                 THEN 'LAST COMM > 96 HRS'
                             WHEN TI.TRACKER_TYPE = 'BATTERY CELLULAR'
                                 AND LATEST_GPS_FIX_TIMESTAMP <= DATEADD(HOUR, -96, CURRENT_TIMESTAMP())
                                 THEN 'STALE GPS > 96 HRS'
                             --Bluetooth trackers
                             --Bluetooth doesn't have 'Latest GPS Fix Timestamp' only 'Last Location Timestamp Date'
                             WHEN TI.TRACKER_TYPE = 'BLUETOOTH' THEN
                                 CASE
                                     WHEN LAST_LOCATION_TIMESTAMP IS NULL THEN 'NO GPS'
                                     WHEN LAST_CHECKIN_TIMESTAMP IS NULL THEN 'NO CHECKIN'
                                     WHEN LAST_CHECKIN_TIMESTAMP >= DATEADD(DAY, -180, CURRENT_TIMESTAMP())
                                         AND LAST_LOCATION_TIMESTAMP < DATEADD(DAY, -180, CURRENT_TIMESTAMP())
                                         THEN 'LAST GPS > 180 DAYS'
                                     WHEN LAST_CHECKIN_TIMESTAMP < DATEADD(DAY, -180, CURRENT_TIMESTAMP())
                                         THEN 'LAST COMM > 180 DAYS'
                                     ELSE 'HEALTHY'
                                     END
                             --Wired/all other trackers
                             --ALLIED TRACKERS (VISION LINK, JD LINK, ETC.) DON'T HAVE LATEST_GPS_FIX_TIMESTAMP
                             --NO GPS
                             WHEN (TRACKER_TYPE_ID IS NULL OR TRACKER_TYPE_ID = 18) --VISION LINK IS 18
                                 AND COALESCE(LATEST_GPS_FIX_TIMESTAMP, LAST_LOCATION_TIMESTAMP) IS NULL
                                 THEN 'NO GPS'
                             --THESE ARE IDENTIFIED BY NOT HAVING A TRACKER_TYPE_ID
                             --STALE GPS > 90 DAYS
                             WHEN (TRACKER_TYPE_ID IS NULL OR TRACKER_TYPE_ID = 18) --VISION LINK IS 18
                                 AND COALESCE(LATEST_GPS_FIX_TIMESTAMP, LAST_LOCATION_TIMESTAMP) <=
                                     DATEADD(DAY, -90, CURRENT_TIMESTAMP())
                                 THEN 'STALE GPS > 90 DAYS'
                             --STALE GPS > 96 HRS
                             WHEN (TRACKER_TYPE_ID IS NULL OR TRACKER_TYPE_ID = 18) --VISION LINK IS 18
                                 AND COALESCE(LATEST_GPS_FIX_TIMESTAMP, LAST_LOCATION_TIMESTAMP) <=
                                     DATEADD(HOUR, -96, CURRENT_TIMESTAMP())
                                 THEN 'STALE GPS > 96 HRS'
                             --FOR ALL ES TRACKERS, IF THERE IS NO CHECKIN WE WANT TO FLAG THEM
                             WHEN TI.TRACKER_TYPE_ID IS NOT NULL AND LAST_CHECKIN_TIMESTAMP IS NULL
                                 THEN 'NO CHECKIN'
                             --If not on rent, should be at a branch with cell service and checking in, if not get it checked
                             WHEN AL.ASSET_INVENTORY_STATUS LIKE ANY
                                  ('Ready To Rent', 'Needs Inspection')
                                 AND AL.OWNERSHIP IN ('ES', 'OWN')
                                 AND LAST_CHECKIN_TIMESTAMP <= DATEADD(HOUR, -96, CURRENT_TIMESTAMP())
                                 THEN 'LAST COMM > 96 HRS OFF RENT'
                             --Aerial units > 6 mo, checkins only
                             --Aerials get put in building basements, allowing longer duration for check ins per Bryan Walsh
                             WHEN AL.CATEGORY LIKE 'Aerial Work Platforms'
                                 AND AL.OWNERSHIP IN ('ES', 'OWN')
                                 AND LAST_CHECKIN_TIMESTAMP < DATEADD(DAY, -60, CURRENT_TIMESTAMP())
                                 AND LAST_CHECKIN_TIMESTAMP > DATEADD(DAY, -180, CURRENT_TIMESTAMP())
                                 THEN 'LAST COMM 60-180 DAYS AERIAL'
                             WHEN AL.CATEGORY LIKE 'Aerial Work Platforms'
                                 --DON'T NEED LAST_LOCATION_TIMESTAMP COALESCE BECAUSE PRESUMABLY
                                 --THESE WILL HAVE IN HOUSE TRACKERS
                                 AND AL.OWNERSHIP IN ('ES', 'OWN')
                                 AND LATEST_GPS_FIX_TIMESTAMP < DATEADD(DAY, -60, CURRENT_TIMESTAMP())
                                 AND LATEST_GPS_FIX_TIMESTAMP > DATEADD(DAY, -180, CURRENT_TIMESTAMP())
                                 THEN 'STALE GPS 60-180 DAYS AERIAL'
                             ----------------------------------------------------
                             ---STRAIGHT 60 DAY LAST CHECKIN
                             WHEN LAST_CHECKIN_TIMESTAMP < DATEADD(DAY, -60, CURRENT_TIMESTAMP())
                                 THEN 'LAST COMM > 60 DAYS'
                             --STRAIGHT 90 DAY LAST GPS CHECK
                             WHEN LATEST_GPS_FIX_TIMESTAMP < DATEADD(DAY, -90, CURRENT_TIMESTAMP())
                                 THEN 'STALE GPS > 90 DAYS'
                             ----------------------------------------------------
                             WHEN LAST_CHECKIN_TIMESTAMP <= DATEADD(HOUR, -96, CURRENT_TIMESTAMP())
                                 AND ABS(THRI.RSSI) >= 90
                                 THEN 'LIKELY IN LOW CELL COVERAGE AREA'
                             WHEN LAST_CHECKIN_TIMESTAMP <= DATEADD(HOUR, -96, CURRENT_TIMESTAMP())
                                 AND THRI.LATEST_SATELLITES < 4
                                 THEN 'LIKELY UNDER COVER OR INSIDE BUILDING'
                             WHEN LAST_CHECKIN_TIMESTAMP <= DATEADD(HOUR, -96, CURRENT_TIMESTAMP())
                                 THEN 'LAST COMM > 96 HRS'
                             WHEN LATEST_GPS_FIX_TIMESTAMP IS NULL THEN 'NO GPS'
                             WHEN LATEST_GPS_FIX_TIMESTAMP <= DATEADD(DAY, -90, CURRENT_TIMESTAMP())
                                 THEN 'STALE GPS > 90 DAYS'
                             WHEN LATEST_GPS_FIX_TIMESTAMP <= DATEADD(HOUR, -96, CURRENT_TIMESTAMP())
                                 AND LATEST_GPS_FIX_TIMESTAMP > DATEADD(DAY, -90, CURRENT_TIMESTAMP())
                                 THEN 'STALE GPS > 96 HRS'
                             WHEN ABI.DEAD_BATTERY = 'YES' THEN 'DEAD ASSET BATTERY'
                             WHEN ABI.DEAD_BATTERY = 'DRAINED ASSET BATTERY' THEN 'DRAINED ASSET BATTERY'
                             WHEN ABI.DEAD_BATTERY = 'MASTER CUTOFF SWITCH/TRACKER DISCONNECTED' THEN
                                 'MASTER CUTOFF SWITCH/TRACKER DISCONNECTED'
                             ELSE 'HEALTHY'
                             END
                                 AS ASSET_HEALTH_DETAIL,
                         CASE
                             WHEN ASSET_HEALTH_DETAIL = 'HEALTHY' THEN 'HEALTHY'
                             WHEN ASSET_HEALTH_DETAIL IN ('NO TRACKER INSTALLED') THEN 'NO TRACKER INSTALLED'
                             WHEN ASSET_HEALTH_DETAIL IN ('STALE GPS > 96 HRS',
                                                          'LIKELY IN LOW CELL COVERAGE AREA',
                                                          'LIKELY UNDER COVER OR INSIDE BUILDING',
                                                          'LAST COMM 60-180 DAYS AERIAL',
                                                          'STALE GPS 60-180 DAYS AERIAL'
                                 ) THEN 'UNSTABLE'
                             WHEN ASSET_HEALTH_DETAIL IN
                                  ('MASTER CUTOFF SWITCH/TRACKER DISCONNECTED')
                                 THEN 'MASTER CUTOFF SWITCH/TRACKER DISCONNECTED'
                             WHEN ASSET_HEALTH_DETAIL IN
                                  ('DEAD ASSET BATTERY',
                                   'DRAINED ASSET BATTERY')
                                 THEN 'NEEDS SERVICE ATTENTION'
                             WHEN ASSET_HEALTH_DETAIL IN
                                  ('NO CHECKIN', 'LAST COMM > 96 HRS', 'LAST COMM > 60 DAYS',
                                   'STALE GPS > 90 DAYS', 'NO GPS',
                                   'LAST COMM > 96 HRS OFF RENT', 'LAST COMM > 180 DAYS AERIAL',
                                   'UNPLUGGED TRACKER', 'LAST COMM > 180 DAYS', 'LAST GPS > 180 DAYS')
                                 THEN 'NEEDS TELEMATICS ATTENTION'
                             ELSE 'Status unknown - Contact Support'
                             END AS ASSET_HEALTH_STATUS,


                         --------------------------------------------------------------------------------------------------------------
                         ---THIS IS THE T3 CUSTOMER FACING STATUS COLUMN


                         CASE
                             WHEN ASSET_HEALTH_DETAIL = 'HEALTHY' THEN 'Healthy'
                             WHEN ASSET_HEALTH_DETAIL IN ('NO TRACKER INSTALLED') THEN 'No Tracker Installed'
                             WHEN ASSET_HEALTH_DETAIL IN
                                  ('LIKELY IN LOW CELL COVERAGE AREA')
                                 THEN 'Asset Likely In Low Cell Coverage Area'
                             WHEN ASSET_HEALTH_DETAIL IN
                                  ('STALE GPS > 96 HRS', 'STALE GPS > 90 DAYS',
                                   'LIKELY UNDER COVER OR INSIDE BUILDING')
                                 THEN 'Asset Likely Under Cover or Inside Building'
                             WHEN ASSET_HEALTH_DETAIL IN ('DRAINED ASSET BATTERY')
                                 THEN 'Drained Asset Battery'
                             WHEN ASSET_HEALTH_DETAIL IN ('DEAD ASSET BATTERY')
                                 THEN 'Dead Asset Battery'
                             WHEN ASSET_HEALTH_DETAIL IN
                                  ('MASTER CUTOFF SWITCH/TRACKER DISCONNECTED')
                                 THEN 'Master Cutoff Switch/Tracker Disconnected'
                             WHEN ASSET_HEALTH_DETAIL IN
                                  ('NO CHECKIN', 'LAST COMM > 96 HRS', 'LAST COMM > 60 DAYS',
                                   'NO GPS',
                                   'LAST COMM > 96 HRS OFF RENT', 'LAST COMM > 180 DAYS AERIAL',
                                   'UNPLUGGED TRACKER', 'LAST COMM > 180 DAYS', 'LAST GPS > 180 DAYS',
                                   'LAST COMM 60-180 DAYS AERIAL', 'STALE GPS 60-180 DAYS AERIAL')
                                 THEN 'Needs Tracker Attention'
                             ELSE 'Status unknown - Contact Support'
                             END AS PUBLIC_HEALTH_STATUS,
                         --------------------------------------------------------------------------------------------------------------
                         CASE
                             WHEN ASSET_HEALTH_DETAIL = 'HEALTHY' THEN TRUE
                             ELSE FALSE
                             END AS IS_REPORTING_READY
                  from asset_list al
                           left join tracker_info ti on al.asset_id = ti.asset_id
                           left join telematics_health_report_info thri on al.asset_id = thri.asset_id
                           left join asset_battery_info abi on al.asset_id = abi.asset_id
                           left join last_trip lt on al.asset_id = lt.asset_id
    ),
    secondary_tracker_health as (
        select sti.custom_name,
        th.asset_health_status as secondary_tracker_health_status,
        th.asset_health_detail as secondary_tracker_health_detail
    from secondary_tracker_info sti
        left join tracker_health th on sti.ASSET_ID = th.asset_id
    ),
    ghost_tracker_health as (
        select gti.custom_name,
        th.asset_health_status as ghost_tracker_health_status,
        th.asset_health_detail as ghost_tracker_health_detail
    from ghost_tracker_info gti
        left join tracker_health th on gti.ASSET_ID = th.asset_id
    ),
    camera_health as (
        select
            al.asset_id,
            case
                when ci.camera_id is null
                then 'NO CAMERA INSTALLED'
                when chb.dvrheartbeat > dateadd(days, -30, current_date)
                then 'CAMERA HEALTH OK'
                when
                    chb.dvrheartbeat < dateadd(days, -30, current_date)
                    and lt.last_trip_date <= chb.dvrheartbeat
                then 'CAMERA HEALTH OK'
                when
                    chb.dvrheartbeat < dateadd(days, -30, current_date)
                    or chb.dvrheartbeat is null
                then 'CAMERA NEEDS ATTENTION'
                else 'UNKNOWN'
            end as camera_health
        from asset_list al
        left join camera_info ci on al.asset_id = ci.asset_id
        left join camera_heartbeat chb on al.asset_id = chb.asset_id
        left join last_trip lt on al.asset_id = lt.asset_id
    )
     ,
     RENTAL_INFO AS (SELECT AL.ASSET_ID,
                            STOR.COMPANY_ID   AS RENTING_COMPANY_ID,
                            STOR.COMPANY_NAME AS RENTING_COMPANY_NAME,
                            STOR.RENTAL_ID,
                            STOR.SCHEDULED_OFF_RENT_DATE
                     FROM ASSET_LIST AL
                               JOIN {{ ref('stg_t3__on_rent') }} STOR
                                   ON AL.ASSET_ID = STOR.ASSET_ID
                                   )
select distinct
    al.asset_id,
    al.custom_name,
    al.serial_vin,
    al.make,
    al.model,
    al.year,
    al.asset_class,
    al.asset_type,
    al.asset_type_thr,
    al.company_id,
    al.company_name,
    al.asset_inventory_status,
    al.market_id,
    al.market_name,
    al.district,
    al.region,
    al.telematics_region,
    al.ownership,
    al.inventory_branch,
    ai.service_branch,
    al.tracker_id,
    ti.tracker_serial,
    ti.tracker_serial as device_serial,
    ti.tracker_type_id,
    ti.tracker_vendor,
    ti.tracker_type,
    case
        when ti.tracker_model ilike ti.tracker_vendor || '%'
        then ti.tracker_model
        else trim(concat(coalesce(ti.tracker_vendor, ''), ' ',
        coalesce(ti.tracker_model, ''))) 
    end as tracker,
    thri.phone_number,
    thri.tracker_last_date_installed,
    thri.latest_report_timestamp,
    thri.battery_voltage,
    coalesce(thri.tracker_firmware_version, sntf.tracker_firmware_version) as tracker_firmware_version,
    thri.ble_on_off,
    thri.geofences,
    thri.last_location,
    thri.is_ble_node,
    thri.unplugged,
    thri.street,
    thri.city,
    thri.state,
    thri.zip_code,
    thri.location,
    thri.last_checkin_timestamp::timestamp_tz as last_checkin_timestamp,
    thri.asset_battery_voltage,
    thri.start_stale_gps_fix_timestamp,
    thri.last_location_timestamp::timestamp_tz as last_location_timestamp,
    thri.latest_gps_fix_timestamp,
    thri.latest_satellites,
    thri.rssi,
    thri.LAST_CELLULAR_CONTACT as rssi_timestamp,
    thri.last_cellular_contact,
    thri.hours::number(38,0) as hours,
    thri.odometer as odometer,
    thri.lat::float as lat,
    thri.long::float as long,
    abi.dead_battery,
    th.asset_health_detail,
    thri.last_address,
    mv.recent_batt_voltage_date as max_voltage_date,
    mv.recent_avg_battery_voltage as max_voltage,
    pdik.hardware_name || ' - ' || pdik.hardware_version as keypad_hardware,
    pdik.app_name || ' - ' || pdik.app_version as keypad_app,
    pdik.bootloader_name || ' - ' || pdik.bootloader_version as keypad_bootloader,
    pdie.hardware_name || ' - ' || pdie.hardware_version as ecm_hardware,
    pdie.app_name || ' - ' || pdie.app_version as ecm_app,
    pdie.bootloader_name || ' - ' || pdie.bootloader_version as ecm_bootloader,
    lkm.last_keypad_entry_date,
    lt.last_trip_date,
    lt.days_btwn_keypad_entry_and_trip,
    coalesce(lt.keypad_vs_trip_health, 'MISSING DATA') as keypad_vs_trip_health,
    lkca.last_keycode_assignment_date,
    lkca.last_keycode_assignment_status,
    th.asset_health_status,
    dr.tracker_req_type,
    dis.tracker_install_status,
    ki.keypad_id,
    ki.keypad_serial,
    dr.keypad_req,
    dis.keypad_install_status,
    dr.keypad_req_type,
    ci.camera_id,
    ci.camera_serial,
    ci.camera_vendor,
    ci.date_installed as camera_install_date,
    dr.camera_req,
    dis.camera_install_status,
    ch.camera_health,
    chb.dvrheartbeat as last_camera_heartbeat,
    dr.has_can,
    dr.secondary_tracker_req,
    dis.secondary_tracker_install_status,
    sti.secondary_tracker_id,
    sti.secondary_tracker_serial,
    sti.secondary_tracker_type,
    sti.secondary_tracker_vendor,
    sti.secondary_tracker_last_checkin,
    sth.secondary_tracker_health_status,
    gti.ghost_tracker_id,
    gti.ghost_tracker_serial,
    gti.ghost_tracker_type,
    gti.ghost_tracker_vendor,
    gti.ghost_tracker_last_checkin,
    gth.ghost_tracker_health_status,
    dr.ghost_tracker_req,
    dis.ghost_tracker_install_status,
    th.public_health_status,
    ldl.last_delivery_date,
    ldl.last_delivery_lat,
    ldl.last_delivery_long,
    ldl.last_delivery_drop_off_or_return,
    ldl.last_delivery_contact_name,
    ldl.last_delivery_contact_phone,
    ldl.last_delivery_address,
    ti.tracker_model,
    cpk.pending_keycode_count,
    sth.secondary_tracker_health_detail,
    al.category,
    cpk.pending_keycode_aged_count,
    abi.battery_voltage_type,
    RI.RENTAL_ID,
    RI.RENTING_COMPANY_ID,
    RI.RENTING_COMPANY_NAME,
    RI.SCHEDULED_OFF_RENT_DATE,
    TH.IS_REPORTING_READY,    
    TI.TRACKER_GROUPING,
    thri.hdop,
    thri.hdop_timestamp,
    CURRENT_TIMESTAMP()::timestamp_ntz AS data_refresh_timestamp
from asset_list al
left join asset_battery_info abi on al.asset_id = abi.asset_id
left join max_voltage mv on al.asset_id = mv.asset_id
left join tracker_info ti on al.asset_id = ti.asset_id
left join secondary_tracker_info sti on TO_VARCHAR(al.asset_id) = sti.custom_name
left join telematics_health_report_info thri on al.asset_id = thri.asset_id
left join keypad_info ki on al.asset_id = ki.asset_id
left join
    peripheral_device_info pdik
    on ti.tracker_tracker_id = pdik.tracker_id
    and upper(pdik.hardware_name) = upper('KEYPAD')
left join
    peripheral_device_info pdie
    on ti.tracker_tracker_id = pdie.tracker_id
    and upper(pdie.app_name) like upper('ECM%CAN')
left join count_pending_keycodes cpk on al.asset_id = cpk.asset_id
left join last_keypad_message lkm on al.asset_id = lkm.asset_id
left join last_keypad_code_assignment lkca on al.asset_id = lkca.asset_id
left join last_trip lt on al.asset_id = lt.asset_id
left join devices_required dr on al.asset_id = dr.asset_id
left join device_install_status dis on al.asset_id = dis.asset_id
left join camera_info ci on al.asset_id = ci.asset_id
left join camera_heartbeat chb on al.asset_id = chb.asset_id
left join tracker_health th on al.asset_id = th.asset_id
left join secondary_tracker_health sth on TO_VARCHAR(al.asset_id) = sth.custom_name
left join camera_health ch on al.asset_id = ch.asset_id
left join last_delivery_location ldl on al.asset_id = ldl.asset_id
left join rental_info ri on al.asset_id = ri.asset_id
left join snt_firmware sntf on sntf.tracker_serial = ti.tracker_serial
left join {{ ref('stg_t3__asset_info') }} ai on ai.asset_id = al.asset_id
left join ghost_tracker_info gti on TO_VARCHAR(al.asset_id) = gti.custom_name
left join ghost_tracker_health gth on TO_VARCHAR(al.asset_id) = gth.custom_name