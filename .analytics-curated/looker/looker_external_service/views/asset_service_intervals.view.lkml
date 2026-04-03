view: asset_service_intervals {
  derived_table: {
    sql:
    select
    mr.asset_id,
    mr.custom_name,
    mr.driver,
    mr.make_and_model,
    mr.year,
    mr.vehicle_vin_serial_number,
    mr.company_name,
    mr.service_interval as service_interval_name,
    mr.date_created::date as date_created,
    mr.until_next_service_usage,
    mr.maintenance_group_interval_id,
    mr.maintenance_group_interval_name,
    mr.asset_type,
    mr.class,
    mr.category_name,
    mr.asset_status_value,
    mr.organization_group,
    mr.ownership,
    mr.dynamic_last_location,
    mr.asset_last_location_address,
    mr.asset_last_location_geofences,
    mr.asset_last_location,
    mr.branch,
    mr.time_remaining,
    mr.percentage_remaining,
    mr.utilization_remaining,
    mr.work_order_id,
    mr.percentage_remaining_buckets,
    ai.license_plate_number,
    ai.license_plate_state
    from business_intelligence.triage.stg_t3__maintenance_report mr
    left join business_intelligence.triage.stg_t3__asset_info ai on ai.asset_id = mr.asset_id
        ;;
  }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: concat(${asset_id},${maintenance_group_interval_id},${date_created_time}) ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: license_plate_number {
    type: string
    sql: ${TABLE}."LICENSE_PLATE_NUMBER" ;;
  }

  dimension: license_plate_state {
    type: string
    sql: ${TABLE}."LICENSE_PLATE_STATE" ;;
  }

  dimension: custom_name {
    type: string
    sql: ${TABLE}."CUSTOM_NAME" ;;
  }

  dimension: make_and_model {
    type: string
    sql: ${TABLE}."MAKE_AND_MODEL" ;;
  }

  dimension: year {
    type: string
    sql: ${TABLE}."YEAR" ;;
  }

  dimension: vehicle_vin_serial_number {
    type: string
    label: "Serial Num/VIN"
    sql: ${TABLE}."VEHICLE_VIN_SERIAL_NUMBER" ;;
  }

  dimension: branch {
    type: string
    sql: ${TABLE}."BRANCH" ;;
  }

  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }

  dimension: class {
    type: string
    sql: ${TABLE}."CLASS" ;;
  }

  dimension: category {
    label: "Cateogry"
    type: string
    sql: ${TABLE}."CATEGORY_NAME" ;;
  }

  dimension: asset_status_value {
    type: string
    label: "Asset Inventory Status"
    sql: ${TABLE}."ASSET_STATUS_VALUE" ;;
  }

  dimension: asset_last_location{
    type: string
    sql: ${TABLE}."ASSET_LAST_LOCATION" ;;
  }

  dimension: asset_last_location_geofences{
    type: string
    label: "Geofences"
    sql: ${TABLE}."ASSET_LAST_LOCATION_GEOFENCES" ;;
  }

  dimension: asset_last_location_address {
    type: string
    label: "Address"
    sql: ${TABLE}."ASSET_LAST_LOCATION_ADDRESS" ;;
  }

  dimension: service_interval_id {
    type: number
    sql: ${TABLE}."SERVICE_INTERVAL_ID" ;;
  }

  dimension: maintenance_group_interval_id {
    type: number
    sql: ${TABLE}."MAINTENANCE_GROUP_INTERVAL_ID" ;;
  }

  dimension: maintenance_group_interval_name {
    type: string
    sql: ${TABLE}."MAINTENANCE_GROUP_INTERVAL_NAME" ;;
  }

  dimension: maintenance_group_id {
    type: number
    sql: ${TABLE}."MAINTENANCE_GROUP_ID" ;;
  }

  dimension: usage_interval_id {
    type: number
    sql: ${TABLE}."USAGE_INTERVAL_ID" ;;
  }

  dimension: time_interval_id {
    type: number
    sql: ${TABLE}."TIME_INTERVAL_ID" ;;
  }

  dimension: hours {
    type: number
    sql: ${TABLE}."HOURS" ;;
  }

  dimension: odometer {
    type: number
    sql: ${TABLE}."ODOMETER" ;;
  }

  dimension_group: date_created {
    type: time
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: service_interval_name {
    type: string
    sql: ${TABLE}."SERVICE_INTERVAL_NAME" ;;
  }

  dimension: time_unit_id {
    type: number
    sql: ${TABLE}."TIME_UNIT_ID" ;;
  }

  dimension: time_value {
    type: number
    sql: ${TABLE}."TIME_VALUE" ;;
  }

  dimension: usage_unit_id {
    type: number
    sql: ${TABLE}."USAGE_UNIT_ID" ;;
  }

  dimension: usage_value {
    type: number
    sql: ${TABLE}."USAGE_VALUE" ;;
  }

  dimension: service_record_id {
    type: number
    sql: ${TABLE}."SERVICE_RECORD_ID" ;;
  }

  dimension: last_service_usage_value {
    type: number
    sql: ${TABLE}."LAST_SERVICE_USAGE_VALUE" ;;
  }

  dimension: next_service_usage_value {
    type: number
    sql: ${TABLE}."NEXT_SERVICE_USAGE_VALUE" ;;
  }

  dimension: current_usage_value {
    type: number
    sql: ${TABLE}."CURRENT_USAGE_VALUE" ;;
  }

  dimension: until_next_service_usage {
    type: number
    sql: ${TABLE}."UNTIL_NEXT_SERVICE_USAGE" ;;
  }

  dimension: usage_percentage_remaining {
    type: number
    sql: ROUND(${TABLE}."USAGE_PERCENTAGE_REMAINING",2) ;;
    value_format_name: percent_0
  }

  dimension: usage_percentage {
    type: number
    sql: ROUND(${TABLE}."USAGE_PERCENTAGE",2) ;;
  }

  dimension: last_service_time_value {
    type: number
    sql: ${TABLE}."LAST_SERVICE_TIME_VALUE" ;;
  }

  dimension: next_service_time_value {
    type: number
    sql: ${TABLE}."NEXT_SERVICE_TIME_VALUE" ;;
  }

  dimension_group: next_service_time_value_corrected {
    type: time
    sql: ${TABLE}."NEXT_SERVICE_TIME_VALUE_CORRECTED" ;;
  }

  dimension: current_time_value {
    type: number
    sql: ${TABLE}."CURRENT_TIME_VALUE" ;;
  }

  dimension_group: time_value_corrected {
    type: time
    sql: ${TABLE}."TIME_VALUE_CORRECTED" ;;
  }

  dimension: service_time_remaining_in_weeks {
    type: number
    sql: ${TABLE}."SERVICE_TIME_REMAINING_IN_WEEKS" ;;
  }

  dimension_group: date_completed {
    type: time
    sql: ${TABLE}."DATE_COMPLETED" ;;
  }

  dimension: _next_service_time_value {
    type: number
    sql: ${TABLE}."_NEXT_SERVICE_TIME_VALUE" ;;
  }

  dimension: _last_service_time_value {
    type: number
    sql: ${TABLE}."_LAST_SERVICE_TIME_VALUE" ;;
  }

  dimension: _current_time_value {
    type: number
    sql: ${TABLE}."_CURRENT_TIME_VALUE" ;;
  }

  dimension: until_next_service_time {
    type: number
    sql: ${TABLE}."UNTIL_NEXT_SERVICE_TIME" ;;
  }

  dimension: time_percentage_remaining {
    type: number
    sql: ROUND(${TABLE}."TIME_PERCENTAGE_REMAINING",2) ;;
    value_format_name: percent_0
  }

  dimension: time_percentage {
    type: number
    sql: ROUND(${TABLE}."TIME_PERCENTAGE",2) ;;
  }

  dimension: work_order_originator_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ORIGINATOR_ID" ;;
  }

  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
    value_format_name: id
  }

  dimension: warn_exceeded {
    type: string
    sql: ${TABLE}."WARN_EXCEEDED" ;;
  }

  dimension: trigger_exceeded {
    type: string
    sql: ${TABLE}."TRIGGER_EXCEEDED" ;;
  }

  measure: service_overdue {
    type: count_distinct
    filters: [service_time_remaining_in_weeks: "= -1"]
    #sql: CASE WHEN ${service_time_remaining_in_weeks} is not null then 1 end ;;
    drill_fields: [detail*]

  }

  measure: service_due_this_week {
    type: sum
    filters: [service_time_remaining_in_weeks: "= 0"]
    #filters: [usage_percentage_remaining: "<= -0",
    #  time_percentage_remaining: "<= -0"]
    sql: CASE WHEN ${service_time_remaining_in_weeks} is not null then 1 end  ;;
    drill_fields: [detail*]
  }

  measure: service_due_next_four_weeks{
    type: sum
    filters: [service_time_remaining_in_weeks: "= 1"]
    sql: CASE WHEN ${service_time_remaining_in_weeks} is not null then 1 end  ;;
    drill_fields: [detail*]
  }

  measure: service_due_over_five_plus_weeks{
    type: sum
    filters: [service_time_remaining_in_weeks: "= 5"]
    sql: CASE WHEN ${service_time_remaining_in_weeks} is not null then 1 end  ;;
    drill_fields: [detail*]
  }

  measure: service_total_due {
    type: sum
    sql: CASE WHEN ${service_time_remaining_in_weeks} is not null then 1 end  ;;
  }

  measure: service_percent_overdue {
    type: number
    sql: 1.0 * ${service_overdue}/case when ${service_total_due} = 0 then null else ${service_total_due} end ;;
    value_format_name: percent_1
    drill_fields: [detail*]
  }

  measure: service_percent_this_week {
    type: number
    sql: 1.0 * ${service_due_this_week}/case when ${service_total_due} = 0 then null else ${service_total_due} end ;;
    value_format_name: percent_1
    drill_fields: [detail*]
  }

  measure: service_percent_next_four_weeks {
    type: number
    sql: 1.0 * ${service_due_next_four_weeks}/case when ${service_total_due} = 0 then null else ${service_total_due} end ;;
    value_format_name: percent_1
    drill_fields: [detail*]
  }

  measure: service_percent_five_plus_weeks {
    type: number
    sql: 1.0 * ${service_due_over_five_plus_weeks}/case when ${service_total_due} = 0 then null else ${service_total_due} end ;;
    value_format_name: percent_1
    drill_fields: [detail*]
  }

  dimension: ansi_status {
    type: string
    sql: case when ${service_time_remaining_in_weeks} = -1 then 'Overdue'
          when ${service_time_remaining_in_weeks} = 0 then 'Due This Week'
          when ${service_time_remaining_in_weeks} = 1 and ${service_time_remaining_in_weeks} <= 4 then 'Due In Next Four Weeks'
          when ${service_time_remaining_in_weeks} = 5 then 'Due In Five Plus Weeks'
          end;;
  }

  dimension: current_date {
    type: date
    sql: current_date() ;;
  }

  dimension: asset_linked_to_track_details {
    group_label: "Link to T3 History Page"
    label: "Asset"
    type: string
    sql: ${custom_name};;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id._filterable_value }}/history?selectedDate={{ current_date._filterable_value }}" target="_blank">{{value}}</a></font?</u>;;
  }

  set: detail {
    fields: [
      asset_id,
      market_region_xwalk.market_name,
      asset_statuses.asset_inventory_status,
      time_percentage,
      service_time_remaining_in_weeks
    ]
  }

  dimension: usage_buckets {
    type: string
    sql: case when ${usage_percentage} >= 1.0 OR ${time_percentage} >= 1.0 then 'Overdue'
          when (${usage_percentage} < 1.0 AND ${usage_percentage} >= .90) OR (${time_percentage} < 1.0 AND ${time_percentage} >= .90) then '90-99% Service Interval'
          when (${usage_percentage} < .90 AND ${usage_percentage} >= .80) OR (${time_percentage} < .90 AND ${time_percentage} >= .80) then '80-89% Service Interval'
          when ${usage_percentage} < .80 OR ${time_percentage} < .80 then '0-79% Service Interval'
          end;;
  }

  measure: service_interval_overdue {
    type: count
    filters: [usage_buckets: "Overdue"]
    # sql: CASE WHEN ${service_time_remaining_in_weeks} is not null then 1 end ;;
    drill_fields: [detail_sevice_interval*]
  }

  measure: service_interval_ninety_percent {
    type: count
    filters: [usage_buckets: "90-99% Service Interval"]
    # sql: CASE WHEN ${service_time_remaining_in_weeks} is not null then 1 end  ;;
    drill_fields: [detail_sevice_interval*]
  }

  measure: service_interval_eighty_percent{
    type: count
    filters: [usage_buckets: "80-89% Service Interval"]
    # sql: CASE WHEN ${service_time_remaining_in_weeks} is not null then 1 end  ;;
    drill_fields: [detail_sevice_interval*]
  }

  measure: service_interval_under_eighty_percent{
    type: count
    filters: [usage_buckets: "0-79% Service Interval"]
    # sql: CASE WHEN ${service_time_remaining_in_weeks} is not null then 1 end  ;;
    drill_fields: [detail_sevice_interval*]
  }

  measure: usage_percentage_count {
    type: sum
    sql: CASE WHEN ${usage_percentage} is not null then 1 end  ;;
  }

  measure: service_interval_overdue_percentage {
    type: number
    sql: 1.0 * ${service_interval_overdue}/case when ${usage_percentage_count} = 0 then null else ${usage_percentage_count} end ;;
    value_format_name: percent_1
    drill_fields: [detail_sevice_interval*]
  }

  measure: service_interval_ninety_percent_percentage {
    type: number
    sql: 1.0 * ${service_interval_ninety_percent}/case when ${usage_percentage_count} = 0 then null else ${usage_percentage_count} end ;;
    value_format_name: percent_1
    drill_fields: [detail_sevice_interval*]
  }

  measure: service_interval_eighty_percent_percentage {
    type: number
    sql: 1.0 * ${service_interval_eighty_percent}/case when ${usage_percentage_count} = 0 then null else ${usage_percentage_count} end ;;
    value_format_name: percent_1
    drill_fields: [detail_sevice_interval*]
  }

  measure: service_interval_under_eighty_percent_percentage {
    type: number
    sql: 1.0 * ${service_interval_under_eighty_percent}/case when ${usage_percentage_count} = 0 then null else ${usage_percentage_count} end ;;
    value_format_name: percent_1
    drill_fields: [detail_sevice_interval*]
  }

  measure: count {
    type: count
    drill_fields: [detail_sevice_interval*]
  }

  dimension: overdue_left_flag {
    type: string
    sql: case when ${until_next_service_usage} < 0 then 'overdue' else 'left' end  ;;
  }

  dimension: until_next_serviced_number {
    type: number
    sql: case when ${until_next_service_usage} < 0 then ${until_next_service_usage}*-1 else ${until_next_service_usage} end ;;
    value_format_name: decimal_0
  }

  dimension: remaining_time {
    type: string
    sql: case when ${until_next_service_usage} < 0 then concat(round(${until_next_serviced_number},0),' ',${overdue_left_flag})
      else concat(round(${until_next_service_usage},0),' ',${overdue_left_flag}) end ;;
  }

  dimension: link_to_work_order {
    group_label: "Link to Work Order"
    label: "Work Order ID"
    type: string
    sql: ${work_order_id} ;;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="_blank">{{rendered_value}}</a></font></u> ;;
  }

  dimension: service_interval {
    type: string
    sql: ${TABLE}."SERVICE_INTERVAL_NAME"
      ;;
  }

  dimension: utilization_remaining {
    type: string
    sql: ${TABLE}."UTILIZATION_REMAINING"
      ;;
  }

  dimension: time_remaining {
    type: string
    sql: ${TABLE}."TIME_REMAINING"
      ;;
  }

  dimension: percentage_remaining {
    group_label: "% Remaining"
    type: number
    label: "% Remaining"
    sql: ${TABLE}."PERCENTAGE_REMAINING" ;;
    html: {{ value | round: 0 }}% ;;
  }

  dimension: usage_percentage_used {
    group_label: "% Used"
    type:  number
    label: "% Remaining"
    sql: coalesce(truncate((${usage_percentage}*100)),truncate((${time_percentage}*100))) ;;
    value_format_name: percent_0
    html: {{value}}% ;;
  }

  dimension: percentage_remaining_buckets {
    type: string
    sql: case when ${percentage_remaining} >= 21 then '21-100%'
          when ${percentage_remaining} >= 11 and ${percentage_remaining} < 20 then '11-20%'
          when ${percentage_remaining} > 0 and ${percentage_remaining} <= 10 then '0-10%'
          when ${percentage_remaining} <= 0 then 'Overdue'
          else 'Unknown'
          end;;
  }
  # colors used for buckets
  # B32F37
  # e03b43
  # FFBF00
  # 00A572

  dimension: percentage_remaining_buckets_duplicate {
    type: string
    sql: case when ${percentage_remaining} >= 21 then '21-100%'
          when ${percentage_remaining} >= 11 and ${percentage_remaining} < 20 then '11-20%'
          when ${percentage_remaining} > 0 and ${percentage_remaining} <= 10 then '0-10%'
          when ${percentage_remaining} <= 0 then 'Overdue'
          else 'Unknown'
          end;;
  }

  dimension: percentage_remaining_rank {
    type: string
    sql: case when ${percentage_remaining_buckets} = 'Overdue' then 1
          when ${percentage_remaining_buckets} = '0-10%' then 2
          when ${percentage_remaining_buckets} = '11-20%' then 3
          when ${percentage_remaining_buckets} = '21-100%' then 4
          else 5
          end
          ;;
  }

  measure: percentage_remaining_over_20 {
    type: count
    filters: [percentage_remaining_buckets: "21-100%"]
  }

  measure: percentage_remaining_twenty_percent {
    type: count
    filters: [percentage_remaining_buckets: "11-20%"]
  }

  measure: percentage_remaining_ten_percent{
    type: count
    filters: [percentage_remaining_buckets: "0-10%"]
  }

  measure: percentage_remaining_overdue_percent{
    type: count
    filters: [percentage_remaining_buckets: "Overdue"]
  }

  dimension: cross_filter_text {
    type: string
    sql: 'Cross Filter' ;;
  }

# ANSI inspections are for aerial equipment only
  dimension: is_ANSI {
    type: yesno
    sql:
    UPPER(${maintenance_group_interval_name}) like '%ANSI%';;
  }

  dimension: is_annual {
    type: yesno
    sql: UPPER(${maintenance_group_interval_name}) like '%ANNUAL%' ;;
  }

  # DOT inspections are only for vehicles
  dimension: is_DOT {
    type: yesno
    sql: UPPER(${maintenance_group_interval_name}) like '%DOT %' ;;
  }

  # Everything that's not ANSI or DOT is considered a PM
  dimension: is_PM {
    type: yesno
    sql:
    UPPER(${maintenance_group_interval_name}) not like '%ANSI%' and
    UPPER(${maintenance_group_interval_name}) not like '%ANNUAL%' and
    UPPER(${maintenance_group_interval_name}) not like '%DOT %';;
  }

  dimension: overdue_inspections {
    type: string
    sql: case when ${is_ANSI} = 'Yes' then 'Overdue ANSI'
          when ${is_annual} = 'Yes' then 'Overdue Annual'
          when ${is_DOT} = 'Yes' then 'Overdue DOT'
          when ${is_PM} = 'Yes' then 'Overdue PM'
          else 'Unclassfied'
          end
          ;;
  }

  dimension: last_location {
    type: string
    sql: coalesce(${asset_last_location_geofences},${asset_last_location_address},${asset_last_location}) ;;
  }

  dimension: location_address {
    label: "Location"
    type: string
    sql: ${last_location} ;;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/assets/all/asset/{{ assets.asset_id._value }}/history?selectedDate={{ current_date._value}}" target="_blank">{{value}}</a></font></u> ;;
  }

  parameter: show_last_location_options {
    type: string
    allowed_value: { value: "Default"}
    allowed_value: { value: "Geofence"}
    allowed_value: { value: "Address"}
  }

  dimension: dynamic_last_location {
    label_from_parameter: show_last_location_options
    sql:{% if show_last_location_options._parameter_value == "'Default'" %}
      ${location_address}
    {% elsif show_last_location_options._parameter_value == "'Geofence'" %}
      ${asset_last_location_geofences}
    {% elsif show_last_location_options._parameter_value == "'Address'" %}
      ${asset_last_location_address}
    {% else %}
      NULL
    {% endif %} ;;
  }

  set: detail_sevice_interval {
    fields: [
      link_to_work_order,
      assets.asset_custom_name_to_service_page,
      asset_last_location.address,
      assets.make,
      assets.model,
      markets.name,
      service_interval,
      percentage_remaining
    ]
  }
}
