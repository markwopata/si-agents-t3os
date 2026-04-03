view: current_rentals_asset_usage_last_7_days {
  derived_table: {
    sql: with asset_list_rental as (
      select asset_id, start_date, end_date from table(rental_asset_list({{ _user_attributes['user_id'] }}::numeric, convert_timezone('UTC', '{{ _user_attributes['user_timezone'] }}', DATEADD('day', -6, CURRENT_DATE())::timestamp_ntz), convert_timezone('UTC', '{{ _user_attributes['user_timezone'] }}', DATEADD('day', 7, DATEADD('day', -6, CURRENT_DATE()))::timestamp_ntz), '{{ _user_attributes['user_timezone'] }}'))
      )
      --,rental_available_dates as (
      select
          alr.asset_id,
          ea.rental_id,
          round(sum(on_time)/3600,2) as on_time_hours
      from
          asset_list_rental alr
          left join equipment_assignments ea on ea.asset_id = alr.asset_id
          left join es_warehouse.public.hourly_asset_usage hau on alr.asset_id = hau.asset_id and hau.report_range:start_range >= alr.start_date AND hau.report_range:end_range <= alr.end_date
      where
          report_range:start_range >= convert_timezone('UTC', '{{ _user_attributes['user_timezone'] }}', DATEADD('day', -6, CURRENT_DATE())::timestamp_ntz)
          AND report_range:end_range <= convert_timezone('UTC', '{{ _user_attributes['user_timezone'] }}', DATEADD('day', 7, DATEADD('day', -6, CURRENT_DATE()))::timestamp_ntz)
      group by
          alr.asset_id,
          ea.rental_id
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

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: on_time_hours {
    type: number
    sql: coalesce(${TABLE}."ON_TIME_HOURS",0) ;;
    html: {{value}} hrs. ;;
  }

  set: detail {
    fields: [asset_id, on_time_hours]
  }
}