view: battery_state_of_charge {
  derived_table: {
    sql: with asset_list_own as (
          select asset_id
          from table(assetlist(17859::numeric))
          --from table(assetlist({{ _user_attributes['user_id'] }}::numeric))
          )
          select
              alo.asset_id,
              name,
              battery_state_of_charge,
              updated
          from
              asset_list_own alo
              join (select asset_id, name, value as battery_state_of_charge, updated from asset_status_key_values where name = 'battery_state_of_charge') bsoc on alo.asset_id = bsoc.asset_id
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    primary_key: yes
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: battery_state_of_charge {
    type: string
    sql: ${TABLE}."BATTERY_STATE_OF_CHARGE" ;;
    # html: {{rendered_value}}% ;;
  }

  dimension_group: updated {
    type: time
    sql: ${TABLE}."UPDATED" ;;
  }

  measure: percent_of_battery_charge_state {
    type: number
    sql: ${battery_state_of_charge} ;;
    html: {{rendered_value}}% ;;
  }

  dimension: updated_formatted {
    group_label: "HTML Passed Date Format" label: "Updated Timestamp"
    # type: time
    sql: ${updated_raw} ;;
    html: {{ rendered_value | date: "%b %d, %Y %r" }};;
  }

  parameter: charge_bucket_size {
    type: number
    allowed_value: { value: "5"}
    allowed_value: { value: "10"}
    allowed_value: { value: "15"}
    allowed_value: { value: "20"}
  }

  dimension: dynamic_charge_size {
    label: "Charge Bucket Size"
    type: number
    sql: TRUNCATE((${battery_state_of_charge}) / {% parameter charge_bucket_size %}, 0)
      * {% parameter charge_bucket_size %} ;;
    html: {{rendered_value}}% ;;
  }

  set: detail {
    fields: [asset_id, name, battery_state_of_charge, updated_time]
  }
}
