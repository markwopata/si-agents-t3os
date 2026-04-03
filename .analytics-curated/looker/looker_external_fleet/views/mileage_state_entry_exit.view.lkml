view: mileage_state_entry_exit {
  derived_table: {
    sql:
    with daily_state_mileage as (
WITH ranked_data AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY asset_id, custom_name, make, model, vin, company_id ORDER BY state_entry_raw) AS overall_row,
        ROW_NUMBER() OVER (PARTITION BY asset_id, custom_name, make, model, vin, company_id, name ORDER BY state_entry_raw) AS state_row
    FROM BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__DAILY_STATE_MILEAGE
    where state_exit_raw between convert_timezone('{{ _user_attributes['user_timezone'] }}', 'UTC', {% date_start date_filter %}::timestamp_ntz)::timestamptz
          and convert_timezone('{{ _user_attributes['user_timezone'] }}', 'UTC', {% date_end date_filter %}::timestamp_ntz)::timestamptz
          and company_id in (select company_id from es_warehouse.public.users where user_id = {{ _user_attributes['user_id'] }}::numeric)
),
grouped_data AS (
    SELECT *,
        (overall_row - state_row) AS group_id
    FROM ranked_data
)
SELECT
    asset_id,
    custom_name,
    make,
    model,
    vin,
    company_id,
    name,
    ifta_reporting,
    MIN_BY(state_entry, state_entry_raw) AS state_entry,
    MAX_BY(state_exit, state_entry_raw) AS state_exit,
    MIN_BY(start_odometer, state_entry_raw) AS start_odometer,
    Max_BY(end_odometer, state_entry_raw) AS end_odometer,
    ROUND(SUM(miles_driven),2) AS miles_driven,
    MIN_BY(start_lat, state_entry_raw) AS start_lat,
    MIN_BY(start_lon, state_entry_raw) AS start_lon,
    MAX_BY(end_lat, state_entry_raw) AS end_lat,
    MAX_BY(end_lon, state_entry_raw) AS end_lon,
    MIN(state_entry_raw) AS state_entry_raw,
    MAX(state_entry_raw) AS state_exit_raw
FROM grouped_data
GROUP BY asset_id, custom_name, make, model, vin, company_id, name, ifta_reporting, group_id
ORDER BY asset_id, company_id
    )
      select fsm.* from daily_state_mileage fsm
      left join public.assets a on a.asset_id = fsm.asset_id
      left join public.asset_settings ast on a.asset_settings_id = ast.asset_settings_id
      left join public.states s on lower(fsm.name) = lower(s.name)
      LEFT JOIN ORGANIZATION_ASSET_XREF OA ON A.ASSET_ID = OA.ASSET_ID
      LEFT JOIN ORGANIZATIONS O ON OA.ORGANIZATION_ID = O.ORGANIZATION_ID
      left join company_dot_numbers d on a.dot_number_id = d.dot_number_id
      where a.asset_type_id = 2
        AND {% condition dot_number_filter %} d.dot_number {% endcondition %}
        AND {% condition groups_filter %} o.name {% endcondition %}
        AND {% condition asset_filter %} a.custom_name {% endcondition %}
        AND   {% if ifta._parameter_value == "'Yes'" %}
              (fsm.ifta_reporting = TRUE)
              {% else %}
              (fsm.ifta_reporting = TRUE OR fsm.ifta_reporting = FALSE OR fsm.ifta_reporting is null)
              {% endif %}
    ;;

  }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: concat(${asset_id},${name}) ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: custom_name {
    label: "Asset"
    type: string
    sql: ${TABLE}."CUSTOM_NAME" ;;
  }

  dimension: end_lat {
    type: number
    sql: ${TABLE}."END_LAT" ;;
  }

  dimension: end_lon {
    type: number
    sql: ${TABLE}."END_LON" ;;
  }

  dimension: end_odometer {
    type: string
    sql: ${TABLE}."END_ODOMETER" ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: make_model {
    type:  string
    sql: concat_ws(' ', coalesce(${make},''),coalesce(${model},'')) ;;
  }


  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: VIN {
    type: string
    sql: ${TABLE}."VIN" ;;
  }

  dimension: miles_driven {
    type: number
    sql: ${TABLE}."MILES_DRIVEN" ;;
  }

  dimension: name {
    label: "State"
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension_group: report_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."REPORT_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: start_lat {
    type: number
    sql: ${TABLE}."START_LAT" ;;
  }

  dimension: start_lon {
    type: number
    sql: ${TABLE}."START_LON" ;;
  }

  dimension: start_lat_long {
    label: "Start Location"
    type: string
    sql:  concat_ws(', ', ${start_lat}, ${start_lon}) ;;
    html: <font color="#0063f3"><u><a href="https://www.google.com/maps/place/{{ mileage_state_entry_exit.start_lat._value }},{{ mileage_state_entry_exit.start_lon._value }}" target="_blank">{{ mileage_state_entry_exit.start_lat._value }}, {{ mileage_state_entry_exit.start_lon._value }}</a></font></u> ;;
  }

  dimension: end_lat_long {
    label: "End Location"
    type: string
    sql:  concat_ws(', ', ${end_lat}, ${end_lon}) ;;
    html: <font color="#0063f3"><u><a href="https://www.google.com/maps/place/{{ mileage_state_entry_exit.end_lat._value }},{{ mileage_state_entry_exit.end_lon._value }}" target="_blank">{{ mileage_state_entry_exit.end_lat._value }}, {{ mileage_state_entry_exit.end_lon._value }}</a></font></u> ;;
  }

  dimension: start_odometer {
    type: string
    sql: ${TABLE}."START_ODOMETER" ;;
  }

  dimension: state_entry {
    label: "State Entry Timestamp Format"
    sql:TO_TIMESTAMP_TZ(${TABLE}."STATE_ENTRY", 'mon-dd-yyyy HH12:mi:ss AM');;
  }

  dimension: state_entry_formatted {
    type: date_time
    label: "State Entry"
    sql: ${state_entry};;
    html: {{ rendered_value | date: "%b %d, %Y %r"  }} {{ _user_attributes['user_timezone_label'] }};;
  }

  dimension: state_exit {
    label: "State Exit Timestamp Format"
    sql: TO_TIMESTAMP_TZ(${TABLE}."STATE_EXIT", 'mon-dd-yyyy HH12:mi:ss AM') ;;
  }

  dimension: state_exit_formatted {
    type: date_time
    label: "State Exit"
    sql: ${state_exit};;
    html: {{ rendered_value | date: "%b %d, %Y %r"  }} {{ _user_attributes['user_timezone_label'] }};;
  }

  filter: date_filter {
    type: date_time
  }

  filter: groups_filter {
    type: string
  }

  filter: dot_number_filter {
    type: string
  }

  filter: asset_filter {
    type: string
  }

  parameter: ifta {
    type: string
    label: "Asset Selection"
    allowed_value: {
      label: "IFTA Assets Only"
      value: "Yes"}
    allowed_value: {
      label: "All Assets (Including IFTA)"
      value: "No"}
  }

  measure: total_miles_driven {
    type: sum
    sql: ${miles_driven} ;;
  }

  measure: count {
    type: count
    drill_fields: [name, custom_name]
  }
}
