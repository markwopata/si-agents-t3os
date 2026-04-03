view: asset_edit_information {
  derived_table: {
    sql:
with bulk_add_users as (
select
    convert_timezone('America/Chicago',ce.time::date) as added_date,
    u._user_id as user_id,
    mimic_user,
    'No' as possible_error_in_upload
from HEAP_T3_PLATFORM_PRODUCTION.HEAP.CUSTOM_EVENTS_FLEET_ASSETS_CLICK_UPLOAD ce
left join HEAP_T3_PLATFORM_PRODUCTION.HEAP.users u on u.user_id = ce.user_id
where convert_timezone('America/Chicago',ce.time::date) >= date('2023-01-01')
union
select
    convert_timezone('America/Chicago',ce.time::date) as added_date,
    u._user_id as user_id,
    mimic_user,
    'No' as possible_error_in_upload
from HEAP_T3_PLATFORM_PRODUCTION.HEAP.CUSTOM_EVENTS_FLEET_ASSETS_CLICK_CSV_FILE_UPLOAD ce
left join HEAP_T3_PLATFORM_PRODUCTION.HEAP.users u on u.user_id = ce.user_id
where convert_timezone('America/Chicago',ce.time::date) >= date('2023-01-01')
union
select
    convert_timezone('America/Chicago',ce.time::date) as added_date,
    u._user_id as user_id,
    mimic_user,
    'Yes' as possible_error_in_upload
from HEAP_T3_PLATFORM_PRODUCTION.HEAP.CUSTOM_EVENTS_FLEET_ASSETS_CLICK_PARTIAL_UPLOAD ce
left join HEAP_T3_PLATFORM_PRODUCTION.HEAP.users u on u.user_id = ce.user_id
where convert_timezone('America/Chicago',ce.time::date) >= date('2023-01-01')
)
, created_assets as (
select
  command_audit_id,
  parameters:asset_id::number as asset_id,
  convert_timezone('America/Chicago', ca.date_created) as date_created,
  case
      when parameters:asset_args:company_id::number = 1854 then 'ES Owned'
      else 'Non-ES'
  end as asset_owner,
  case
      when bau.user_id is not null then 'Y'
      else 'N'
  end as possible_bulk_upload,
  bau.possible_error_in_upload,
  case
      when parameters:asset_args:asset_type_id::number = 1 then 'Equipment'
      when parameters:asset_args:asset_type_id::number = 2 then 'Vehicle'
      when parameters:asset_args:asset_type_id::number = 3 then 'Trailer'
      when parameters:asset_args:asset_type_id::number = 4 then 'Attachment'
      when parameters:asset_args:asset_type_id::number = 5 then 'Bucket'
      when parameters:asset_args:asset_type_id::number = 6 then 'Small Tool'
  end as asset_type,
  datediff(seconds,lag(date_created,1) over (partition by ca.user_id order by date_created asc), date_created) as time_diff
from
    command_audit ca
left join
    bulk_add_users bau on bau.user_id = ca.user_id and bau.added_date = ca.date_created::date
where
    convert_timezone('America/Chicago', ca.date_created) >= /*dateadd('month', -6, current_date)*/ date('2023-01-01')
and
    command = 'CreateAsset'
)
, edited_assets as (
select
  command_audit_id,
  parameters:asset_id::number as asset_id,
  user_id as edit_user_id,
  convert_timezone('America/Chicago', ca.date_created) as date_edited,
  case when parameters:changes:asset_settings_id is not null and parameters:changes:asset_settings_id::text != 'null' then 1 else 0 end asset_settings_id,
  case when parameters:changes:asset_type_id is not null and parameters:changes:asset_type_id::text != 'null' then 1 else 0 end asset_type_id,
  case when parameters:changes:branch_id is not null and parameters:changes:branch_id::text != 'null' then 1 else 0 end branch_id,
  case when parameters:changes:category_id is not null and parameters:changes:category_id::text != 'null' then 1 else 0 end category_id,
  case when parameters:changes:company_id is not null and parameters:changes:company_id::text != 'null' then 1 else 0 end company_id,
  --case when parameters:changes:company_timezone is not null then 1 else 0 end company_timezone,
  case when parameters:changes:custom_name is not null and parameters:changes:custom_name::text != 'null' then 1 else 0 end custom_name,
  case when parameters:changes:description is not null and parameters:changes:description::text != 'null' then 1 else 0 end description,
  case when parameters:changes:dot_number_id is not null and parameters:changes:dot_number_id::text != 'null' then 1 else 0 end dot_number_id,
  case when parameters:changes:driver_name is not null and parameters:changes:driver_name::text != 'null' then 1 else 0 end driver_name,
  case when parameters:changes:equipment_class_id is not null and parameters:changes:equipment_class_id::text != 'null' then 1 else 0 end equipment_class_id,
  case when parameters:changes:equipment_make_id is not null and parameters:changes:equipment_make_id::text != 'null' then 1 else 0 end equipment_make_id,
  case when parameters:changes:equipment_model_id is not null and parameters:changes:equipment_model_id::text != 'null' then 1 else 0 end equipment_model_id,
  --case when parameters:changes:hours is not null and parameters:changes:hours::text != 'null' then 1 else 0 end hours,
  case when parameters:changes:location_id is not null and parameters:changes:location_id::text != 'null' then 1 else 0 end location_id,
  case when parameters:changes:location_name is not null and parameters:changes:location_name::text != 'null' then 1 else 0 end location_name,
  case when parameters:changes:maintenance_group_id is not null and parameters:changes:maintenance_group_id::text != 'null' then 1 else 0 end maintenance_group_id,
  case when parameters:changes:model is not null and parameters:changes:model::text != 'null' then 1 else 0 end model,
  case when parameters:changes:name is not null and parameters:changes:name::text != 'null' then 1 else 0 end name,
  --case when parameters:changes:odometer is not null and parameters:changes:odometer::text != 'null' then 1 else 0 end odometer,
  case when parameters:changes:photo_id is not null and parameters:changes:photo_id::text != 'null' then 1 else 0 end photo_id,
  case when parameters:changes:placed_in_service is not null and parameters:changes:placed_in_service::text != 'null' then 1 else 0 end placed_in_service,
  case when parameters:changes:serial_number is not null and parameters:changes:serial_number::text != 'null' then 1 else 0 end serial_number,
  case when parameters:changes:tracker_id is not null and parameters:changes:tracker_id::text != 'null' then 1 else 0 end tracker_id,
  --case when parameters:changes:user_id is not null and parameters:changes:user_id::text != 'null' then 1 else 0 end user_id,
  case when parameters:changes:vin is not null and parameters:changes:vin::text != 'null' then 1 else 0 end vin,
  case when parameters:changes:year is not null and parameters:changes:year::text != 'null' then 1 else 0 end as year
from
    command_audit ca
where
    convert_timezone('America/Chicago', ca.date_created) >= date('2023-01-01')
and
    command = 'UpdateAsset'
and
    parameters:changes != '{}'
)
select
    ca.asset_id,
    concat(u.first_name, ' ', u.last_name) as user,
    c.name as company,
    ca.asset_owner,
    ca.asset_type,
    case
        when possible_bulk_upload = 'Y' and time_diff <= 1 then 'Bulk Asset Upload'
        else 'Normal Upload'
    end as asset_add_type,
    ca.possible_error_in_upload,
    ea.command_audit_id,
    ea.date_edited,
    ca.date_created,
    datediff('day', ca.date_created, ea.date_edited) as days_diff_from_edit_create,
    ea.asset_settings_id,
    ea.asset_type_id,
    ea.branch_id,
    ea.category_id,
    ea.company_id,
    --ea.company_timezone,
    ea.custom_name,
    ea.description,
    ea.dot_number_id,
    ea.driver_name,
    ea.equipment_class_id,
    ea.equipment_make_id,
    ea.equipment_model_id,
    --ea.hours,
    ea.location_id,
    ea.location_name,
    ea.maintenance_group_id,
    ea.model,
    ea.name,
    --ea.odometer,
    ea.photo_id,
    ea.placed_in_service,
    ea.serial_number,
    ea.tracker_id,
    --ea.user_id,
    ea.vin,
    ea.year
from
    created_assets ca
join
    edited_assets ea on ea.asset_id = ca.asset_id
left join
    assets a on a.asset_id = ea.asset_id
left join
    companies c on c.company_id = a.company_id
left join
    users u on ea.edit_user_id = u.user_id
where
  {% condition asset_filter %} ca.asset_id {% endcondition %}
and
  {% condition company_filter %} c.name {% endcondition %}
and
  {% condition asset_owner_filter %} ca.asset_owner {% endcondition %}
and
  {% condition asset_type_filter %} ca.asset_type {% endcondition %}
and
  {% condition user_filter %} concat(u.first_name, ' ', u.last_name) {% endcondition %}
and
  ea.date_edited between
  {% date_start date_filter %} and
  {% date_end date_filter %}
      ;;
  }

  filter: asset_filter {
    type: number
  }

  filter: company_filter {
    type: string
  }

  filter: asset_owner_filter {
    type: string
  }

  filter: asset_type_filter {
    type: string
  }

  filter: user_filter {
    type: string
  }

  filter: date_filter {
    type: date_time
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: user {
    type: string
    sql: ${TABLE}."USER" ;;
  }

  dimension: company {
    type: string
    sql: ${TABLE}."COMPANY" ;;
  }

  dimension: asset_owner {
    type: string
    sql: ${TABLE}."ASSET_OWNER" ;;
  }

  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }

  dimension: asset_add_type {
    type: string
    sql: ${TABLE}."ASSET_ADD_TYPE" ;;
  }

  dimension: possible_error_in_upload {
    type: string
    sql: ${TABLE}."POSSIBLE_ERROR_IN_UPLOAD" ;;
  }

  dimension: command_audit_id {
    type: number
    sql: ${TABLE}."COMMAND_AUDIT_ID" ;;
  }

  dimension_group: date_edited {
    label: "Date Edited"
    type: time
    sql: ${TABLE}."DATE_EDITED" ;;
  }

  dimension: date_created {
    type: date_time
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: days_diff_from_edit_create {
    label: "Difference in Days between Asset Creation and Edit"
    type: number
    sql: ${TABLE}."DAYS_DIFF_FROM_EDIT_CREATE" ;;
  }

  dimension: asset_settings_id {
    type: number
    sql: ${TABLE}."ASSET_SETTINGS_ID" ;;
  }

  dimension: asset_type_id {
    type: number
    sql: ${TABLE}."ASSET_TYPE_ID" ;;
  }

  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: category_id {
    type: number
    sql: ${TABLE}."CATEGORY_ID" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: custom_name {
    type: number
    sql: ${TABLE}."CUSTOM_NAME" ;;
  }

  dimension: description {
    type: number
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: dot_number_id {
    type: number
    sql: ${TABLE}."DOT_NUMBER_ID" ;;
  }

  dimension: driver_name {
    type: number
    sql: ${TABLE}."DRIVER_NAME" ;;
  }

  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }

  dimension: equipment_make_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_MAKE_ID" ;;
  }

  dimension: equipment_model_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_MODEL_ID" ;;
  }

  # dimension: hours {
  #   type: number
  #   sql: ${TABLE}."HOURS" ;;
  # }

  dimension: location_id {
    type: number
    sql: ${TABLE}."LOCATION_ID" ;;
  }

  dimension: location_name {
    type: number
    sql: ${TABLE}."LOCATION_NAME" ;;
  }

  dimension: maintenance_group_id {
    type: number
    sql: ${TABLE}."MAINTENANCE_GROUP_ID" ;;
  }

  dimension: model {
    type: number
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: name {
    type: number
    sql: ${TABLE}."NAME" ;;
  }

  # dimension: odometer {
  #   type: number
  #   sql: ${TABLE}."ODOMETER" ;;
  # }

  dimension: photo_id {
    type: number
    sql: ${TABLE}."PHOTO_ID" ;;
  }

  dimension: placed_in_service {
    type: number
    sql: ${TABLE}."PLACED_IN_SERVICE" ;;
  }

  dimension: serial_number {
    type: number
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }

  dimension: tracker_id {
    type: number
    sql: ${TABLE}."TRACKER_ID" ;;
  }

  # dimension: user_id {
  #   type: number
  #   sql: ${TABLE}."USER_ID" ;;
  # }

  dimension: vin {
    type: number
    sql: ${TABLE}."VIN" ;;
  }

  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
  }

  measure: total_number_of_edits {
    type: count_distinct
    sql: ${command_audit_id} ;;
  }

  measure: average_day_diff_between_create_and_edit {
    type: average
    label: "Avg. Days between Creation and Edit"
    sql: ${days_diff_from_edit_create} ;;
    value_format_name: decimal_2
  }

  measure: asset_settings_id_edits {
    type: sum
    sql: ${asset_settings_id} ;;
  }

  measure: asset_type_id_edits {
    type: sum
    sql: ${asset_type_id} ;;
  }

  measure: branch_id_edits {
    type: sum
    sql: ${branch_id} ;;
  }

  measure: category_id_edits {
    type: sum
    sql: ${category_id} ;;
  }

  measure: custom_name_edits {
    type: sum
    sql: ${custom_name} ;;
  }

  measure: description_edits {
    type: sum
    sql: ${description} ;;
  }

  measure: dot_number_id_edits {
    label: "DOT Number ID Edits"
    type: sum
    sql: ${dot_number_id} ;;
  }

  measure: driver_name_edits {
    type: sum
    sql: ${driver_name} ;;
  }

  measure: equipment_class_id_edits {
    type: sum
    sql: ${equipment_class_id} ;;
  }

  measure: equipment_make_id_edits {
    type: sum
    sql: ${equipment_make_id} ;;
  }

  measure: equipment_model_id_edits {
    type: sum
    sql: ${equipment_model_id} ;;
  }

  # measure: hours_edits {
  #   type: sum
  #   sql: ${hours} ;;
  # }

  measure: location_id_edits {
    type: sum
    sql: ${location_id} ;;
  }

  measure: location_name_edits {
    type: sum
    sql: ${location_name} ;;
  }

  measure: maintenance_group_id_edits {
    type: sum
    sql: ${maintenance_group_id} ;;
  }

  measure: model_edits {
    type: sum
    sql: ${model} ;;
  }

  measure: name_edits {
    type: sum
    sql: ${name} ;;
  }

  # measure: odometer_edits {
  #   type: sum
  #   sql: ${odometer} ;;
  # }

  measure: photo_id_edits {
    type: sum
    sql: ${photo_id} ;;
  }

  measure: placed_in_service_edits {
    type: sum
    sql: ${placed_in_service} ;;
  }

  measure: serial_number_edits {
    type: sum
    sql: ${serial_number} ;;
  }

  measure: tracker_id_edits {
    type: sum
    sql: ${tracker_id} ;;
  }

  # measure: user_id_edits {
  #   type: sum
  #   sql: ${user_id} ;;
  # }

  measure: vin_edits {
    label: "VIN Edits"
    type: sum
    sql: ${vin} ;;
  }

  measure: year_edits {
    type: sum
    sql: ${year} ;;
  }
}
