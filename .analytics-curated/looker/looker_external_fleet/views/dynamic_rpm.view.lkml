
view: dynamic_rpm {
  derived_table: {
    sql: select *,
    ({% parameter parameter_dynamic_value %}) as dynamic_value
    from
      analytics.t3_analytics.dynamic_rpm_idle ;;
  }

  dimension: primary_key {
    type: string
    sql: concat(${asset_id},${trip_id},${row_num}) ;;
    primary_key: yes
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: trip_id {
    type: string
    sql: ${TABLE}."TRIP_ID" ;;
    # value_format_name: id
  }

  dimension_group: ignition_on_date_time {
    type: time
    sql: ${TABLE}."IGNITION_ON_DATE_TIME" ;;
  }

  dimension_group: ignition_off_date_time {
    type: time
    sql: ${TABLE}."IGNITION_OFF_DATE_TIME" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension_group: value_timestamp {
    type: time
    sql: ${TABLE}."VALUE_TIMESTAMP" ;;
  }

  dimension_group: previous_value_timestamp {
    type: time
    sql: ${TABLE}."PREVIOUS_VALUE_TIMESTAMP" ;;
  }

  dimension: row_num {
    type: number
    sql: ${TABLE}."ROW_NUM" ;;
  }

  dimension: duration {
    type: number
    sql: ${TABLE}."DURATION" ;;
  }

  dimension: value {
    type: number
    sql: ${TABLE}."VALUE" ;;
  }

  dimension: dynamic_value {
    type: number
    sql: ${TABLE}."DYNAMIC_VALUE" ;;
  }

  parameter: parameter_dynamic_value {
    type: number

    allowed_value: {value: "500"}
    allowed_value: {value: "550"}
    allowed_value: {value: "600"}
    allowed_value: {value: "650"}
    allowed_value: {value: "700"}
    allowed_value: {value: "750"}
    allowed_value: {value: "800"}
    allowed_value: {value: "850"}
    allowed_value: {value: "900"}
    allowed_value: {value: "950"}
    allowed_value: {value: "1000"}
    allowed_value: {value: "1050"}
    allowed_value: {value: "1100"}
    allowed_value: {value: "1150"}
    allowed_value: {value: "1200"}
    allowed_value: {value: "1250"}
    allowed_value: {value: "1300"}
    allowed_value: {value: "1350"}
    allowed_value: {value: "1400"}
    allowed_value: {value: "1450"}
    allowed_value: {value: "1500"}
  }

  dimension: rpm_flag {
    type: yesno
    sql: ${value} >= ${dynamic_value} ;;
  }

  measure: total_idle_duration {
    type: sum
    sql: ${duration} ;;
    filters: [rpm_flag: "No"]
  }


  measure: total_non_idle_duration {
    type: sum
    sql: ${duration} ;;
    filters: [rpm_flag: "Yes"]
  }

  measure: trip_duration {
    type: sum
    sql: ${duration} ;;
  }

  measure: rpm_value_reading {
    label: "RPM Value"
    type: sum
    sql: ${value} ;;
  }

  dimension: ignition_on_date {
    group_label: "HTML Formatted Time"
    label: "Ignition On Date Time"
    type: date_time
    sql: ${ignition_on_date_time_raw} ;;
    html: {{ rendered_value | date: "%b %d, %Y %r"  }} {{ _user_attributes['user_timezone_label'] }};;
  }

  dimension: ignition_off_date {
    group_label: "HTML Formatted Time"
    label: "Ignition Off Date Time"
    type: date_time
    sql: ${ignition_off_date_time_raw} ;;
    html: {{ rendered_value | date: "%b %d, %Y %r"  }} {{ _user_attributes['user_timezone_label'] }};;
  }

  dimension: trip_id_cross_filter {
    label: "Trip ID"
    group_label: "Cross Filter Trip ID"
    type: string
    sql: ${trip_id} ;;
    html:
    {{rendered_value}} <br />
    <span style="color: #3c91e6;"> <b>RPM History ➔ </b></span>
    ;;
    description: "Click on a trip ID to view the RPM reading history during the trip."
  }


  set: detail {
    fields: [
        trip_id,
  ignition_on_date_time_time,
  ignition_off_date_time_time,
  asset_id,
  value_timestamp_time,
  previous_value_timestamp_time,
  row_num,
  duration,
  value
    ]
  }
}
