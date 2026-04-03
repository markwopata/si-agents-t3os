view: asset_odometer_based_off_date_selection {
  derived_table: {
    sql:
    with asset_list as (
    select asset_id
    from table(assetlist({{ _user_attributes['user_id'] }}::numeric))
    union
    select asset_id
    from table(rental_asset_list({{ _user_attributes['user_id'] }}::numeric,
    convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start hourly_asset_usage_date_filter.date_filter %}),
    convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end hourly_asset_usage_date_filter.date_filter %}),
    '{{ _user_attributes['user_timezone'] }}'))
    )
    select
      al.asset_id,
      max(odometer) as odometer,
      max(date_end) as date_end
    from
      asset_list al
      inner join scd.scd_asset_odometer ao on al.asset_id = ao.asset_id
    where
      case when convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end hourly_asset_usage_date_filter.date_filter %}) > current_date then convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', current_timestamp)::timestamp_ntz else dateadd(minute,59,dateadd(hour,17,convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end hourly_asset_usage_date_filter.date_filter %}))) end
      BETWEEN date_start and case when date_end::date = '9999-12-31' then convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', current_timestamp) else date_end end
    group by
      al.asset_id
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: asset_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: odometer {
    type: number
    sql: coalesce(${TABLE}."ODOMETER",0) ;;
    value_format_name: decimal_1
  }

  dimension_group: date_end {
    type: time
    sql: ${TABLE}."DATE_END" ;;
  }

  dimension: current_date {
    type: date
    sql: current_date ;;
  }

  set: detail {
    fields: [asset_id, odometer, date_end_time]
  }
}