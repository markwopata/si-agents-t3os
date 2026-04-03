view: unique_addresses_with_lat_lon {
  derived_table: {
    sql: with asset_list_own as (
      select asset_id
      --from table(assetlist(27961::numeric))
      from table(assetlist({{ _user_attributes['user_id'] }}::numeric))
      )
, te_own_locations as (
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
    --AND te.report_timestamp >= '2021-10-01'::timestamp_ntz
    --AND te.report_timestamp <  '2021-10-03'::timestamp_ntz
    AND te.report_timestamp >= {% date_start date_filter %}
    AND te.report_timestamp <  {% date_end date_filter %}
    AND street is not null
QUALIFY ROW_NUMBER() OVER (PARTITION BY concat(street,' ',city,', ', s.abbreviation) ORDER BY street) = 1
)
,rental_asset_list as (
select
asset_id,
start_date,
end_date
--from table(rental_asset_list(27961::numeric,
--convert_timezone('America/Chicago','2021-10-01')::timestamp_ntz,
--convert_timezone('America/Chicago','2021-10-03')::timestamp_ntz,
--('America/Chicago')))
from table(rental_asset_list({{ _user_attributes['user_id'] }}::numeric,
convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %}),
convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %}),
('{{ _user_attributes['user_timezone'] }}')))
)
, te_rental_locations as (
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
    --AND te.report_timestamp >= '2021-10-01'::timestamp_ntz
    --AND te.report_timestamp <  '2021-10-03'::timestamp_ntz
    AND te.report_timestamp >= {% date_start date_filter %}
    AND te.report_timestamp <  {% date_end date_filter %}
    AND street is not null
QUALIFY ROW_NUMBER() OVER (PARTITION BY concat(street,' ',city,', ', s.abbreviation) ORDER BY street) = 1
)
, jobsite_locations as (
select
    distinct(concat(street_1,', ',city,', ', s.abbreviation, '(Jobsite)')) as address,
    longitude as location_lon,
    latitude as location_lat,
    1 as flag
from
    locations l
    join states s on s.state_id = l.state_id
where
  --l.company_id = 50::numeric
    l.company_id = {{ _user_attributes['company_id'] }}::numeric
)
, combine_locations as (
select * from te_own_locations
UNION
select * from te_rental_locations
UNION
select * from jobsite_locations
)
select
  distinct(address),
  location_lat,
  location_lon,
  flag
from
  combine_locations
QUALIFY ROW_NUMBER() OVER (PARTITION BY address ORDER BY address) = 1
 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: address {
    type: string
    sql: ${TABLE}."ADDRESS" ;;
  }

  dimension: location_lon {
    type: number
    sql: ${TABLE}."LOCATION_LON" ;;
  }

  dimension: location_lat {
    type: number
    sql: ${TABLE}."LOCATION_LAT" ;;
  }

  dimension: flag {
    type: string
    sql: ${TABLE}."FLAG" ;;
  }

  dimension: map_location {
    type: location
    sql_latitude: ${location_lat} ;;
    sql_longitude: ${location_lon} ;;
  }

  filter: date_filter {
    type: date_time
  }

  set: detail {
    fields: [address, location_lon, location_lat]
  }
}