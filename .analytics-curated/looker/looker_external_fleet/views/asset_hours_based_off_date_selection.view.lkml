view: asset_hours_based_off_date_selection {
  derived_table: {
    sql:
    with asset_list as (
    select asset_id
    from table(assetlist({{ _user_attributes['user_id'] }}::numeric))
    union
    select asset_id
    from table(rental_asset_list({{ _user_attributes['user_id'] }}::numeric,
    convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start hourly_asset_usage_date_filter.date_filter %}),
    convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end hourly_asset_usage_date_filter.date_filter %}::timestamp_ntz),
    '{{ _user_attributes['user_timezone'] }}'))
    )
    , asset_info_hours as (
    select
      al.asset_id,
      ah.hours,
      ah.date_end,
      ROW_NUMBER() OVER(partition by al.asset_id ORDER BY ah.date_end desc) hour_ranking
    from
      asset_list al
      inner join scd.scd_asset_hours ah on al.asset_id = ah.asset_id AND (case when convert_timezone('UTC', {% date_end hourly_asset_usage_date_filter.date_filter %})::date >= current_date then current_flag = 1 when date_end::date = '9999-12-31' and date_start <= convert_timezone('UTC', {% date_start hourly_asset_usage_date_filter.date_filter %}) then current_flag = 1 else date_end::date <= convert_timezone('UTC', {% date_end hourly_asset_usage_date_filter.date_filter %})::date AND date_start::date >= convert_timezone('UTC', {% date_start hourly_asset_usage_date_filter.date_filter %}) end)
    )
    select
        asset_id,
        hours,
        date_end
    from
        asset_info_hours aih
    where
        hour_ranking = 1
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

  dimension: hours {
    type: number
    sql: coalesce(${TABLE}."HOURS",0) ;;
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
    fields: [asset_id, hours, date_end_time]
  }
}