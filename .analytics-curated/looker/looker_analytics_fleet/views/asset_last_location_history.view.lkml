view: asset_last_location_history {
  derived_table: {
    sql: with asset_list_own as (
        select asset_id
        from table(assetlist({{ _user_attributes['user_id'] }}::numeric))
      )
      ,asset_list_rental as (
        select asset_id,
        case
        when end_date <= {% date_end hourly_asset_usage_date_filter.date_filter %} then end_date
        when {% date_end hourly_asset_usage_date_filter.date_filter %}::date >= current_date then current_timestamp
        else end_date end as end_date
        from table(rental_asset_list({{ _user_attributes['user_id'] }}::numeric, convert_timezone('{{ _user_attributes['company_timezone'] }}', 'UTC', {% date_start hourly_asset_usage_date_filter.date_filter %}::timestamp_ntz), convert_timezone('{{ _user_attributes['company_timezone'] }}', 'UTC', {% date_end hourly_asset_usage_date_filter.date_filter %}::timestamp_ntz), '{{ _user_attributes['company_timezone'] }}'))
      )
      ,rental_max_date as (
      select
        asset_id,
        max(end_date) as last_end_date
      from
        asset_list_rental
      group by
        asset_id
      )
      ,owned_location as (
      select
        alo.asset_id,
        case
        when {% date_end hourly_asset_usage_date_filter.date_filter %}::date >= current_date then coalesce(al.geofences,al.address,al.location)
        else coalesce(hal.geofences,hal.address,hal.location) end as location,
        case
        when {% date_end hourly_asset_usage_date_filter.date_filter %}::date >= current_date then al.last_checkin_timestamp
        else hal.last_checkin_timestamp end as last_checkin_timestamp
      from
        asset_list_own alo
        left join es_warehouse.snapshot.asset_last_location hal on alo.asset_id = hal.asset_id and {% date_end hourly_asset_usage_date_filter.date_filter %}::date = hal.end_date::date
        left join asset_last_location al on alo.asset_id = al.asset_id
      )
      ,rental_location as (
      select
        rmd.asset_id,
        coalesce(coalesce(hal.geofences,hal.address,hal.location),coalesce(al.geofences,al.address,al.location)) as location,
        coalesce(hal.last_checkin_timestamp,al.last_checkin_timestamp) as last_checkin_timestamp
      from
        rental_max_date rmd
        left join es_warehouse.snapshot.asset_last_location hal on rmd.asset_id = hal.asset_id and rmd.last_end_date::date = hal._es_update_timestamp::date
        left join asset_last_location al on al.asset_id = rmd.asset_id
      )
      select
      *
      from
      rental_location
      union
      select
      *
      from
      owned_location
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
    hidden: yes
  }

  dimension: asset_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    hidden: yes
  }

  dimension: location {
    label: "Table Location"
    type: string
    sql: ${TABLE}."LOCATION" ;;
    hidden: yes
  }

  dimension_group: last_checkin_timestamp {
    type: time
    sql: ${TABLE}."LAST_CHECKIN_TIMESTAMP" ;;
    hidden: yes
  }

  dimension: current_date {
    type: date
    sql: current_date() ;;
    hidden: yes
  }

  dimension: last_contact_time_formatted {
    label: "Last Contact"
    sql: convert_timezone(('{{ _user_attributes['company_timezone'] }}'),${last_checkin_timestamp_time}) ;;
    html: {{ rendered_value | date: "%b %d, %Y %r %Z"  }};;
    skip_drill_filter: yes
    group_label: "Metrics Based Off End Date"
    view_label: "Assets"
  }

  dimension: location_address {
    label: "Location"
    type: string
    sql: ${location} ;;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/home/assets/all/asset/{{ assets.asset_id._value }}/history?selectedDate={{ current_date._value}}" target="_blank">{{value}}</a></font></u> ;;
    skip_drill_filter: yes
    group_label: "Metrics Based Off End Date"
    view_label: "Assets"
  }

  set: detail {
    fields: [asset_id, location, last_checkin_timestamp_time]
  }
}
