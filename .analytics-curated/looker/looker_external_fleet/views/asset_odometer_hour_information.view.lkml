view: asset_odometer_hour_information {
  derived_table: {
    sql: with asset_list as (
      select asset_id
      from table(assetlist({{ _user_attributes['user_id'] }}::numeric))
      )
      select
        a.asset_id,
        m.odometer,
        h.hours
      from
        asset_list a
        left join (select asset_id, value as odometer from asset_status_key_values where name = 'odometer') m on m.asset_id = a.asset_id
        left join (select asset_id, value as hours from asset_status_key_values where name = 'hours') h on h.asset_id = a.asset_id
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
    sql: ${TABLE}."ODOMETER" ;;
    value_format_name: decimal_2
  }

  dimension: hours {
    type: number
    sql: ${TABLE}."HOURS" ;;
    value_format_name: decimal_2
  }

  set: detail {
    fields: [asset_id, odometer, hours]
  }
}
