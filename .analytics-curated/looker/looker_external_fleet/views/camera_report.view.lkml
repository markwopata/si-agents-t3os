view: camera_test {
  view_label: "Camera Report"
  derived_table: {
    sql:
    select --te.trip_id, te.tracking_event_id,
        ti.tracking_incident_id,
        tity.name as incident_type, ti.asset_id,
        convert_timezone('{{ _user_attributes['user_timezone'] }}', cem.start_date_time) as start_date_time,
        convert_timezone('{{ _user_attributes['user_timezone'] }}', cem.end_date_time) as end_date_time,
        --cem.*, sw.*,
        case when cem.clip_id is null then concat('https://sv.smartwitness.co', cem.url)
             else -- owlcam handling
               concat('https://reporting-api.equipmentshare.com/camera-clip/',
                      '{{ _user_attributes['user_id'] }}', '/',
                      '{{ _user_attributes['company_id'] }}', '/',
                      ti.asset_id, '/', cem.clip_id)
            -- concat('http://api.partner.owlcam.com/v1/clip/', cem.clip_id) -- TODO: link to test endpoint
        end as media_link,
        te.location_lat as lat, te.location_lon as lon,
        te.speed as speed,
        concat(lat, ', ', lon) as event_coordinates,
        u.can_access_camera as can_access_camera
    from tracking_events te
      join table(public.assetlist('{{ _user_attributes['user_id']}}'::numeric)) al on al.asset_id = te.asset_id
      join tracking_incidents ti on ti.tracking_event_id = te.tracking_event_id
      join camera_event_medias cem on cem.tracking_incident_id = ti.tracking_incident_id
      join tracking_incident_types tity on tity.tracking_incident_type_id = ti.tracking_incident_type_id
      join users u on {{ _user_attributes['user_id'] }} = u.user_id
        where te.report_timestamp >= convert_timezone('{{ _user_attributes['user_timezone'] }}', 'UTC', {% date_start date_filter %})
            and te.report_timestamp < convert_timezone('{{ _user_attributes['user_timezone'] }}', 'UTC', {% date_end date_filter %})
            and tity.request_video = true
    ;;
  }

  filter: date_filter {
    type: date_time
  }

  dimension: can_access_camera {
    hidden: yes
    type: yesno
    sql: ${TABLE}."CAN_ACCESS_CAMERA" ;;
  }

  dimension: incident_type {
    type: string
    sql: ${TABLE}."INCIDENT_TYPE" ;;
    # html:
    # {% if incident_type._value == 'Aggressive Acceleration'  %}
    # <font color="#00CB86">{{rendered_value }}</font>
    # {% elsif incident_type._value == 'Aggressive Deceleration' %}
    # <font color="#FFB14E">{{rendered_value }}</font>
    # {% elsif incident_type._value == 'Hard Cornering' %}
    # <font color="#336CA4">{{rendered_value }}</font>
    # {% elsif incident_type._value == 'Hard Left' %}
    # <font color="#fcdd6a">{{rendered_value }}</font>
    # {% elsif incident_type._value == 'Hard Right' %}
    # <font color="#9f66b4">{{rendered_value }}</font>
    # {% elsif incident_type._value == 'Impact' %}
    # <font color="#3EBCD2">{{rendered_value }}</font>
    # {% else %}
    # <font color="#000000">{{rendered_value }}</font>
    # {% endif %}
    # ;;
  }

  dimension: incident_type_formatted {
    group_label: "Incident Type Formatted"
    label: "Incident Type"
    type: string
    sql: ${incident_type} ;;
    html:
    {% if incident_type._value == 'Aggressive Acceleration'  %}
    <font color="#00CB86">❯</font> {{rendered_value }}
    {% elsif incident_type._value == 'Aggressive Deceleration' %}
    <font color="#FFB14E">❯</font> {{rendered_value }}
    {% elsif incident_type._value == 'Hard Cornering' %}
    <font color="#336CA4">❯</font> {{rendered_value }}
    {% elsif incident_type._value == 'Hard Left' %}
    <font color="#fcdd6a">❯</font> {{rendered_value }}
    {% elsif incident_type._value == 'Hard Right' %}
    <font color="#9f66b4">❯</font> {{rendered_value }}
    {% elsif incident_type._value == 'Impact' %}
    <font color="#3EBCD2">❯</font> {{rendered_value }}
    {% else %}
    <font color="#000000">❯ {{rendered_value }}</font>
    {% endif %}
    ;;
  }

  dimension: tracking_incident_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."TRACKING_INCIDENT_ID" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID";;
  }

  dimension: start_date_time {
    label: "Start Time"
    type: date_time
    sql: ${TABLE}."START_DATE_TIME" ;;
    html: {{rendered_value | date: "%b %d, %Y %r"}} {{ _user_attributes['user_timezone_label'] }};;
  }

  dimension: end_date_time {
    label: "End Time"
    type: date_time
    sql: ${TABLE}."END_DATE_TIME" ;;
    html: {{rendered_value | date: "%b %d, %Y %r"}} {{ _user_attributes['user_timezone_label'] }};;
  }

  dimension: media_link {
    label: "Camera Media"
    type: string
    sql: ${TABLE}."MEDIA_LINK" ;;
    html:
    {% if can_access_camera._value == 'Yes' %}
    <font color="#0063f3"><u><a href={{rendered_value}} target="_blank">View Media</a></font></u>
    {% else %}
    <a>Permission Denied</a>
    {% endif %}
    ;;
  }

  dimension: lat {
    type: number
    sql: ${TABLE}."LAT" ;;
  }

  dimension: lon {
    type: number
    sql: ${TABLE}."LON" ;;
  }

  dimension: event_coordinates {
    type: string
    sql: ${TABLE}."EVENT_COORDINATES" ;;
  }

  dimension: event_location {
    label: "Location"
    type: string
    sql: ${TABLE}."EVENT_COORDINATES" ;;
    # html: <font color="#0063f3"><u><a href="http://maps.google.com/maps?q={{ lat._value }},{{ lon._value }}" target="_blank">{{ event_location._value }}</a></font></u> ;;
    html: <font color="#0063f3"><u>View on Map</u></font> ;;
  }

  dimension: location {
    label: "Coordinates"
    type: location
    sql_latitude:  ${TABLE}."LAT" ;;
    sql_longitude: ${TABLE}."LON" ;;
  }

  measure: count {
    label: "Events"
    type: count
  }

  measure: count_hard_left {
    label: "Hard Left"
    type: count
    filters: [incident_type: "Hard Left"]
  }

  measure: count_hard_right {
    label: "Hard Right"
    type: count
    filters: [incident_type: "Hard Right"]
  }

  measure: count_hard_cornering {
    label: "Hard Cornering"
    type: count
    filters: [incident_type: "Hard Cornering"]
  }

  measure: count_aggressive_deceleration {
    label: "Aggressive Deceleration"
    type: count
    filters: [incident_type: "Aggressive Deceleration"]
  }

  measure: count_aggressive_acceleration {
    label: "Aggressive Acceleration"
    type: count
    filters: [incident_type: "Aggressive Acceleration"]
  }

  measure: count_impact {
    label: "Impact"
    type: count
    filters: [incident_type: "Impact"]
  }


}
