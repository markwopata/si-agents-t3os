view: telematics_health_report {

  derived_table: {

    sql:
with max_voltage as (
select asset_id, date_start::date as date1, max(battery_voltage) as maxvoltage1
from es_warehouse.scd.scd_asset_statuses_battery_voltage sasbv
where sasbv.date_start::date = (select max(date_start::date)
                                from es_warehouse.scd.scd_asset_statuses_battery_voltage isasbv
                                where sasbv.asset_id = isasbv.asset_id)
group by asset_id, date_start::date
)
,  own_list as (
      select asset_id FROM table(assetlist({{ _user_attributes['user_id'] }}::numeric ))
      )
, query_before_grouping as (
      Select thr.tracker_id,
          thr.device_serial,
          thr.phone_number,
          thr.tracker_type,
          thr.tracker_vendor,
          concat(thr.tracker_vendor, ' ', tracker_type) as tracker,
          thr.asset_id,
          convert_timezone('{{ _user_attributes['user_timezone'] }}', thr.tracker_last_date_installed) as tracker_last_date_installed,
          convert_timezone('{{ _user_attributes['user_timezone'] }}', thr.latest_report_timestamp) as latest_report_timestamp,
          thr.battery_voltage,
          thr.tracker_firmware_version,
          thr.ble_on_off,
          thr.geofences,
          thr.last_location,
          thr.is_ble_node,
          --thr.out_of_lock_reason,
          --thr.out_of_lock_timestamp,
          thr.unplugged,
          thr.street,
          thr.city,
          thr.state,
          thr.zip_code,
          thr.location,
          convert_timezone('{{ _user_attributes['user_timezone'] }}', cast(thr.last_checkin_timestamp as timestamp)) as last_checkin_timestamp,
          thr.asset_battery_voltage,
          convert_timezone('{{ _user_attributes['user_timezone'] }}', cast(thr.start_stale_gps_fix_timestamp as timestamp)) as start_stale_gps_fix_timestamp,
          convert_timezone('{{ _user_attributes['user_timezone'] }}', cast(thr.last_location_timestamp as timestamp)) as last_location_timestamp,
          convert_timezone('{{ _user_attributes['user_timezone'] }}', cast(thr.latest_gps_fix_timestamp as timestamp)) as latest_gps_fix_timestamp,
          thr.latest_satellites,
          thr.rssi,
          convert_timezone('{{ _user_attributes['user_timezone'] }}', thr.rssi_timestamp) as last_cellular_contact,
          thr.hours,
          Substring(last_location, 1,Charindex(',', last_location)-1) as lat,
          Substring(last_location, Charindex(',', last_location)+1, LEN(last_location)) as long,
          m.name as inventory_branch,
--          case
--            when start_stale_gps_fix_timestamp is not null then 'Yes'
--            else 'No'
--          end as stale_GPS,
          case
            when asset_battery_voltage between .01 and 8 then 'Yes'
            else 'No'
          end as dead_battery,
          case
            when unplugged = 'true' then 'Unplugged Tracker'
            when thr.tracker_id is null then 'No Tracker Installed'
            when asset_battery_voltage > .1 and asset_battery_voltage < 8 then 'Dead Battery'
            when asset_battery_voltage >= 10.8 and (start_stale_gps_fix_timestamp is not null or datediff(day, latest_gps_fix_timestamp, thr.last_location_timestamp) > 4) then 'Stale GPS'
            when (latest_report_timestamp is null and start_stale_gps_fix_timestamp is null) or thr.last_location_timestamp::date <= DATEADD(month,-3, GETDATE()) then 'Unknown Error Contact Support'
            --when latest_report_timestamp is not null and (start_stale_gps_fix_timestamp is null or start_stale_gps_fix_timestamp between '12-30-1969' and '01-01-1970') then 'Stale GPS'
            when asset_battery_voltage >= 12 and latest_report_timestamp <= DATEADD(hour,-12, GETDATE())
                then
                    case
                        when cast(replace(rssi, '-', '') as integer) < 90 then 'Unknown Error Contact Support'
                        when cast(replace(rssi, '-', '') as integer) >= 90 then 'Likely in Low Coverage Area'
                    else 'Stale GPS'
                    end
             when asset_battery_voltage < 12 and latest_report_timestamp <= DATEADD(hour,-12, GETDATE())
                then
                    case
                        when asset_battery_voltage < 1 and maxvoltage1 >= 10.8 then 'Master Cutoff Switch/Tracker Disconnected'
                        else 'Drained Battery'
                    end
            when thr.last_checkin_timestamp is null then 'Unknown Error Contact Support'
            else 'Healthy'
            end as asset_status,
            coalesce(a.serial_number, a.vin) as serial_vin,
            --case
              -- when thr.geofences is not null then concat('Geofence: ', thr.geofences)
              -- when thr.geofences is null then CONCAT(COALESCE(street,''),',',COALESCE(city,''),',',COALESCE(state,''),'',COALESCE(zip_code,''))
            --else thr.last_location
            --end as last_address,
            case
              when length(CONCAT(COALESCE(street,''),',',COALESCE(city,''),',',COALESCE(state,''),'',COALESCE(zip_code,''))) <= 5 then thr.last_location
              else CONCAT(COALESCE(street,''),',',COALESCE(city,''),',',COALESCE(state,''),'',COALESCE(zip_code,''))
            end as last_address,
            mv.date1,
            mv.maxvoltage1,
            a.custom_name as name,
            a.make,
            a.model,
            a.asset_class,
            concat(upper(substring(at.name,1,1)),substring(at.name,2,length(at.name))) as asset_type,
            o.name as organization
      from own_list own
          join es_warehouse.public.telematics_health_report thr on thr.asset_id = own.asset_id
          join es_warehouse.public.assets a on thr.asset_id = a.asset_id
          left join es_warehouse.public.markets m on a.inventory_branch_id = m.market_id
          left join max_voltage mv on mv.asset_id = thr.asset_id
          left join asset_types at on a.asset_type_id = at.asset_type_id
          left join organization_asset_xref oax on oax.asset_id = a.asset_id
          left join organizations o on o.organization_id = oax.organization_id
      where a.battery_voltage_type_id = 1
      and a.deleted = false
      AND a.company_id = {{ _user_attributes['company_id'] }}::integer
union
        Select thr.tracker_id,
          thr.device_serial,
          thr.phone_number,
          thr.tracker_type,
          thr.tracker_vendor,
          concat(thr.tracker_vendor, ' ', tracker_type) as tracker,
          thr.asset_id,
          convert_timezone('{{ _user_attributes['user_timezone'] }}', thr.tracker_last_date_installed) as tracker_last_date_installed,
          convert_timezone('{{ _user_attributes['user_timezone'] }}', thr.latest_report_timestamp) as latest_report_timestamp,
          thr.battery_voltage,
          thr.tracker_firmware_version,
          thr.ble_on_off,
          thr.geofences,
          thr.last_location,
          thr.is_ble_node,
          --thr.out_of_lock_reason,
          --thr.out_of_lock_timestamp,
          thr.unplugged,
          thr.street,
          thr.city,
          thr.state,
          thr.zip_code,
          thr.location,
          convert_timezone('{{ _user_attributes['user_timezone'] }}', cast(thr.last_checkin_timestamp as timestamp)) as last_checkin_timestamp,
          thr.asset_battery_voltage,
          convert_timezone('{{ _user_attributes['user_timezone'] }}', cast(thr.start_stale_gps_fix_timestamp as timestamp)) as start_stale_gps_fix_timestamp,
          convert_timezone('{{ _user_attributes['user_timezone'] }}', cast(thr.last_location_timestamp as timestamp)) as last_location_timestamp,
          convert_timezone('{{ _user_attributes['user_timezone'] }}', cast(thr.latest_gps_fix_timestamp as timestamp)) as latest_gps_fix_timestamp,
          thr.latest_satellites,
          thr.rssi,
          thr.rssi_timestamp,
          thr.hours,
          Substring(last_location, 1,Charindex(',', last_location)-1) as lat,
          Substring(last_location, Charindex(',', last_location)+1, LEN(last_location)) as long,
          m.name as inventory_branch,
--          case
--            when start_stale_gps_fix_timestamp is not null then 'Yes'
--            else 'No'
--          end as stale_gps,
          case
            when asset_battery_voltage between .01 and 16 then 'Yes'
            else 'No'
          end as dead_battery,
          case
            when unplugged = 'true' then 'Unplugged Tracker'
            when thr.tracker_id is null then 'Tracker Not Installed'
            when asset_battery_voltage between .01 and 16 then 'Dead Battery'
            when asset_battery_voltage >= 22 and (start_stale_gps_fix_timestamp is not null or datediff(day, latest_gps_fix_timestamp, thr.last_location_timestamp) > 4) then 'Stale GPS'
            when (latest_report_timestamp is null and start_stale_gps_fix_timestamp is null) or thr.last_location_timestamp::date <= DATEADD(month,-3, GETDATE()) then 'Unknown Error Contact Support'
            --when latest_report_timestamp is not null and (start_stale_gps_fix_timestamp is null or start_stale_gps_fix_timestamp between '12-30-1969' and '01-01-1970') then 'Stale GPS'
            when asset_battery_voltage >= 22 and latest_report_timestamp <= DATEADD(hour,-12, GETDATE())
                then
                    case
                        when cast(replace(rssi, '-', '') as integer) < 90 then 'Unknown Error Contact Support'
                        when cast(replace(rssi, '-', '') as integer) >= 90 then 'Likely in Low Coverage Area'
                    else 'Stale GPS'
                    end
             when asset_battery_voltage < 22 and latest_report_timestamp <= DATEADD(hour,-12, GETDATE())
                then
                    case
                        when asset_battery_voltage < 1 and maxvoltage1 >= 22 then 'Master Cutoff Switch/Tracker Disconnected'
                        else 'Drained Battery'
                    end
            when thr.last_checkin_timestamp is null then 'Unknown Error Contact Support'
            else 'Healthy'
            end as asset_status,
            coalesce(a.serial_number, a.vin) as serial_vin,
            --case
            --    when thr.geofences is not null then concat('Geofence: ', thr.geofences)
            --    when thr.geofences is null then CONCAT(COALESCE(street,''),',',COALESCE(city,''),',',COALESCE(state,''),'',COALESCE(zip_code,''))
            --else thr.last_location
            --end as last_address,
            case
              when length(CONCAT(COALESCE(street,''),',',COALESCE(city,''),',',COALESCE(state,''),'',COALESCE(zip_code,''))) <= 5 then thr.last_location
              else CONCAT(COALESCE(street,''),',',COALESCE(city,''),',',COALESCE(state,''),'',COALESCE(zip_code,''))
            end as last_address,
            mv.date1,
            mv.maxvoltage1,
            a.custom_name as name,
            a.make,
            a.model,
            a.asset_class,
            concat(upper(substring(at.name,1,1)),substring(at.name,2,length(at.name))) as asset_type,
            o.name as organization
      from own_list own
          join es_warehouse.public.telematics_health_report thr on thr.asset_id = own.asset_id
          join es_warehouse.public.assets a on thr.asset_id = a.asset_id
          left join es_warehouse.public.markets m on a.inventory_branch_id = m.market_id
          left join max_voltage mv on mv.asset_id = thr.asset_id
          left join asset_types at on a.asset_type_id = at.asset_type_id
          left join organization_asset_xref oax on oax.asset_id = a.asset_id
          left join organizations o on o.organization_id = oax.organization_id
      where a.battery_voltage_type_id = 2 and a.deleted = false
      --AND thr.company_id = {{ _user_attributes['company_id'] }}::integer
      --AND a.company_id = {{ _user_attributes['company_id'] }}::integer)
union
        Select thr.tracker_id,
          thr.device_serial,
          thr.phone_number,
          thr.tracker_type,
          thr.tracker_vendor,
          concat(thr.tracker_vendor, ' ', tracker_type) as tracker,
          thr.asset_id,
          convert_timezone('{{ _user_attributes['user_timezone'] }}', thr.tracker_last_date_installed) as tracker_last_date_installed,
          convert_timezone('{{ _user_attributes['user_timezone'] }}', thr.latest_report_timestamp) as latest_report_timestamp,
          thr.battery_voltage,
          thr.tracker_firmware_version,
          thr.ble_on_off,
          thr.geofences,
          thr.last_location,
          thr.is_ble_node,
          thr.unplugged,
          thr.street,
          thr.city,
          thr.state,
          thr.zip_code,
          thr.location,
          convert_timezone('{{ _user_attributes['user_timezone'] }}', cast(thr.last_checkin_timestamp as timestamp)) as last_checkin_timestamp,
          thr.asset_battery_voltage,
          convert_timezone('{{ _user_attributes['user_timezone'] }}', cast(thr.start_stale_gps_fix_timestamp as timestamp)) as start_stale_gps_fix_timestamp,
          convert_timezone('{{ _user_attributes['user_timezone'] }}', cast(thr.last_location_timestamp as timestamp)) as last_location_timestamp,
          convert_timezone('{{ _user_attributes['user_timezone'] }}', cast(thr.latest_gps_fix_timestamp as timestamp)) as latest_gps_fix_timestamp,
          thr.latest_satellites,
          thr.rssi,
          thr.rssi_timestamp,
          thr.hours,
          Substring(last_location, 1,Charindex(',', last_location)-1) as lat,
          Substring(last_location, Charindex(',', last_location)+1, LEN(last_location)) as long,
          m.name as inventory_branch,
          case
            when asset_battery_voltage between .01 and 16 then 'Yes'
            else 'No'
          end as dead_battery,
          case
            when unplugged = 'true' then 'Unplugged Tracker'
            when thr.tracker_id is null then 'Tracker Not Installed'
            when start_stale_gps_fix_timestamp is not null or datediff(day, latest_gps_fix_timestamp, thr.last_location_timestamp) > 4 then 'Stale GPS'
            when (latest_report_timestamp is null and start_stale_gps_fix_timestamp is null) or thr.last_location_timestamp::date <= DATEADD(month,-3, GETDATE()) then 'Unknown Error Contact Support'
            when latest_report_timestamp <= DATEADD(hour,-12, GETDATE()) and start_stale_gps_fix_timestamp is null
                then
                    case
                        when cast(replace(rssi, '-', '') as integer) < 90 then 'Unknown Error Contact Support'
                        when cast(replace(rssi, '-', '') as integer) >= 90 then 'Likely in Low Coverage Area'
                    else 'Stale GPS'
                    end
            when thr.last_checkin_timestamp is null then 'Unknown Error Contact Support'
            else 'Healthy'
            end as asset_status,
            coalesce(a.serial_number, a.vin) as serial_vin,
            case
              when length(CONCAT(COALESCE(street,''),',',COALESCE(city,''),',',COALESCE(state,''),'',COALESCE(zip_code,''))) <= 5 then thr.last_location
              else CONCAT(COALESCE(street,''),',',COALESCE(city,''),',',COALESCE(state,''),'',COALESCE(zip_code,''))
            end as last_address,
            mv.date1,
            mv.maxvoltage1,
            a.custom_name as name,
            a.make,
            a.model,
            a.asset_class,
            concat(upper(substring(at.name,1,1)),substring(at.name,2,length(at.name))) as asset_type,
            o.name as organization
      from own_list own
          join es_warehouse.public.telematics_health_report thr on thr.asset_id = own.asset_id
          join es_warehouse.public.assets a on thr.asset_id = a.asset_id
          left join es_warehouse.public.markets m on a.inventory_branch_id = m.market_id
          left join max_voltage mv on mv.asset_id = thr.asset_id
          left join asset_types at on a.asset_type_id = at.asset_type_id
          left join organization_asset_xref oax on oax.asset_id = a.asset_id
          left join organizations o on o.organization_id = oax.organization_id
          left join trackers t on thr.tracker_id = t.tracker_id
      where (t.tracker_type_id in (24,25,26) or a.battery_voltage_type_id is null) and a.deleted = false
    ) SELECT *,
    case
          when asset_status = 'Healthy' then 'Healthy'
          when asset_status in ('Unplugged Tracker', 'Tracker Not Installed') then 'Inactive'
          when asset_status in ('Stale GPS', 'Likely in Low Coverage Area') then 'Unstable'
          when asset_status in ('Master Cutoff Switch/Tracker Disconnected', 'Dead Battery', 'Drained Battery', 'Unknown Error Contact Support') then 'Needs Attention'
    else 'No Tracker'
    end as asset_health_status
          FROM query_before_grouping
  ;;
  }

  drill_fields: [tracker_id]

  dimension: tracker_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."TRACKER_ID" ;;
  }

  dimension: device_serial {
    label: "Tracker Serial #"
    type: string
    sql: ${TABLE}."DEVICE_SERIAL" ;;
  }

  dimension: phone_number {
    label: "Tracker Phone #"
    type: string
    sql: ${TABLE}."PHONE_NUMBER" ;;
  }

  dimension: tracker_type {
    type: string
    sql: ${TABLE}."TRACKER_TYPE" ;;
  }

  dimension: tracker_vendor {
    type: string
    sql: ${TABLE}."TRACKER_VENDOR" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: tracker_last_date_installed {
    label: "Tracker Install Date"
    type: date
    sql: ${TABLE}."TRACKER_LAST_DATE_INSTALLED" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: latest_report_timestamp {
    type: date_time
    sql: ${TABLE}."LATEST_REPORT_TIMESTAMP" ;;
    html:
      {{ rendered_value | date: "%b %d, %Y %r"  }} {{ _user_attributes['user_timezone_label'] }} ;;
  }

  dimension: battery_voltage {
    label: "Tracker Battery Voltage"
    type: number
    sql: ${TABLE}."BATTERY_VOLTAGE" ;;
  }

  dimension: tracker_firmware_version {
    description: "Currently, we can only guarantee accurate firmware version readings for Morey devices.
    Calamp device firmware versions may be out of date; verify using the Calamp web interface.
    NO other tracker vendors will show a firmware version here, but for ANY vendor, you may verify the current firmware version using that vendor's web interface."
    type: string
    sql: ${TABLE}."TRACKER_FIRMWARE_VERSION" ;;
  }

  dimension: BLE_on_off {
    label: "BLE Status (On/Off)"
    type: string
    sql: ${TABLE}."BLE_ON_OFF" ;;
  }

  dimension: geofences {
    type: string
    sql: ${TABLE}."GEOFENCES" ;;
  }

  dimension: last_location {
    type: string
    sql: ${TABLE}."LAST_LOCATION" ;;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/assets/all/asset/{{ telematics_health_report.asset_id }}" target="_blank">View Fleet Map</a></font></u> ;;
  }

#  dimension: last_location {
#    type: string
#    sql: ${TABLE}."LAST_LOCATION" ;;
#    html: <font color="#0063f3"><u><a href="https://www.google.com/maps/place/{{ telematics_health_report.lat._value }},{{ telematics_health_report.long._value }}" target="_blank">View Map</a></font></u> ;;
#  }

  dimension: is_ble_node {
    label: "BLE Node (True/False)"
    type: string
    sql: ${TABLE}."IS_BLE_NODE" ;;
  }

  dimension: unplugged {
    type: string
    sql: ${TABLE}."UNPLUGGED" ;;
  }

  dimension: street {
    type: string
    sql: ${TABLE}."STREET" ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}."CITY" ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  dimension: zip_code {
    type: string
    sql: ${TABLE}."ZIP_CODE" ;;
  }

  dimension: location {
    type: string
    sql: ${TABLE}."LOCATION" ;;
  }

  dimension: last_checkin_timestamp {
    label: "Last Check In Time"
    type: date_time
    sql: ${TABLE}."LAST_CHECKIN_TIMESTAMP" ;;
    html:
      {{ rendered_value | date: "%b %d, %Y %r"  }} {{ _user_attributes['user_timezone_label'] }} ;;
  }

  dimension: asset_battery_voltage {
    type: number
    sql: ${TABLE}."ASSET_BATTERY_VOLTAGE" ;;
  }

  dimension: start_stale_gps_fix_timestamp {
    label: "Stale GPS Timestamp"
    type: date_time
    sql: ${TABLE}."START_STALE_GPS_FIX_TIMESTAMP" ;;
    html:
      {{ rendered_value | date: "%b %d, %Y %r"  }} {{ _user_attributes['user_timezone_label'] }} ;;
  }

  dimension: last_location_timestamp {
    label: "Last Location Time"
    type: date_time
    sql: ${TABLE}."LAST_LOCATION_TIMESTAMP";;
    html:
      {{ rendered_value | date: "%b %d, %Y %r"  }} {{ _user_attributes['user_timezone_label'] }} ;;
  }

  dimension: latest_gps_fix_timestamp {
    label: "Latest GPS Fix Time"
    type: date_time
    sql: ${TABLE}."LATEST_GPS_FIX_TIMESTAMP" ;;
    html:
      {{ rendered_value | date: "%b %d, %Y %r"  }} {{ _user_attributes['user_timezone_label'] }} ;;
  }

  dimension: latest_satellites {
    type: number
    sql: ${TABLE}."LATEST_SATELLITES" ;;
  }

  dimension: rssi {
    label: "Cell Connection (dBm)"
    type: number
    sql: ${TABLE}."RSSI" ;;
  }

  dimension: rssi_timestamp {
    label: "RSSI Time"
    type: date_time
    sql: ${TABLE}."RSSI_TIMESTAMP" ;;
    html:
      {{ rendered_value | date: "%b %d, %Y %r"  }} {{ _user_attributes['user_timezone_label'] }} ;;
  }

  dimension: hours {
    type: number
    sql: ${TABLE}."HOURS" ;;
  }

  dimension: last_address {
    type: string
    sql: ${TABLE}."LAST_ADDRESS";;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/assets/all/asset/{{ telematics_health_report.asset_id }}" target="_blank">
    {{value}};;
  }

  dimension: lat {
    type: string
    sql: ${TABLE}."LAT" ;;
  }

  dimension: long {
    type: string
    sql: ${TABLE}."LONG" ;;
  }

  dimension: inventory_branch {
    label: "Inventory Branch"
    sql: ${TABLE}."INVENTORY_BRANCH" ;;
  }

  dimension: serial_vin {
    label: "Serial/VIN"
    type: string
    sql: ${TABLE}."SERIAL_VIN" ;;
  }

  # dimension: dead_battery {
  #   type: string
  #   sql: ${TABLE}."DEAD_BATTERY" ;;
  #   html:  {% if value == 'No' %}
  #   <p style="color: white; background-color: #00CB86; font-size:100%; text-align:center">{{ rendered_value }}</p>
  #   {% elsif value == 'Yes' %}
  #   <p style="color: white; background-color: #DA344D; font-size:100%; text-align:center">{{ rendered_value }}</p>
  #   {% endif %} ;;
  # }

  dimension: tracker_connection_status {
    type: string
    sql: case
          when ${tracker_id} is null then 'No Tracker'
          when ${asset_status} = 'Inactive' then 'Inactive'
          when ${rssi} <= -81 and ${rssi} > -90 then 'Poor (-81/-90)'
          when ${rssi} <= -90 then 'Unstable (-91+)'
          when ${rssi} is null then 'No Recent Status'
          else 'Healthy (0/-80)' end  ;;
  }

  dimension: asset_health_status {
    type: string
    sql: ${TABLE}."ASSET_HEALTH_STATUS" ;;
    html:  {% if value == 'Healthy' %}
    <p style="color: white; background-color: #00CB86; font-size:100%; min-width: 80px; text-align:center; border-radius: 20px; height: 18px">{{ rendered_value }}</p>
    {% elsif value == 'Inactive' %}
    <p style="color: white; background-color: #336CA4; font-size:100%; min-width: 80px; text-align:center; border-radius: 20px; height: 18px">{{ rendered_value }}</p>
    {% elsif value == 'Unstable' %}
    <p style="color: white; background-color: #94fab6; font-size:100%; min-width: 80px; text-align:center; border-radius: 20px; height: 18px">{{ rendered_value }}</p>
    {% elsif value == 'Needs Attention' %}
    <p style="color: white; background-color: #DA344D; font-size:100%; min-width: 100px; text-align:center; border-radius: 20px; height: 18px">{{ rendered_value }}</p>
    {% elsif value == 'No Tracker' %}
    <p style="color: black; font-size:100%; text-align:center">{{ rendered_value }}</p>
    {% endif %} ;;
  }


  dimension: tracker_asset_status {
    type: string
    sql: case
          when ${tracker_id} is null then 'No Tracker'
          when ${unplugged} = 'true' then 'Unplugged Tracker'
          end  ;;
  }

  dimension: tracker {
    type: string
    sql: concat(coalesce(${tracker_vendor}, ''), ' ', coalesce(${tracker_type}, '')) ;;
  }

  dimension: asset_status {
    label: "Possible Issue"
    type: string
    sql: ${TABLE}."ASSET_STATUS"  ;;
    # html:
    # {% if value == "Drained Battery" %}
    # <font color="black"> 🪫 {{value}}</font>
    # {% elsif value == "Master Cutoff Switch/Tracker Disconnected" %}
    # <font color="black"> 🚫  {{value}}</font>
    # {% elsif value == "Dead Battery" %}
    # <font color="black"> 🔴 {{value}}</font>

    # {% elsif value == "Unknown Error Contact Support" %}
    # <font color="black"> 🚧 {{value}}</font>
    # {% elsif value == "Likely in Low Coverage Area" %}
    # <font color="black"> 📶 {{value}}</font>
    # {% elsif value == "Stale GPS" %}
    # <font color="black"> 🛰{{value}}</font>

    # {% elsif value == "Healthy" %}
    # <font color="black"> 🟢 {{value}}</font>

    # {% elsif value == "Unplugged Tracker" %}
    # <font color="black"> 🔌 {{value}}</font>
    # {% elsif value == "Tracker Not Installed" %}
    # <font color="black"> ✖ {{value}}</font>

    # {% else %}
    # <font color="black">{{value}}</font>
    # {% endif %} ;;

  }

  dimension: date1 {
    label: "Previous Voltage Date"
    type: date
    sql: ${TABLE}."DATE1"  ;;
  }

  dimension: maxvoltage1 {
    label: "Previous Voltage"
    type: string
    sql: ${TABLE}."MAXVOLTAGE1"  ;;
  }

  dimension: name {
    label: "Asset - Serial/VIN"
    type: string
    # sql: case
    #     when ${serial_vin} is null then ${TABLE}."NAME"
    #     else concat(${TABLE}."NAME",' - ',${serial_vin})
    #     end;;
    # html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id._filterable_value }}/status" target="_blank">
    #       {{value}}
    #       ;;
    sql: ${TABLE}."NAME" ;;
    html:
    {% if serial_vin._value == null  %}
    <font color="#0063f3"><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id._filterable_value }}/status" target="_blank"> {{ name._rendered_value }}
    {% else %}
    <font color="#0063f3"><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id._filterable_value }}/status" target="_blank"> {{ name._rendered_value }} - {{serial_vin._rendered_value }}
    {% endif %};;
  }

  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE"  ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE"  ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL"  ;;
  }

  dimension: organization {
    type: string
    sql: ${TABLE}."ORGANIZATION"  ;;
  }

  dimension: groups {
    type: string
    sql: coalesce(${organization}, 'Ungrouped Assets')  ;;
  }

  dimension: asset_class {
    type: string
    sql: coalesce(${TABLE}."ASSET_CLASS",'Unassigned') ;;
  }

  measure: count_all_assets {
    label: "Total Assets"
    type: count
  }

  measure: count {
    label: " Count"
    type: count_distinct
    sql: ${asset_id} ;;
    drill_fields: [asset_health_status, asset_type, tracker_type, inventory_branch, groups, name]
    html: {{rendered_value}} ({{count_percent._rendered_value}}) ;;
  }

  measure: count_percent {
    type: percent_of_total
    sql: ${count} ;;
  }

  measure: asset_count_for_trackers {
    label: "Asset Count for Labels"
    type: count_distinct
    sql: ${asset_id} ;;
    html: <br>{{rendered_value}} ({{count_percent._rendered_value}})</br> ;;
  }

  # Added from on_rent for testing
  dimension: current_date {
    type: date
    sql: current_date() ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }


  }
