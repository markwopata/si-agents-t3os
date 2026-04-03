view: eld_pairing_report {
  label: "ELD Pairing Report"

  derived_table: {
    sql:

    select
        dl.asset_id as asset_id,
        coalesce(a.custom_name, 'No Asset Paired') as asset,
        dl.driver_id as driver_id, concat(coalesce(u.first_name, 'No'), ' ', coalesce(u.last_name, 'Driver Paired')) as driver_name,
        u.company_id as company_id,
        sum(datediff(second, dl.start_date, dl.end_date))/3600 as hours_driven,
        sum(distance) as miles_driven,
        dl.start_location as start_location, dl.end_location as end_location,
        dl.start_date as start_date, dl.end_date as end_date
    from elogs.driver_tracker_logs dl
        left join users u on u.user_id = dl.driver_id
        left join assets a on dl.asset_id = a.asset_id
    where dl.start_date >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %})
        and dl.end_date <= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end   date_filter %})
        and (a.asset_type_id = 2 or dl.asset_id is null)
        and dl.distance > 0
    group by dl.asset_id, a.custom_name, dl.driver_id,
             u.first_name, u.last_name, u.company_id,
             dl.start_location, dl.end_location,
             dl.start_date, dl.end_date
    order by asset_id, start_date

    ;;
  }

  filter: date_filter {
    type: date_time
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset {
    type: string
    sql: ${TABLE}."ASSET" ;;
  }

  dimension: driver_id {
    type: number
    sql: ${TABLE}."DRIVER_ID" ;;
  }

  dimension: driver_name {
    type: string
    sql: ${TABLE}."DRIVER_NAME" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: hours_driven {
    type: number
    sql: ${TABLE}."HOURS_DRIVEN" ;;
    html: <a href="#drillmenu" target="_self">{{rendered_value}} hrs.</a>;;
    value_format_name: decimal_2
  }

  dimension: miles_driven {
    type: number
    sql: ${TABLE}."MILES_DRIVEN" ;;
    html: <a href="#drillmenu" target="_self">{{rendered_value}} mi.</a>;;
    value_format_name: decimal_2
  }

  dimension: start_location {
    type: string
    sql: ${TABLE}."START_LOCATION" ;;
  }

  dimension: end_location {
    type: string
    sql: ${TABLE}."END_LOCATION" ;;
  }

  dimension: start_date {
    type: date_time
    sql: convert_timezone('{{ _user_attributes['user_timezone'] }}', 'UTC', ${TABLE}."START_DATE"::timestamp_ntz) ;;
    html: {{ rendered_value | date: "%b %d, %Y %r"  }} {{ _user_attributes['user_timezone_label'] }};;
  }

  dimension: end_date {
    type: date_time
    sql: convert_timezone('{{ _user_attributes['user_timezone'] }}', 'UTC', ${TABLE}."END_DATE"::timestamp_ntz) ;;
    html: {{ rendered_value | date: "%b %d, %Y %r"  }} {{ _user_attributes['user_timezone_label'] }};;
  }

  measure: unpaired_hours {
    label: "Unassigned Hours"
    type: sum
    sql: case when ${driver_name} = 'No Driver Paired' or ${asset} = 'No Asset Paired'
              then ${hours_driven}
         else 0 end ;;
    value_format_name: decimal_2
    html: <a href="#drillmenu" target="_self">{{rendered_value}} hrs.</a>;;
  }

  measure: paired_hours {
    label: "Assigned Hours"
    type: sum
    sql: case when ${driver_name} <> 'No Driver Paired' and ${asset} <> 'No Asset Paired'
              then ${hours_driven}
         else 0 end ;;
    value_format_name: decimal_2
    html: <a href="#drillmenu" target="_self">{{rendered_value}} hrs.</a>;;
  }




}
