view: fuel_pump_outside_hours_alert {
  derived_table: {
    sql: select
          --convert_timezone('{{ _user_attributes['user_timezone'] }}', e.fuel_date) as fuel_date,
          convert_timezone('America/Chicago', e.fuel_date) as fuel_date,
          e.fuel_source_asset_id,
          coalesce(a.custom_name, 'Not Available') as fuel_source_asset_name,
          e.fueled_asset_id,
          coalesce(a2.custom_name, e.fueled_asset_custom_name) as fueled_asset_name,
          coalesce(concat(u.first_name, ', ' , u.last_name),ckc.name) as username,
          fty.name as fuel_type,
          e.amount,
          fu.name as fuel_unit,
          e.duration_seconds/60 as fuel_duration_mins,
          concat(upper(substring(ast.name,1,1)),substring(ast.name,2,length(ast.name))) as fueled_asset_type
      from
          fuel_entries e
          join assets a on a.asset_id = e.fuel_source_asset_id
          --join table(assetlist({{ _user_attributes['user_id'] }}::numeric)) L on L.asset_id = a.asset_id
          join table(assetlist(27961::numeric)) L on L.asset_id = a.asset_id
          join assets a2 on a2.asset_id = e.fueled_asset_id
          --join table(assetlist({{ _user_attributes['user_id'] }}::numeric)) L2 on L2.asset_id = a2.asset_id
          join table(assetlist(27961::numeric)) L2 on L2.asset_id = a2.asset_id
          join asset_types ast on ast.asset_type_id = a2.asset_type_id
          join fuel_types fty on fty.fuel_type_id = e.fuel_type_id
          join fuel_units fu on fu.fuel_unit_id = e.fuel_unit_id
          left join company_keypad_codes ckc on ckc.company_keypad_code_id = e.company_keypad_code_id
          left join users u on u.user_id = ckc.user_id
      where
          CASE WHEN DAYNAME(current_date) NOT IN ('Mon')
          THEN
          --convert_timezone('{{ _user_attributes['user_timezone'] }}',e.fuel_date) >= dateadd(hour,24,dateadd(day,-1,convert_timezone('{{ _user_attributes['user_timezone'] }}',current_date)))
          --AND convert_timezone('{{ _user_attributes['user_timezone'] }}',e.fuel_date) < dateadd(hour,12,convert_timezone('{{ _user_attributes['user_timezone'] }}',current_date))
          convert_timezone('America/Chicago',e.fuel_date) >= dateadd(hour,24,dateadd(day,-1,convert_timezone('America/Chicago',current_date)))
          AND convert_timezone('America/Chicago',e.fuel_date) < dateadd(hour,12,convert_timezone('America/Chicago',current_date))
          ELSE
          convert_timezone('America/Chicago',e.fuel_date) >= dateadd(hour,24,dateadd(day,-3,convert_timezone('America/Chicago',current_date)))
          AND convert_timezone('America/Chicago',e.fuel_date) < dateadd(hour,12,convert_timezone('America/Chicago',current_date))
          --convert_timezone('{{ _user_attributes['user_timezone'] }}',e.fuel_date) >= dateadd(hour,24,dateadd(day,-3,convert_timezone('{{ _user_attributes['user_timezone'] }}',current_date)))
          --AND convert_timezone('{{ _user_attributes['user_timezone'] }}',e.fuel_date) < dateadd(hour,12,convert_timezone('{{ _user_attributes['user_timezone'] }}',current_date))
          end
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension_group: fuel_date {
    type: time
    sql: ${TABLE}."FUEL_DATE" ;;
  }

  dimension: fuel_source_asset_id {
    type: number
    sql: ${TABLE}."FUEL_SOURCE_ASSET_ID" ;;
  }

  dimension: fuel_source_asset_name {
    label: "Source"
    type: string
    sql: ${TABLE}."FUEL_SOURCE_ASSET_NAME" ;;
  }

  dimension: fueled_asset_id {
    type: number
    sql: ${TABLE}."FUELED_ASSET_ID" ;;
  }

  dimension: fueled_asset_name {
    label: "Fueled Asset"
    type: string
    sql: ${TABLE}."FUELED_ASSET_NAME" ;;
  }

  dimension: username {
    label: "User"
    type: string
    sql: ${TABLE}."USERNAME" ;;
  }

  dimension: fuel_type {
    type: string
    sql: ${TABLE}."FUEL_TYPE" ;;
  }

  dimension: amount {
    label: "Gallons"
    type: number
    sql: ${TABLE}."AMOUNT" ;;
  }

  dimension: fuel_unit {
    type: string
    sql: ${TABLE}."FUEL_UNIT" ;;
  }

  dimension: fuel_duration_mins {
    label: "Fuel Duration (Mins.)"
    type: number
    sql: ${TABLE}."FUEL_DURATION_MINS" ;;
    value_format_name: decimal_2
  }

  dimension: fueled_asset_type {
    type: string
    sql: ${TABLE}."FUELED_ASSET_TYPE" ;;
  }

  dimension: fuel_date_time_formatted {
    group_label: "HTML Formatted Time"
    label: "Fuel Date & Time"
    type: date_time
    sql: ${fuel_date_raw} ;;
    html: {{ rendered_value | date: "%b %d, %Y %r"  }} {{ _user_attributes['user_timezone_label'] }};;
  }

  set: detail {
    fields: [
      fuel_date_time,
      fuel_source_asset_id,
      fuel_source_asset_name,
      fueled_asset_id,
      fueled_asset_name,
      username,
      fuel_type,
      amount,
      fuel_unit,
      fuel_duration_mins
    ]
  }
}
