view: telematics_health_report {

  derived_table: {

    sql:
    with asset_groups as (
        select distinct a.asset_id, a.company_id, a.year, a.serial_number, a.vin
        from es_warehouse.public.assets a
            left join es_warehouse.public.organization_asset_xref x on x.asset_id = a.asset_id
            join es_warehouse.public.asset_types aty on a.asset_type_id=aty.asset_type_id
    ),
    last_geofence as (
        select distinct
          asset_last_location.asset_id,
          asset_last_location.geofences as name,
          asset_last_location.location as last_location
        from es_warehouse.public.asset_last_location
          join asset_groups ag on asset_last_location.asset_id = ag.asset_id
    ),
    latest_ble as (
    select distinct ble.ble_asset_id, max(ble.message_date) as ble_last_contact
      from es_warehouse.public.ble_message_logs ble
        join asset_groups ag on ag.asset_id = ble.ble_asset_id
        join es_warehouse.public.assets a on a.asset_id = ag.asset_id
        join es_warehouse.public.trackers t on t.tracker_id = a.tracker_id
      group by ble.ble_asset_id
    )
    , latest_tracker_install_date as (
    select distinct ata.asset_id, ata.tracker_id, ata.date_installed
    from es_warehouse.public.asset_tracker_assignments ata join asset_groups ag on ata.asset_id = ag.asset_id
    where ata.date_uninstalled is null
    QUALIFY ROW_NUMBER() OVER (PARTITION BY ata.asset_id ORDER BY ata.asset_id, ata.date_installed desc) = 1
    )
    , is_ble_node as (
    select akv.asset_id, akv.value as is_ble_node
    from es_warehouse.public.asset_status_key_values akv
    join asset_groups ag on ag.asset_id = akv.asset_id
    where akv.name = 'is_ble_node'
    )
    , unplugged as (
    select akv.asset_id, akv.value as unplugged
    from es_warehouse.public.asset_status_key_values akv
    join asset_groups ag on ag.asset_id = akv.asset_id
    where akv.name = 'unplugged'
    )
    , thr as (
    select thr.asset_id,thr.street,thr.city,thr.zip_code --akv.value as street
    from es_warehouse_stage.public.telematics_health_report thr
    join asset_groups ag on ag.asset_id = thr.asset_id
    )
    , state as (
    select b.asset_id, st.abbreviation
    from (
    select akv.asset_id,akv.value as state_id
    from es_warehouse.public.asset_status_key_values akv
    join asset_groups ag on ag.asset_id = akv.asset_id
    where akv.name = 'state_id') b
    left join es_warehouse.public.states st on b.state_id = st.state_id
    )
    , location as (
    select akv.asset_id, try_to_geography(akv.value) as location
    from es_warehouse.public.asset_status_key_values akv
    join asset_groups ag on ag.asset_id = akv.asset_id
    where akv.name = 'location'
    )
    , last_checkin_timestamp as (
    select akv.asset_id, akv.value as last_checkin_timestamp
    from es_warehouse.public.asset_status_key_values akv
    join asset_groups ag on ag.asset_id = akv.asset_id
    where akv.name = 'last_checkin_timestamp'
    )
    , battery_voltage as (
    select akv.asset_id, akv.value as battery_voltage
    from es_warehouse.public.asset_status_key_values akv
    join asset_groups ag on ag.asset_id = akv.asset_id
    where akv.name = 'battery_voltage'
    )
    , start_stale_gps_fix_timestamp as (
    select akv.asset_id, akv.value as start_stale_gps_fix_timestamp
    from es_warehouse.public.asset_status_key_values akv
    join asset_groups ag on ag.asset_id = akv.asset_id
    where akv.name = 'start_stale_gps_fix_timestamp'
    )
    , last_location_timestamp as (
    select akv.asset_id, akv.value as last_location_timestamp
    from es_warehouse.public.asset_status_key_values akv
    join asset_groups ag on ag.asset_id = akv.asset_id
    where akv.name = 'last_location_timestamp'
    )
    , rssi as (
    select akv.asset_id, akv.value as rssi, akv.value_timestamp as rssi_timestamp
    from es_warehouse.public.asset_status_key_values akv
    join asset_groups ag on ag.asset_id = akv.asset_id
    where akv.name = 'rssi'
    )
    , hours as (
    select akv.asset_id, akv.value as hours
    from es_warehouse.public.asset_status_key_values akv
    join asset_groups ag on ag.asset_id = akv.asset_id
    where akv.name = 'hours'
    )
    , base as (
    select a.asset_id, initcap(aty.name) as asset_type, a.custom_name, a.make, a.model, a.year,
          case when t.tracker_id is null then 1
               when up.unplugged = true then 2
              else 4 end as tracker_state_num,
          case
               when t.tracker_id is null then 'Untracked'
              else 'Working' end as tracker_state,
              case when up.unplugged = true then '/Unplugged'
              else '' end as unplugged_status,
          case
               when lg.name is not null then concat('Geofence: ', lg.name)
               else
                  case when thr.street is not null
                          then concat(thr.street, ', ', coalesce(thr.city,''), ', ', state.abbreviation,' ', coalesce(thr.zip_code,''))
                       when loc.location is not null
                          then concat(to_char(ST_YMIN(loc.location)), ', ', to_char(ST_XMIN(loc.location)))
                       else 'N/A' end end as location,
        case when m2.name = 'Main Branch' then -1 else a.inventory_branch_id end as inventory_branch_id,
          m2.name as inventory_branch,
          case
        when coalesce(lct.last_checkin_timestamp, tsc.latest_report_timestamp) >= lt.date_installed then convert_timezone('America/Chicago', coalesce(lct.last_checkin_timestamp, tsc.latest_report_timestamp) )
               else null end as last_checkin_timestamp,
          case
          when coalesce(lct.last_checkin_timestamp, tsc.latest_report_timestamp) <= lt.date_installed
          then
          'No Message Since Tracker Assigned'
          else
          null
          end
          as no_tracker_message_since_assigned,
          case
          when tv.name is null and tty.name is null then  'N/A'
          when tv.name is not null and tty.name is null then tv.name
              else concat(tv.name, ' ', tty.name)
              end as tracker,
          case when ibn.is_ble_node = true then 'Yes' else 'No' end as ble,
          t.device_serial as tracker_serial,
          coalesce(tt.firmware_version, tt.obd2_firmware_version, 'Unknown') as tracker_firmware_version,
          k.serial_number as keypad_serial,
          case when c1.field_value = '1' and c1.configuration_eid = '431'
          AND c2.field_value = '1' and c2.configuration_eid = '4d6' then 'ON'
          when c1.field_value = '0' and c1.configuration_eid = '431'
          OR c2.field_value = '0' and c2.configuration_eid = '4d6' then 'OFF'
          else 'N/A' end as BLE_on_off,
          t.tracker_id, t.device_serial,
          bv.battery_voltage as asset_battery_voltage,
          sc.battery_voltage as tracker_battery_voltage,

      case
      when gpsf.start_stale_gps_fix_timestamp = '1970-01-01 00:00:00'::timestamp_ntz and llt.last_location_timestamp <> '1970-01-01 00:00:00'::timestamp_ntz
      then coalesce(convert_timezone('America/Chicago', llt.last_location_timestamp),
      convert_timezone('America/Chicago', sc.latest_gps_fix_timestamp))
      when gpsf.start_stale_gps_fix_timestamp = '1970-01-01 00:00:00'::timestamp_ntz and llt.last_location_timestamp = '1970-01-01 00:00:00'::timestamp_ntz
      then convert_timezone('America/Chicago', sc.latest_gps_fix_timestamp)
      else
      coalesce(convert_timezone('America/Chicago', gpsf.start_stale_gps_fix_timestamp),
      convert_timezone('America/Chicago', llt.last_location_timestamp),
      convert_timezone('America/Chicago', sc.latest_gps_fix_timestamp))
      end as last_gps_contact,
      case
      when gpsf.start_stale_gps_fix_timestamp = '1970-01-01 00:00:00'::timestamp_ntz
      then true else false
      end as tracker_restarted_wo_gps_fix,
      case when gpsf.start_stale_gps_fix_timestamp is null then 'Healthy' else 'Unstable' end as gps_health,
      coalesce(to_char(convert_timezone('America/Chicago', b.ble_last_contact), 'MON-DD-YYYY HH12:MI:SS AM'), 'N/A') as last_ble_contact,
      TRY_CAST(rssi.rssi as integer) as rssi,
      convert_timezone('America/Chicago', rssi.rssi_timestamp) as last_cellular_contact,
      sc.latest_satellites,
      t.phone_number,
      h.hours,
      convert_timezone('America/Chicago', lt.date_installed) as last_tracker_install_date,
      lg.last_location as last_location,
      coalesce(a.serial_number, a.vin) as serial_vin
      from asset_groups ag
      join es_warehouse.public.assets a on a.asset_id = ag.asset_id
      left join latest_ble b on b.ble_asset_id = ag.asset_id
      left join latest_tracker_install_date lt on ag.asset_id = lt.asset_id
      left join trackers t on lt.tracker_id=t.tracker_id
      left join tracker_state_cache sc on sc.tracker_id = t.tracker_id
      left join trackers.trackers tt on tt.device_serial = t.device_serial
      left join trackers.current_morey_device_field_configurations c1 on c1.tracker_id = tt.tracker_id and (c1.configuration_eid = '431')
      left join trackers.current_morey_device_field_configurations c2 on c2.tracker_id = tt.tracker_id and (c2.configuration_eid = '4d6')
      left join TRACKERS.PUBLIC.TRACKER_STATE_CACHE tsc on tsc.tracker_id = tt.tracker_id
      left join tracker_types tty on t.tracker_type_id=tty.tracker_type_id
      left join tracker_vendors tv on coalesce(tty.tracker_vendor_id,t.vendor_id) = tv.tracker_vendor_id
      left join last_geofence lg on ag.asset_id = lg.asset_id
      left join asset_types aty on a.asset_type_id=aty.asset_type_id
      left join markets m2 on a.inventory_branch_id = m2.market_id
      left join keypads k on k.asset_id = ag.asset_id
      left join is_ble_node ibn on ibn.asset_id = ag.asset_id
      left join unplugged up on up.asset_id = ag.asset_id
      left join thr on thr.asset_id = ag.asset_id
      left join state on state.asset_id = ag.asset_id
      left join location loc on loc.asset_id = ag.asset_id
      left join last_checkin_timestamp lct on lct.asset_id = ag.asset_id
      left join battery_voltage bv on bv.asset_id = ag.asset_id
      left join start_stale_gps_fix_timestamp gpsf on gpsf.asset_id = ag.asset_id
      left join last_location_timestamp llt on llt.asset_id = ag.asset_id
      left join rssi on rssi.asset_id = ag.asset_id
      left join hours h on h.asset_id = ag.asset_id
      where a.deleted = false
      ) select
      distinct BLE_on_off,
      b.asset_id, asset_type, custom_name, make, model,
      concat(tracker_state, '',unplugged_status) as tracker_state,  inventory_branch, location,
      last_checkin_timestamp,
      no_tracker_message_since_assigned,
      tracker, ble,
      tracker_serial,
      tracker_firmware_version,
      keypad_serial,
      asset_battery_voltage,
      tracker_battery_voltage,
      last_gps_contact, gps_health,
      tracker_restarted_wo_gps_fix,
      last_ble_contact,
      rssi,
      last_cellular_contact,
      last_location,
      split_part(last_location, ', ', 1) as lat,
      split_part(last_location, ', ', 2) as long,
      phone_number,
      latest_satellites,
      round(coalesce(hours, 0), 2) as hours,
      to_date(last_tracker_install_date) as last_tracker_install_date,
      year,
      serial_vin
      from base b
      ;;
  }

  dimension: primary_key {
    primary_key: yes
    sql: ${asset_id};;
  }

  dimension: BLE_on_off {
    label: "BLE Status (On/Off)"
    type: string
    sql: ${TABLE}."BLE_ON_OFF" ;;
  }

  dimension: ble {
    label: "BLE Node (Y/N)"
    type: string
    sql: ${TABLE}."BLE" ;;
  }

  dimension: asset_id {
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }

  dimension: custom_name {
    label: "Asset"
    type: string
    sql: ltrim(rtrim(${TABLE}."CUSTOM_NAME")) ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: make_model {
    label: "Make/Model"
    type: string
    sql: concat(${make}, ' ', ${model}) ;;
  }

  dimension: location {
    label: "Last Address"
    type: string
    sql: ${TABLE}."LOCATION" ;;
  }

  dimension: lat {
    type: string
    sql: ${TABLE}."LAT" ;;
  }

  dimension: long {
    type: string
    sql: ${TABLE}."LONG" ;;
  }

  dimension: last_location {
    label: "Last Location"
    type: string
    sql: ${TABLE}."LAST_LOCATION" ;;
    html: <font color="#0063f3"><u><a href="https://www.google.com/maps/place/{{ telematics_health_report.lat._value }},{{ telematics_health_report.long._value }}" target="_blank">View Map</a></font></u> ;;
  }

  dimension: inventory_branch {
    type: string
    sql: ${TABLE}."INVENTORY_BRANCH" ;;
  }

  # dimension_group: last_checkin_timestamp {
  #   label: "Last Checkin"
  #   type: time
  #   sql: ${TABLE}."LAST_CHECKIN_TIMESTAMP" ;;
  # }

  # dimension_group: out_of_lock_timestamp {
  #   label: "Out of Lock"
  #   type: time
  #   sql: ${TABLE}."OUT_OF_LOCK_TIMESTAMP" ;;
  # }

  dimension: last_checkin_timestamp {
    label: "Last Checkin Time"
    type: date_time
    sql: ${TABLE}."LAST_CHECKIN_TIMESTAMP" ;;
    html:
      {{ rendered_value | date: "%b %d, %Y %r"  }}  ;;
    # html:
    # {% if value == 'No Message Since Tracker Assigned' %}
    #   {{ rendered_value }}
    # {% else %}
    #   {{ rendered_value | date: "%b %d, %Y %r"  }} {{ _user_attributes['user_timezone_label'] }}
    # {% endif %} ;;
    }

    dimension: no_tracker_message_since_assigned {
      group_label: "No Message Since Tracker Assigned"
      label: " "
      type: string
      sql: ${TABLE}."NO_TRACKER_MESSAGE_SINCE_ASSIGNED" ;;
      html:
          {% if value == 'No Message Since Tracker Assigned' %}
          <b><font color="#DA344D">{{ rendered_value }}</font></b>
          {% else %}
          <font color="black"> " " </font>
          {% endif %} ;;
    }

    # html:
    # {% if value == 'No Message Since Tracker Assigned' %}
    #   {{ rendered_value }}
    # {% else %}
    #   {{ rendered_value | date: "%b %d, %Y %r"  }} {{ _user_attributes['user_timezone_label'] }}
    # {% endif %}

    # dimension: out_of_lock_timestamp {
    #   label: "Out of Lock Time"
    #   type: date_time
    #   sql: ${TABLE}."OUT_OF_LOCK_TIMESTAMP" ;;
    #   html: {{ rendered_value | date: "%b %d, %Y %r"  }} {{ _user_attributes['user_timezone_label'] }};;
    # }

    # dimension: out_of_lock_reason {
    #   label: "Out of Lock Reason"
    #   type: string
    #   # Prettifying this field a bit, as it's a raw list of lowercase strings
    #   # w/ comma separators only (no spaces between values).
    #   sql: replace(
    #         replace(
    #           replace(
    #             replace(
    #               replace(${TABLE}."OUT_OF_LOCK_REASON", 'stale-gps-location', 'Stale GPS Location'),
    #               'low-battery-voltage', 'Low Battery Voltage'),
    #             'poor-cellular-service', 'Poor Cellular Service'),
    #           'unknown', 'Unknown'),
    #         ',', ', ') ;;
    # }

    dimension: tracker {
      type: string
      sql: ${TABLE}."TRACKER" ;;
    }

    dimension: tracker_serial {
      type: string
      sql: ${TABLE}."TRACKER_SERIAL" ;;
    }

    dimension: tracker_firmware_version {
      label: "Firmware Version"
      description: "Currently, we can only guarantee accurate firmware version readings for Morey devices.
      Calamp device firmware versions may be out of date; verify using the Calamp web interface.
      NO other tracker vendors will show a firmware version here, but for ANY vendor, you may verify the current firmware version using that vendor's web interface."
      type: string
      sql: ${TABLE}."TRACKER_FIRMWARE_VERSION" ;;
    }

    dimension: tracker_state {
      type: string
      sql: ${TABLE}."TRACKER_STATE" ;;

      html:

          {% if value == 'Working' %}

                      <p style="color: white; background-color: #00CB86; font-size:100%; text-align:center; border-radius: 20px; height: 18px">{{ rendered_value }}</p>

        {% elsif value == 'Working/Unplugged' %}

        <p style="color: white; background-color: #FFB14E; font-size:100%; text-align:center; border-radius: 20px; height: 18px">{{ rendered_value }}</p>

        {% elsif value == 'Untracked' %}

        <p style="color: black; background-color: #9f66b4; font-size:100%; text-align:center; border-radius: 20px; height: 18px">{{ rendered_value }}</p>

        {% endif %}

        ;;

    }

    #   {% elsif value == 'Out of Lock' %}

    #   <p style="color: white; background-color: #336CA4; font-size:100%; text-align:center; border-radius: 20px; height: 18px">{{ rendered_value }}</p>

    # {% elsif value == 'Out of Lock/Unplugged' %}

    #   <p style="color: black; background-color: #fcdd6a; font-size:100%; text-align:center; border-radius: 20px; height: 18px">{{ rendered_value }}</p>

    dimension: keypad_serial {
      type: string
      sql: ${TABLE}."KEYPAD_SERIAL" ;;
    }

    dimension: asset_battery_voltage {
      type: number
      sql: ${TABLE}."ASSET_BATTERY_VOLTAGE" ;;
    }

    dimension: tracker_battery_voltage {
      type: number
      sql: ${TABLE}."TRACKER_BATTERY_VOLTAGE" ;;
    }

    dimension: last_gps_contact {
      label: "Last GPS Contact"
      type: date_time
      sql: ${TABLE}."LAST_GPS_CONTACT" ;;
      description:
      "Gray cells indicate trackers with limited or incomplete GPS data --
      this may cause the Last GPS Contact time to be stale or inaccurate;
      some may show a Last GPS Contact time of 01-01-1970 or 12-31-1969.
      Refer to Asset Health Status details in Track to confirm."
      html:
          {% if telematics_health_report.tracker_restarted_wo_gps_fix._value == 'Yes' %}

                      <p style="color: black; background-color: #cccccc; font-size:100%; text-align:left">{{ rendered_value | date: "%b %d, %Y %r"  }} {{ _user_attributes['user_timezone_label'] }}</p>

        {% else %}

        {{ rendered_value | date: "%b %d, %Y %r"  }}

        {% endif %} ;;
    }

    dimension: gps_health {
      type: string
      sql: ${TABLE}."GPS_HEALTH" ;;
    }

    dimension: tracker_restarted_wo_gps_fix {
      type: yesno
      label: "Restarted w/o GPS Fix"
      description:
      "If a tracker was restarted and began sending messages _before_ receiving a GPS fix,
      Last GPS Contact would previously show the UNIX epoch timestamp ('1970-01-01 00:00:00 +0000'), converted to local time.
      That column now uses a secondary/fallback data source when this happens, but may be stale or inaccurate in some cases;
      this yes/no column describes whether or not that secondary source is being used for the asset's Last GPS Contact data."
      sql: ${TABLE}."TRACKER_RESTARTED_WO_GPS_FIX" ;;
    }

    dimension: latest_satellites {
      label: "GPS Satellites (#)"
      type: number
      sql: ${TABLE}."LATEST_SATELLITES" ;;
    }

    dimension: last_ble_contact {
      type:  string
      sql: ${TABLE}."LAST_BLE_CONTACT" ;;
      html:
          {% if telematics_health_report.last_ble_contact._value == 'N/A' %}

                    {{ rendered_value }}

        {% else %}

        {{ rendered_value | date: "%b %d, %Y %r"  }}

        {% endif %} ;;

    }

    dimension: rssi {
      label: "Cell Connection (dBm)"
      type: number
      sql: ${TABLE}."RSSI" ;;
    }

    dimension: last_cellular_contact {
      label: "Last Cell Contact"
      type: date_time
      sql: ${TABLE}."LAST_CELLULAR_CONTACT" ;;
      html: {{ rendered_value | date: "%b %d, %Y %r"  }};;
    }

    dimension: phone_number {
      label: "Tracker Phone #"
      type: string
      sql: ${TABLE}."PHONE_NUMBER" ;;
    }

    dimension: hours {
      type: number
      sql: ${TABLE}."HOURS" ;;
    }

    dimension: negative_hours {
      type: yesno
      sql: ${TABLE}."NEGATIVE_HOURS" ;;
    }

    dimension: negative_hours_value {
      type: number
      sql: ${TABLE}."NEGATIVE_HOURS_VALUE" ;;
    }

    dimension: last_tracker_install_date {
      label: "Tracker Install Date"
      type: date
      sql: ${TABLE}."LAST_TRACKER_INSTALL_DATE" ;;
      html: {{ rendered_value | date: "%b %d, %Y" }};;
    }

    dimension: year {
      type: number
      sql: ${TABLE}."YEAR" ;;
      value_format_name:  id
    }

    dimension: serial_vin {
      label: "Serial/VIN"
      type: string
      sql: ${TABLE}."SERIAL_VIN" ;;
    }

    measure: count_all_assets {
      label: "Total Assets"
      type: count
    }

    measure: count_untracked {
      label: "Untracked"
      type: count
      filters: [tracker_state: "Untracked"]
    }

    # measure: count_out_of_lock {
    #   label: "Out of Lock"
    #   type: count
    #   filters: [tracker_state: "Out of Lock"]
    # }

    # measure: count_out_of_lock_unplugged {
    #   label: "Out of Lock/Unplugged"
    #   type: count
    #   filters: [tracker_state: "Out of Lock/Unplugged"]
    # }

    measure: count_working {
      label: "Working"
      type: count
      filters: [tracker_state: "Working"]
    }

    measure: count_working_unplugged {
      label: "Working/Unplugged"
      type: count
      filters: [tracker_state: "Working/Unplugged"]
    }

  }
