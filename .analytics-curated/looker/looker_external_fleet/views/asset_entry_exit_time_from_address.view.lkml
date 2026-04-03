view: asset_entry_exit_time_from_address {
  derived_table: {
    sql: with asset_list_own as (
      select asset_id
      from table(assetlist({{ _user_attributes['user_id'] }}::numeric))
      )
, owned_address_selections as (
select
    distinct(concat(street,', ',city,', ', s.abbreviation)) as address,
    location_lon,
    location_lat,
    1 as flag
from
    tracking_events te
    join states s on s.state_id = te.state_id
    join asset_list_own a on a.asset_id = te.asset_id
where
    location_lon is not null
    and location_lat is not null
    AND te.report_timestamp >= {% date_start date_filter %}
    AND te.report_timestamp <  {% date_end date_filter %}
    AND street is not null
    AND {% condition address_filter %} concat(street,', ',city,', ', s.abbreviation) {% endcondition %}
QUALIFY ROW_NUMBER() OVER (PARTITION BY concat(street,' ',city,', ', s.abbreviation) ORDER BY street) = 1
 )
,rental_asset_list as (
select
asset_id,
start_date,
end_date
from table(rental_asset_list({{ _user_attributes['user_id'] }}::numeric,
convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}),
convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %}),
('{{ _user_attributes['user_timezone'] }}')))
)
, rental_address_selections as (
select
    distinct(concat(street,', ',city,', ', s.abbreviation)) as address,
    location_lon,
    location_lat,
    1 as flag
from
    tracking_events te
    join states s on s.state_id = te.state_id
    join rental_asset_list ral on ral.asset_id = te.asset_id and te.report_timestamp >= ral.start_date AND te.report_timestamp <= ral.end_date
where
    location_lon is not null
    and location_lat is not null
    AND te.report_timestamp >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %})
    AND te.report_timestamp < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})
    AND street is not null
    AND {% condition address_filter %} concat(street,', ',city,', ', s.abbreviation) {% endcondition %}
QUALIFY ROW_NUMBER() OVER (PARTITION BY concat(street,' ',city,', ', s.abbreviation) ORDER BY street) = 1
)
, jobsite_address_selections as (
select
    distinct(concat(street_1,', ',city,', ', s.abbreviation)) as address,
    latitude as location_lat,
    longitude as location_lon,
    1 as flag
from
    locations l
    join states s on s.state_id = l.state_id
where
  l.company_id = {{ _user_attributes['company_id'] }}::numeric
  AND {% condition address_filter %} concat(street_1,', ',city,', ', s.abbreviation) {% endcondition %}
)
, address_selections as (
select * from owned_address_selections
UNION
select * from rental_address_selections
UNION
select * from jobsite_address_selections
)
, address_selection as (
select
  location_lon as user_entered_location_lon,
  location_lat as user_entered_location_lat
from
  address_selections
limit 1
)
, distance_from_address as (
select
    a.asset_id,
    convert_timezone('{{ _user_attributes['user_timezone'] }}', te.report_timestamp) as report_timestamp,
    haversine(location_lat,location_lon, ads.user_entered_location_lat, ads.user_entered_location_lon) as distance
from
    tracking_events te
    join asset_list_own a on a.asset_id = te.asset_id
    join address_selection ads on 1=1
where
    location_lon is not null
    and location_lat is not null
    AND te.report_timestamp >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %})
    AND te.report_timestamp < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})
)
select
    asset_id,
    min(report_timestamp) as earliest_entry_time,
    max(report_timestamp) as latest_exit_time,
    1 as flag
from
    distance_from_address
where
    round(distance,2) <=
    {% if distance._parameter_value == "'1 Miles'" %}
    1.61
    {% elsif distance._parameter_value == "'2 Miles'" %}
    3.22
    {% elsif distance._parameter_value == "'3 Miles'" %}
    4.83
    {% elsif distance._parameter_value == "'4 Miles'" %}
    6.44
    {% elsif distance._parameter_value == "'5 Miles'" %}
    8.05
    {% elsif distance._parameter_value == "'6 Miles'" %}
    9.66
    {% elsif distance._parameter_value == "'7 Miles'" %}
    11.27
    {% elsif distance._parameter_value == "'8 Miles'" %}
    12.87
    {% elsif distance._parameter_value == "'9 Miles'" %}
    14.48
    {% else %}
    16.09
    {% endif %}
    --8.05 --in kilometers...1 mile to 1.60934 kilometers
group by
    asset_id
 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension_group: earliest_entry_time {
    type: time
    # timeframes: [time, date, week, month, raw]
    # sql: CAST(${TABLE}."EARLIEST_ENTRY_TIME" AS TIMESTAMP_NTZ) ;;
    sql: ${TABLE}."EARLIEST_ENTRY_TIME" ;;
  }

  dimension_group: latest_exit_time {
    type: time
    sql: ${TABLE}."LATEST_EXIT_TIME" ;;
  }

  dimension: flag {
    type: string
    sql: ${TABLE}."FLAG" ;;
  }

  filter: address_filter {
    suggest_explore: unique_addresses_with_lat_lon
    suggest_dimension: unique_addresses_with_lat_lon.address
  }

  filter: date_filter {
    type: date_time
  }

  dimension: earliest_entry_time {
    type: date_time
    sql: ${earliest_entry_time_raw} ;;
    # html: {{ value | date: "%b %d, %Y %r  "}} ;;
    html: {{rendered_value | date: "%b %d, %Y %r"}} ;;
  }

  dimension: latest_exit_time {
    type: date_time
    sql: ${latest_exit_time_raw} ;;
    html: {{rendered_value | date: "%b %d, %Y %r"}} ;;
  }

  dimension: test {
    type: date_time
    sql: convert_timezone('America/Chicago',${earliest_entry_time_raw}) ;;
    html: {{ rendered_value | date: "%b %d, %Y %r  "  }};;
  }

  dimension: test_timezone_tz {
    type: date_time
    sql: convert_timezone('UTC',${earliest_entry_time_raw}) ;;
    html: {{ rendered_value | date: "%b %d, %Y %r  "  }};;
  }

  dimension: test_timezone_tz_NY {
    type: date_time
    sql: convert_timezone('America/New_York',${earliest_entry_time_raw}) ;;
    html: {{ rendered_value | date: "%b %d, %Y %r  "  }};;
  }

  dimension: test_2 {
    type: date_time
    sql: ${earliest_entry_time_raw} ;;
    html: {{ rendered_value | date: "%b %d, %Y %r  "  }};;
  }

  dimension: test_3_arun_suggestion {
    type: date_time
    sql: ${earliest_entry_time_raw} ;;
    html: {{ earliest_entry_time_raw._rendered_value | date: "%b %d, %Y %r  " }};;
  }

  dimension: test_raw {
    type: date_raw
    sql: ${earliest_entry_time_raw} ;;
  }

  parameter: distance {
    type: string
    allowed_value: { value: "1 Miles"}
    allowed_value: { value: "2 Miles"}
    allowed_value: { value: "3 Miles"}
    allowed_value: { value: "4 Miles"}
    allowed_value: { value: "5 Miles"}
    allowed_value: { value: "6 Miles"}
    allowed_value: { value: "7 Miles"}
    allowed_value: { value: "8 Miles"}
    allowed_value: { value: "9 Miles"}
    allowed_value: { value: "10 Miles"}
  }

  set: detail {
    fields: [asset_id, earliest_entry_time_time, latest_exit_time_time]
  }
}