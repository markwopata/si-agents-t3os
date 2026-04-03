view: asset_idle_locations {
  derived_table: {
    sql:
    with rental_asset_list as (
      select distinct cv.asset_id,cv.start_date,cv.end_date,ai.custom_name
      from BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__COMPANY_VALUES cv
      left join BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__ASSET_INFO ai on ai.asset_id = cv.asset_id
      where time_overlaps(
        start_date,
        end_date,
        convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}),
        convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}),
        true
      )
      and rental_company_id = {{ _user_attributes['company_id'] }}::numeric
      and ai.asset_type = 'Vehicle'
    )
    select
        ai.asset_idle_id,
        ai.asset_id,
        convert_timezone('{{ _user_attributes['user_timezone'] }}',ai.start_timestamp) as start_timestamp,
        convert_timezone('{{ _user_attributes['user_timezone'] }}',ai.end_timestamp) as end_timestamp,
        ai.trip_id,
        ai.duration_seconds as duration_seconds,
        ti.speed_location_lon as idle_event_location_lon,
        ti.speed_location_lat as idle_event_location_lat,
        ti.start_address,
        ti.end_address,
        COALESCE(ti.driver_name_new, 'Unassigned Driver') as driver,
        ti.asset_name as custom_name
    from
       BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__ASSET_INFO al
       join es_warehouse.public.asset_idles ai on al.asset_id = ai.asset_id
        join BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__TRACKING_INCIDENTS_TRIAGE ti on ai.asset_idle_id = ti.tracking_incident_id
        where
        ai.date_created between convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %})
        and convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})
        and ai.start_timestamp between convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %})
        and convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})
        AND al.company_id = {{ _user_attributes['company_id'] }}::numeric
        and al.asset_type = 'Vehicle'
      UNION
      select
        ai.asset_idle_id,
        ai.asset_id,
        convert_timezone('{{ _user_attributes['user_timezone'] }}',ai.start_timestamp) as start_timestamp,
        convert_timezone('{{ _user_attributes['user_timezone'] }}',ai.end_timestamp) as end_timestamp,
        ai.trip_id,
        ai.duration_seconds as duration_seconds,
        ti.speed_location_lon as idle_event_location_lon,
        ti.speed_location_lat as idle_event_location_lat,
        ti.start_address,
        ti.end_address,
        COALESCE(ti.driver_name_new, 'Unassigned Driver') as driver,
        ti.asset_name as custom_name
    from
       rental_asset_list ral
       join es_warehouse.public.asset_idles ai on ral.asset_id = ai.asset_id
                  and ai.start_timestamp >= ral.start_date
                  and ai.end_timestamp <= ral.end_date
        join BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__TRACKING_INCIDENTS_TRIAGE ti on ai.asset_idle_id = ti.tracking_incident_id
    where
        ai.date_created between convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %})
        and convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})
        and ai.start_timestamp between convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %})
        and convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})
    ;;
  }

  measure: count {
    label: "Total Idle Events"
    type: count
    drill_fields: [detail*]
  }

  measure: map_count {
    group_label: "Map Counts"
    label: "Total Idle Events"
    type: count
    html: {{rendered_value}}
          <p>Trip Start Address:
          <br />{{ start_address._value }}
          </p>
          <p>Trip End Address:
          <br />{{ end_address._value }}
          </p>
          ;;
          # html: {{rendered_value}}
          # <p>Trip Start Street:
          # <br />{{ start_street._value }}
          # </p>
          # <p>Trip Start City:
          # <br />{{ start_city._value }}
          # </p>
          # <p>Trip Start County:
          # <br />{{ start_county._value }}
          # </p>
          # <p>Trip End Street:
          # <br />{{ end_street._value }}
          # </p>
          # <p>Trip End City:
          # <br />{{ end_city._value }}
          # </p>
          # <p>Trip End County:
          # <br />{{ end_county._value }}
          # </p>
          # ;;
    }

    dimension: asset_idle_id {
      primary_key: yes
      type: number
      sql: ${TABLE}."ASSET_IDLE_ID" ;;
    }

    measure: idle_event_count {
      type: count_distinct
      sql: ${asset_idle_id} ;;
    }

    dimension: asset_id {
      type: number
      sql: ${TABLE}."ASSET_ID" ;;
    }

    dimension_group: start_timestamp {
      type: time
      sql: ${TABLE}."START_TIMESTAMP" ;;
    }

    dimension_group: end_timestamp {
      type: time
      sql: ${TABLE}."END_TIMESTAMP" ;;
    }

    dimension: trip_id {
      type: number
      sql: ${TABLE}."TRIP_ID" ;;
    }

    dimension: duration_seconds {
      type: number
      sql: ${TABLE}."DURATION_SECONDS" ;;
    }

    dimension: idle_event_location_lon {
      type: number
      sql: ${TABLE}."IDLE_EVENT_LOCATION_LON" ;;
    }

    dimension: idle_event_location_lat {
      type: number
      sql: ${TABLE}."IDLE_EVENT_LOCATION_LAT" ;;
    }

    dimension: start_address {
      type: string
      sql: ${TABLE}."START_ADDRESS" ;;
    }

    dimension: end_address {
      type: string
      sql: ${TABLE}."END_ADDRESS" ;;
    }

    # dimension: end_street {
    #   type: string
    #   sql: ${TABLE}."END_STREET" ;;
    # }

    # dimension: end_county {
    #   type: string
    #   sql: ${TABLE}."END_COUNTY" ;;
    # }

    # dimension: end_city {
    #   type: string
    #   sql: ${TABLE}."END_CITY" ;;
    # }

    # dimension: start_street {
    #   type: string
    #   sql: ${TABLE}."START_STREET" ;;
    # }

    # dimension: start_county {
    #   type: string
    #   sql: ${TABLE}."START_COUNTY" ;;
    # }

    # dimension: start_city {
    #   type: string
    #   sql: ${TABLE}."START_CITY" ;;
    # }

    dimension: mapping_idle_event {
      label: "Idle Event Location"
      type: location
      sql_latitude:${idle_event_location_lat} ;;
      sql_longitude:${idle_event_location_lon} ;;
    }

    dimension: start_day{
      group_label: "Start Date Timestamp" label: "Start Day"
      type: date
      sql: ${start_timestamp_raw} ;;
      html: {{ rendered_value | date: "%b %d, %Y" }} ;;
    }

    dimension: start_time_formatted {
      group_label: "Start Date Timestamp" label: "Start Date"
      type: date_time
      sql: ${start_timestamp_raw} ;;
      html: {{ rendered_value | date: "%b %d, %Y %r" }} {{ _user_attributes['user_timezone_label'] }};;
    }

    dimension: end_time_formatted {
      group_label: "End Date Timestamp" label: "End Date"
      type: date_time
      sql: ${end_timestamp_raw} ;;
      html: {{ rendered_value | date: "%b %d, %Y %r" }} {{ _user_attributes['user_timezone_label'] }};;
    }

    measure: total_idle_duration_seconds {
      type: sum
      sql: ${duration_seconds} ;;
    }

    measure: idle_time {
      type: number
      # sql: case when ${duration_seconds} >= 60 then ${duration_seconds}/60 else ${duration_seconds} end ;;
      sql: ${total_idle_duration_seconds}/60 ;;
      html: {{ rendered_value }} mins ;;
      # html:
      # {% if duration_seconds._value >= 60 %}
      # {{ rendered_value }} mins
      # {% else %}
      # {{rendered_value}} secs
      # {% endif %};;
      value_format_name: decimal_2
      description: "This column is rounded to the nearest minute"
    }

    dimension: asset_idle_id_cross_filter {
      label: "Asset Idle Event ID"
      group_label: "Cross Filter Idle ID"
      type: number
      sql: ${asset_idle_id} ;;
      html: View Event Location ➔ ;;
      description: "Click a row below to view a certain idle event on the map"
    }

    # parameter: driver_by {
    #   type: string
    #   allowed_value: { value: "Driver Assignment"}
    #   allowed_value: { value: "Legacy Assignment"}
    # }

    parameter: time_bucket_size {
      type: number
      allowed_value: { value: "1"
        label: "1 min."}
      allowed_value: { value: "2"
        label: "2 mins."}
      allowed_value: { value: "3"
        label: "3 mins."}
      allowed_value: { value: "4"
        label: "4 mins."}
      allowed_value: { value: "5"
        label: "5 mins."}
      allowed_value: { value: "6"
        label: "6 mins."}
      allowed_value: { value: "7"
        label: "7 mins."}
      allowed_value: { value: "8"
        label: "8 mins."}
      allowed_value: { value: "9"
        label: "9 mins."}
      allowed_value: { value: "10"
        label: "10 mins."}
      allowed_value: { value: "11"
        label: "11 mins."}
      allowed_value: { value: "12"
        label: "12 mins."}
      allowed_value: { value: "13"
        label: "13 mins."}
      allowed_value: { value: "14"
        label: "14 mins."}
      allowed_value: { value: "15"
        label: "15 mins."}
      allowed_value: { value: "16"
        label: "16 mins."}
      allowed_value: { value: "17"
        label: "17 mins."}
      allowed_value: { value: "18"
        label: "18 mins."}
      allowed_value: { value: "19"
        label: "19 mins."}
      allowed_value: { value: "20"
        label: "20 mins."}
      allowed_value: { value: "21"
        label: "21 mins."}
      allowed_value: { value: "22"
        label: "22 mins."}
      allowed_value: { value: "23"
        label: "23 mins."}
      allowed_value: { value: "24"
        label: "24 mins."}
      allowed_value: { value: "25"
        label: "25 mins."}
      allowed_value: { value: "26"
        label: "26 mins."}
      allowed_value: { value: "27"
        label: "27 mins."}
      allowed_value: { value: "28"
        label: "28 mins."}
      allowed_value: { value: "29"
        label: "29 mins."}
      allowed_value: { value: "30"
        label: "30 mins."}
    }

    dimension: dynamic_time_tier {
      label: "Idle Bucket Size"
      type: number
      sql: TRUNCATE((${duration_seconds}/60) / {% parameter time_bucket_size %}, 0)
        * {% parameter time_bucket_size %} ;;
      html: {{rendered_value}} mins ;;
    }

    dimension: custom_name {
      label: "Asset"
      type: string
      sql: TRIM(${TABLE}."CUSTOM_NAME") ;;
    }

    dimension: driver {
      type: string
      sql: ${TABLE}."DRIVER" ;;
    }

    dimension: asset_custom_name_to_asset_info {
      group_label: "Link to T3"
      label: "Asset"
      type: string
      sql: ${custom_name};;
      html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id._filterable_value }}/status" target="_blank">{{value}}</a></font></u>;;

    }

    filter: date_filter {
      type: date_time
    }

    filter: driver_name_filter {
    }

    measure: total_idle_time {
      type: number
      # sql: case when ${duration_seconds} >= 60 then ${duration_seconds}/60 else ${duration_seconds} end ;;
      # sql: ${duration_seconds}/60 ;;
      sql: ${total_idle_duration_seconds} / 3600 ;;
      # html: {{ rendered_value }} mins ;;
      # html:
      # {% if duration_seconds._value >= 60 %}
      # {{ rendered_value }} mins
      # {% else %}
      # {{rendered_value}} secs
      # {% endif %};;
      html: {{ duration_display._rendered_value }} ;;
      value_format_name: decimal_2
      description: "This column is rounded to the nearest minute"
    }

    measure: duration_display {
      type: string
      sql:
          CASE
          WHEN COALESCE(SUM(${duration_seconds}), 0) >= 3600 THEN
          CONCAT(
          FLOOR(COALESCE(SUM(${duration_seconds}), 0) / 3600), 'h ',
          FLOOR(MOD(COALESCE(SUM(${duration_seconds}), 0), 3600) / 60), 'm'
          )
          WHEN COALESCE(SUM(${duration_seconds}), 0) >= 60 THEN
          CONCAT(
          FLOOR(COALESCE(SUM(${duration_seconds}), 0) / 60), 'm'
          )
          ELSE
          CONCAT(
          COALESCE(SUM(${duration_seconds}), 0), 's'
          )
          END ;;
    }

    set: detail {
      fields: [
        custom_name,
        driver,
        start_timestamp_time,
        end_timestamp_time,
        duration_seconds
      ]
    }
  }
