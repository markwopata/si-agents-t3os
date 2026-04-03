view: fleet_utilization_asset_details_drilldown {
  derived_table: {
    sql: with owned_assets as (
      select alo.asset_id
      from
        table(assetlist({{ _user_attributes['user_id'] }}::numeric)) alo
        join assets a on alo.asset_id = a.asset_id
        join trackers_mapping tm on tm.asset_id = a.asset_id
      where
        tm.asset_id is not null
      )
      , own_asset_odometer as (
      select
        own.asset_id,
        ao.odometer,
        ROW_NUMBER() OVER(partition by own.asset_id ORDER BY ao.date_end desc) odometer_ranking
      from
        owned_assets own
        left join scd.scd_asset_odometer ao on own.asset_id = ao.asset_id AND (case when convert_timezone('UTC', {% date_end asset_utilization_by_day.date_filter %})::date >= current_date then current_flag = 1 when date_end::date = '9999-12-31' and date_start <= convert_timezone('UTC', {% date_start asset_utilization_by_day.date_filter %}) then current_flag = 1 else convert_timezone('UTC', {% date_end asset_utilization_by_day.date_filter %})::date BETWEEN date_start::date AND date_end::date end)
      )
      , own_odometer as (
      select
          asset_id,
          round(odometer, 0) as odometer
      from
          own_asset_odometer
      where
          odometer_ranking = 1
      )
      , own_asset_hours as (
      select
        own.asset_id,
        ah.hours,
        ROW_NUMBER() OVER(partition by own.asset_id ORDER BY ah.date_end desc) hour_ranking
      from
        owned_assets own
        left join scd.scd_asset_hours ah on own.asset_id = ah.asset_id AND (case when convert_timezone('UTC', {% date_end asset_utilization_by_day.date_filter %})::date >= current_date then current_flag = 1 when date_end::date = '9999-12-31' and date_start <= convert_timezone('UTC', {% date_start asset_utilization_by_day.date_filter %}) then current_flag = 1 else convert_timezone('UTC', {% date_end asset_utilization_by_day.date_filter %})::date BETWEEN date_start::date AND date_end::date end)
      )
      , own_hours as (
      select distinct
          asset_id,
          round(hours, 0) as hours
      from
          own_asset_hours
      where
          hour_ranking = 1
      )
      , rental_assets as (
      select alr.asset_id, start_date, end_date
      from
        table(rental_asset_list({{ _user_attributes['user_id'] }}::numeric,
        convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start asset_utilization_by_day.date_filter %}),
        convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end asset_utilization_by_day.date_filter %}),
        '{{ _user_attributes['user_timezone'] }}')) alr
        join assets a on alr.asset_id = a.asset_id
        join trackers_mapping tm on tm.asset_id = a.asset_id
      where
        tm.asset_id is not null
        AND a.company_id <> {{ _user_attributes['company_id'] }}
      )
      , rental_asset_odometer as (
      select
        ra.asset_id,
        ao.odometer,
        ROW_NUMBER() OVER(partition by ra.asset_id ORDER BY ao.date_end desc) odometer_ranking
      from
        rental_assets ra
        left join scd.scd_asset_odometer ao on ra.asset_id = ao.asset_id
        AND ra.start_date <= ao.date_start
        AND ra.end_date <= ao.date_end
      )
      , rental_odometer as (
      select
          asset_id,
          round(odometer, 0) as odometer
      from
          rental_asset_odometer
      where
          odometer_ranking = 1
      )
      , rental_asset_hours as (
      select
        ra.asset_id,
        ah.hours,
        ROW_NUMBER() OVER(partition by ra.asset_id ORDER BY ah.date_end desc) hour_ranking
      from
        rental_assets ra
        left join scd.scd_asset_hours ah on ra.asset_id = ah.asset_id
        AND ra.start_date <= ah.date_start
        AND ra.end_date <= ah.date_end
      )
      , rental_hours as (
      select distinct
          asset_id,
          round(hours, 0) as hours
      from
          rental_asset_hours
      where
          hour_ranking = 1
      )
      select
          oa.asset_id,
          coalesce(oo.odometer,0) as odometer,
          coalesce(oh.hours,0) as hours,
          coalesce(hll.geofences,ll.geofences) as geofence,
          coalesce(hll.address,ll.address) as address,
          coalesce(hll.last_location_timestamp,ll.last_location_timestamp) as last_location_timestamp,
          coalesce(hll.last_checkin_timestamp,ll.last_checkin_timestamp) as last_checkin_timestamp
      from
         owned_assets oa
         left join own_odometer oo on oo.asset_id = oa.asset_id
         left join own_hours oh on oh.asset_id = oa.asset_id
         left join snapshot.asset_last_location hll on hll.asset_id = oa.asset_id AND hll.end_date::date = convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end asset_utilization_by_day.date_filter %})::date
         left join asset_last_location ll on ll.asset_id = oa.asset_id
      UNION
      select
          ra.asset_id,
          coalesce(ro.odometer,0) as odometer,
          coalesce(rh.hours,0) as hours,
          coalesce(hll.geofences,ll.geofences) as geofence,
          coalesce(hll.address,ll.address) as address,
          coalesce(hll.last_location_timestamp,ll.last_location_timestamp) as last_location_timestamp,
          coalesce(hll.last_checkin_timestamp,ll.last_checkin_timestamp) as last_checkin_timestamp
      from
         rental_assets ra
         left join rental_odometer ro on ro.asset_id = ra.asset_id
         left join rental_hours rh on rh.asset_id = ra.asset_id
         left join snapshot.asset_last_location hll on hll.asset_id = ra.asset_id AND ra.end_date <= hll.end_date::date AND ra.start_date >= hll.start_date::date AND hll.end_date::date = convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end asset_utilization_by_day.date_filter %})::date
         left join asset_last_location ll on ll.asset_id = ra.asset_id AND ra.end_date >= current_date()
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

  dimension: odometer {
    type: number
    sql: ${TABLE}."ODOMETER" ;;
  }

  dimension: hours {
    type: number
    sql: ${TABLE}."HOURS" ;;
  }

  dimension: geofence {
    type: string
    sql: ${TABLE}."GEOFENCE" ;;
  }

  dimension: address {
    type: string
    sql: ${TABLE}."ADDRESS" ;;
  }

  dimension_group: last_location_timestamp {
    type: time
    sql: ${TABLE}."LAST_LOCATION_TIMESTAMP" ;;
  }

  dimension_group: last_checkin_timestamp {
    type: time
    sql: ${TABLE}."LAST_CHECKIN_TIMESTAMP" ;;
  }

  dimension: current_date {
    type: date
    sql: current_date() ;;
  }

  dimension: last_location_timestamp_formatted {
    group_label: "HTML Format" label: "Last Location"
    sql: convert_timezone(('{{ _user_attributes['user_timezone'] }}'),${last_checkin_timestamp_time}) ;;
    html: {{ rendered_value | date: "%b %d, %Y %r  "  }} {{ _user_attributes['user_timezone_label'] }};;
    skip_drill_filter: yes
  }

  dimension: last_checkin_timestamp_formatted {
    group_label: "HTML Format" label: "Last Check In"
    sql: convert_timezone(('{{ _user_attributes['user_timezone'] }}'),${last_checkin_timestamp_time}) ;;
    html: {{ rendered_value | date: "%b %d, %Y %r  "  }} {{ _user_attributes['user_timezone_label'] }};;
    skip_drill_filter: yes
  }

  dimension: location_address {
    group_label: "HTML Format"
    label: "Address"
    type: string
    sql: ${address} ;;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id._value }}/history?selectedDate={{ current_date._value}}" target="_blank">{{value}}</a></font></u> ;;
    skip_drill_filter: yes
  }

  dimension: location_geofence {
    group_label: "HTML Format"
    label: "Geofence"
    type: string
    sql: ${geofence} ;;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id._value }}/history?selectedDate={{ current_date._value}}" target="_blank">{{value}}</a></font></u> ;;
    skip_drill_filter: yes
  }

  set: detail {
    fields: [
      asset_id,
      odometer,
      hours,
      geofence,
      address,
      last_location_timestamp_time,
      last_checkin_timestamp_time
    ]
  }
}
