view: fuel_pump_data {
 derived_table: {
  sql:
  select convert_timezone('{{ _user_attributes['user_timezone'] }}', e.fuel_date) as fuel_date,
    e.fuel_source_asset_id,
    coalesce(a.custom_name, 'Not Available') as fuel_source_asset_name,
    e.fueled_asset_id,
    coalesce(a2.custom_name, e.fueled_asset_custom_name,'Unassigned') as fueled_asset_name,
    coalesce(concat(u.first_name, ', ' , u.last_name),ckc.name) as username,
    fty.name as fuel_type,
    e.amount,
    fu.name as fuel_unit,
  e.duration_seconds/60 as fuel_duration_mins
from fuel_entries e join assets a on a.asset_id = e.fuel_source_asset_id
    left join table(assetlist({{ _user_attributes['user_id'] }}::numeric)) L on L.asset_id = a.asset_id
    left join assets a2 on a2.asset_id = e.fueled_asset_id left join table(assetlist({{ _user_attributes['user_id'] }}::numeric)) L2 on L2.asset_id = a2.asset_id
    left join fuel_types fty on fty.fuel_type_id = e.fuel_type_id
    left join fuel_units fu on fu.fuel_unit_id = e.fuel_unit_id
    left join company_keypad_codes ckc on ckc.company_keypad_code_id = e.company_keypad_code_id
    left join users u on u.user_id = ckc.user_id
where e.fuel_date >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %})
    and e.fuel_date < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})
    and e.company_id = {{ _user_attributes['company_id'] }}::numeric
  ;;


  }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: ${fuel_date_raw} ;;
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
    value_format_name: decimal_2
    html: {{rendered_value}} gal. ;;
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
    html: {{rendered_value}} mins. ;;
  }

  filter: date_filter {
    type: date_time
  }

  dimension: fuel_date_time_formatted {
    group_label: "HTML Formatted Time"
    label: "Fuel Date & Time"
    type: date_time
    sql: ${fuel_date_raw} ;;
    html: {{ rendered_value | date: "%b %d, %Y %r"  }} {{ _user_attributes['user_timezone_label'] }};;
  }

  measure: total_gallons {
    type: sum
    sql: ${amount} ;;
    value_format_name: decimal_2
    filters: [fueled_asset_id: "not null"]
    html: {{rendered_value}} gal. ;;
    drill_fields: [assigned_fueling_history*]
  }

  measure: total_gallons_unassigned {
    type: sum
    sql: ${amount} ;;
    value_format_name: decimal_2
    filters: [fueled_asset_id: "null"]
    html: {{rendered_value}} gal. ;;
    drill_fields: [unassigned_fueling_history*]
  }

  set: assigned_fueling_history {
    fields: [
      fuel_date_time_formatted,
      fueled_asset_name,
      fuel_source_asset_name,
      username,
      total_gallons,
      fuel_type,
      fuel_duration_mins
    ]
  }

  set: unassigned_fueling_history {
    fields: [
      fuel_date_time_formatted,
      fueled_asset_name,
      fuel_source_asset_name,
      username,
      total_gallons_unassigned,
      fuel_type,
      fuel_duration_mins
    ]
  }


  }
