view: kes_excavating_trips_and_fuel_purchases {
  derived_table: {
    sql: with asset_list_own as (
      select
        alo.asset_id
      from
        table(assetlist({{ _user_attributes['user_id'] }}::numeric)) alo
        join assets a on a.asset_id = alo.asset_id
      where
        {% condition custom_name_filter %} a.custom_name {% endcondition %}
      )
      ,all_trip_ids_for_range as (
      select
         f.value as trip_id
      from
        asset_list_own alo
        join hourly_asset_usage h on
             alo.asset_id = h.asset_id,
             lateral flatten(input => source_metadata:trip_ids) f
      where
          report_range:start_range >= to_varchar({% date_start date_filter %}::timestamptz, 'yyyy-mm-dd hh:mm:ss TZH')
      )
      ,owned_and_rental_assets as ( --Code to combine all asset ids together
      select
        asset_id
      from
        asset_list_own
      )
      , base as (
      SELECT
        t.trip_id,
        a.asset_id,
        to_char(trip_time_seconds::timestamp,'HH24:MI:SS') as trip_length,
        t.start_timestamp,
        start_street,
        start_city,
        coalesce(st1.abbreviation, '') as start_state,
        start_lat,
        start_lon,
        end_timestamp,
        end_street,
        end_city,
        coalesce(st2.abbreviation, '') as end_state,
        end_lat,
        end_lon,
        start_geofence_id,
        end_geofence_id,
        t.trip_distance_miles,
        coalesce(t.end_hours,0) - coalesce(t.start_hours,0) as asset_hours,
        TO_CHAR(coalesce(t.idle_duration,0)::timestamp, 'HH24:MI:SS') as idle_time,
        round(t.start_odometer::numeric,0) as start_odometer,
        case  when (t.end_total_fuel_used_liters - t.start_total_fuel_used_liters) is null then 'N/A'
        when t.end_total_fuel_used_liters = t.start_total_fuel_used_liters  then '<1'
        else (t.end_total_fuel_used_liters - t.start_total_fuel_used_liters)::text
        end as fuel_used,
        coalesce((t.end_total_fuel_used_liters - t.start_total_fuel_used_liters),0) as fuel_used_var,
        start_hours,
        end_hours,
        case when trip_type_id = 2 then TO_CHAR(t.trip_time_seconds::timestamp, 'HH24:MI:SS') else '00:00:00' end as hauling_time,
        case when trip_type_id = 2 then t.trip_distance_miles else 0 end as hauling_distance,
        end_odometer
      from
        all_trip_ids_for_range alt
        join trips T on t.trip_id = alt.trip_id
        JOIN owned_and_rental_assets a on a.asset_id = t.asset_id
        left join states st1 on st1.state_id = T.start_state_id
        left join states st2 on st2.state_id = T.end_state_id
      where
        t.start_timestamp >= {% date_start date_filter %}
        AND t.start_timestamp <= {% date_end date_filter %}
        and t.trip_time_seconds > 12
      )
      select
        b.trip_id,
        b.asset_id,
        a.custom_name as asset,
        start_timestamp,
        end_timestamp,
        trip_length,
        trip_distance_miles,
        end_odometer,
        start_state,
        end_state,
        concat(fp.city,', ',s.abbreviation) as fuel_location,
        fp.gallons_purchased as gallons_received,
        fp.cost_per_gallon as diesel_price,
        case
        when fp.purchase_date between b.start_timestamp::date and b.end_timestamp::date AND UPPER(fp.city) = coalesce(UPPER(b.end_city),UPPER(b.start_city)) then 'Potentially Most Accurate'
        when fp.purchase_date between b.start_timestamp::date and b.end_timestamp::date then 'Lower Confidence Level'
        else ' ' end as fuel_location_confidence
      from
        base b
        left join fuel_purchases fp on fp.asset_id = b.asset_id and fp.purchase_date between b.start_timestamp::date and b.end_timestamp::date --and UPPER(fp.city) = coalesce(UPPER(b.end_city),UPPER(b.start_city))
        left join states s on s.state_id = fp.state_id
        join assets a on a.asset_id = b.asset_id
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: trip_id {
    type: number
    sql: ${TABLE}."TRIP_ID" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset {
    type: string
    sql: ${TABLE}."ASSET" ;;
  }

  dimension_group: start_timestamp {
    type: time
    sql: ${TABLE}."START_TIMESTAMP" ;;
  }

  dimension_group: end_timestamp {
    type: time
    sql: ${TABLE}."END_TIMESTAMP" ;;
  }

  dimension: trip_length {
    type: string
    sql: ${TABLE}."TRIP_LENGTH" ;;
  }

  dimension: trip_distance_miles {
    type: number
    sql: ${TABLE}."TRIP_DISTANCE_MILES" ;;
    html: {{rendered_value}} mi. ;;
  }

  dimension: end_odometer {
    type: number
    sql: ${TABLE}."END_ODOMETER" ;;
    value_format_name: decimal_2
  }

  dimension: start_state {
    type: string
    sql: ${TABLE}."START_STATE" ;;
  }

  dimension: end_state {
    type: string
    sql: ${TABLE}."END_STATE" ;;
  }

  dimension: fuel_location {
    type: string
    sql: ${TABLE}."FUEL_LOCATION" ;;
  }

  dimension: gallons_received {
    type: number
    sql: ${TABLE}."GALLONS_RECEIVED" ;;
    value_format_name: decimal_2

  }

  dimension: diesel_price {
    type: number
    sql: ${TABLE}."DIESEL_PRICE" ;;
    value_format_name: usd
  }

  dimension: fuel_location_confidence {
    type: string
    sql: ${TABLE}."FUEL_LOCATION_CONFIDENCE" ;;
  }

  dimension: start_timestamp {
    group_label: "HTML Passed Date Format" label: "Trip Start Date"
    type:  date_time
    sql: convert_timezone('{{ _user_attributes['user_timezone'] }}',${start_timestamp_raw}) ;;
    html: {{ rendered_value | date: "%b %d, %Y %r"  }} {{ _user_attributes['user_timezone_label'] }};;
    skip_drill_filter: yes
  }

  dimension: end_timestamp {
    group_label: "HTML Passed Date Format" label: "Trip End Date"
    type:  date_time
    sql: convert_timezone('{{ _user_attributes['user_timezone'] }}',${end_timestamp_raw}) ;;
    html: {{ rendered_value | date: "%b %d, %Y %r"  }} {{ _user_attributes['user_timezone_label'] }} ;;
    skip_drill_filter: yes
  }

  filter: date_filter {
    type: date
  }

  filter: custom_name_filter {
    suggest_explore: kes_excavating_trips_and_fuel_purchases
    suggest_dimension: asset
  }


  set: detail {
    fields: [
      trip_id,
      asset_id,
      start_timestamp_time,
      end_timestamp_time,
      trip_length,
      trip_distance_miles,
      end_odometer,
      start_state,
      end_state,
      fuel_location,
      gallons_received,
      diesel_price,
      fuel_location_confidence
    ]
  }
}
