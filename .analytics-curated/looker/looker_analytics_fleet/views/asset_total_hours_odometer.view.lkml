view: asset_total_hours_odometer {
  derived_table: {
    sql: with asset_list as (
          select asset_id
          from table(assetlist({{ _user_attributes['user_id'] }}::numeric))
          union
          select asset_id
          from table(rental_asset_list({{ _user_attributes['user_id'] }}::numeric, convert_timezone('UTC', '{{ _user_attributes['company_timezone'] }}', current_date::timestamp_ntz), convert_timezone('UTC', '{{ _user_attributes['company_timezone'] }}',  current_date::timestamp_ntz), '{{ _user_attributes['company_timezone'] }}'))
          )
          select
              a.asset_id,
              coalesce(h.hours,0) as hours,
              coalesce(o.odometer,0) as odometer
          from
              asset_list a
              left join (select asset_id, hours from ES_WAREHOUSE.SCD.scd_asset_hours where current_flag = 1) h on a.asset_id = h.asset_id
              left join (select asset_id, odometer from ES_WAREHOUSE.SCD.scd_asset_odometer where current_flag = 1) o on a.asset_id = o.asset_id
             ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
    hidden: yes
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    hidden: yes
  }

  dimension: hours {
    type: number
    sql: ${TABLE}."HOURS" ;;
    value_format_name: decimal_1
    view_label: "Assets"
    label: "Current Asset Hours"
  }

  dimension: odometer {
    type: number
    sql: ${TABLE}."ODOMETER" ;;
    value_format_name: decimal_1
    view_label: "Assets"
    label: "Current Asset Odometer Reading"
  }

  set: detail {
    fields: [asset_id, hours, odometer]
  }
}
