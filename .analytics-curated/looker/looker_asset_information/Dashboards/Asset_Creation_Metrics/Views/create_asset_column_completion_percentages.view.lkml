  view: create_asset_column_completion_percentages {
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
, create_asset_command as (
select
  ca.command_audit_id,
  parameters:asset_id as asset_id,
  concat(u.first_name, ' ', u.last_name) as user,
  c.name as company,
  convert_timezone('America/Chicago', ca.date_created) as added_date,
  case
      when parameters:asset_args:company_id::number = 1854 then 'ES Owned'
      else 'Non-ES'
  end as asset_owner,
  case
      when bau.user_id is not null then 'Y'
      else 'N'
  end as possible_bulk_upload,
  case
    when bau.possible_error_in_upload is not null then bau.possible_error_in_upload
    else 'No'
  end as possible_error_in_upload,
  case
      when parameters:asset_args:asset_type_id::number = 1 then 'Equipment'
      when parameters:asset_args:asset_type_id::number = 2 then 'Vehicle'
      when parameters:asset_args:asset_type_id::number = 3 then 'Trailer'
      when parameters:asset_args:asset_type_id::number = 4 then 'Attachment'
      when parameters:asset_args:asset_type_id::number = 5 then 'Bucket'
      when parameters:asset_args:asset_type_id::number = 6 then 'Small Tool'
  end as asset_type,
  case when parameters:asset_args:asset_settings_id is not null and parameters:asset_args:asset_settings_id::text != 'null' then parameters:asset_args:asset_settings_id else null end as asset_settings_id,
  --case when parameters:asset_args:asset_type_id is not null and parameters:asset_args:asset_type_id::text != 'null' then parameters:asset_args:asset_type_id else null end as asset_type_id,
  case when parameters:asset_args:branch_id is not null and parameters:asset_args:branch_id::text != 'null' then parameters:asset_args:branch_id else null end as branch_id,
  case when parameters:asset_args:category_id is not null and parameters:asset_args:category_id ::text != 'null' then parameters:asset_args:category_id else null end as category_id,
  --case when parameters:asset_args:company_id is not null and parameters:asset_args:company_id::text != 'null' then parameters:asset_args:company_id else null end as company_id,
  --case when parameters:asset_args:company_timezone is not null and parameters:asset_args:company_timezone::text != 'null' then parameters:asset_args:company_timezone else null as company_timezone,
  case when parameters:asset_args:custom_name is not null and parameters:asset_args:custom_name ::text != 'null' and len(parameters:asset_args:custom_name) < 36 then parameters:asset_args:custom_name else null end as custom_name,
  case when parameters:asset_args:description is not null and parameters:asset_args:description::text != 'null' then parameters:asset_args:description else null end as description,
  case when parameters:asset_args:dot_number_id is not null and parameters:asset_args:dot_number_id::text != 'null' then parameters:asset_args:dot_number_id else null end as dot_number_id,
  case when parameters:asset_args:driver_name is not null and parameters:asset_args:driver_name::text != 'null' then parameters:asset_args:driver_name else null end as driver_name,
  case when parameters:asset_args:equipment_class_id is not null and parameters:asset_args:equipment_class_id::text != 'null' then parameters:asset_args:equipment_class_id else null end as equipment_class_id,
  case when parameters:asset_args:equipment_make_id is not null and parameters:asset_args:equipment_make_id::text != 'null' then parameters:asset_args:equipment_make_id else null end as equipment_make_id,
  case when parameters:asset_args:equipment_model_id is not null and parameters:asset_args:equipment_model_id::text != 'null' then parameters:asset_args:equipment_model_id else null end as equipment_model_id,
  case when parameters:asset_args:hours is not null and parameters:asset_args:hours::text != 'null' then parameters:asset_args:hours else null end as hours,
  --case when parameters:asset_args:location_id is not null and parameters:asset_args:location_id::text != 'null' then parameters:asset_args:location_id else null end as location_id,
  --case when parameters:asset_args:location_name is not null and parameters:asset_args:location_name::text != 'null' then parameters:asset_args:location_name else null end as location_name,
  case when parameters:asset_args:maintenance_group_id is not null and parameters:asset_args:maintenance_group_id::text != 'null' then parameters:asset_args:maintenance_group_id else null end as maintenance_group_id,
  case when parameters:asset_args:model is not null and parameters:asset_args:model::text != 'null' then parameters:asset_args:model else null end as model,
  case when parameters:asset_args:name is not null and parameters:asset_args:name::text != 'null' then parameters:asset_args:name else null end as name,
  case when parameters:asset_args:odometer is not null and parameters:asset_args:odometer::text != 'null' then parameters:asset_args:odometer else null end as odometer,
  case when parameters:asset_args:photo_id is not null and parameters:asset_args:photo_id::text != 'null' then parameters:asset_args:photo_id else null end as photo_id,
  case when parameters:asset_args:placed_in_service is not null and parameters:asset_args:placed_in_service::text != 'null' then parameters:asset_args:placed_in_service else null end as placed_in_service,
  case when parameters:asset_args:serial_number is not null and parameters:asset_args:serial_number::text != 'null' then parameters:asset_args:serial_number else null end as serial_number,
  case when parameters:asset_args:tracker_id is not null and parameters:asset_args:tracker_id::text != 'null' then parameters:asset_args:tracker_id else null end as tracker_id,
  --case when parameters:asset_args:user_id is not null and parameters:asset_args:user_id::text != 'null' then parameters:asset_args:user_id else null  end as user_id,
  case when parameters:asset_args:vin is not null and parameters:asset_args:vin::text != 'null' then parameters:asset_args:vin else null end as vin,
  case when parameters:asset_args:year is not null and parameters:asset_args:year::text != 'null' then parameters:asset_args:year else null end as year,
  datediff(seconds,lag(ca.date_created,1) over (partition by ca.user_id order by ca.date_created asc), ca.date_created) as time_diff
from command_audit ca
left join
    bulk_add_users bau on bau.user_id = ca.user_id and bau.added_date = ca.date_created::date
left join
    users u on ca.user_id = u.user_id
left join
    companies c on c.company_id = u.company_id
where convert_timezone('America/Chicago', ca.date_created) >= date('2023-01-01')
and command = 'CreateAsset'
)
select
    company,
    user,
    asset_type,
    asset_owner,
    case
        when possible_bulk_upload = 'Y' and time_diff <= 1 then 'Bulk Asset Upload'
        else 'Normal Upload'
    end as asset_add_type,
    possible_error_in_upload,
    added_date,
    round((count(ca.asset_settings_id) * 1.0 / count(*)) * 100,2) as pcnt_asset_settings_id,
    --round((count(ca.asset_type_id) * 1.0 / count(*)) * 100,2) as pcnt_asset_type_id,
    round((count(ca.branch_id) * 1.0 / count(*)) * 100,2) as pcnt_branch_id,
    round((count(category_id) * 1.0 / count(*)) * 100,2) as pcnt_category_id,
    --round((count(company_id) * 1.0 / count(*)) * 100,2) as pcnt_company_id,
    --round((count(company_timezone) * 1.0 / count(*)) * 100,2) as pcnt_company_timezone,
    round((count(custom_name) * 1.0 / count(*)) * 100,2) as pcnt_custom_name,
    round((count(description) * 1.0 / count(*)) * 100,2) as pcnt_description,
    round((count(dot_number_id) * 1.0 / count(*)) * 100,2) as pcnt_dot_number_id,
    round((count(driver_name) * 1.0 / count(*)) * 100,2) as pcnt_driver_name,
    round((count(equipment_class_id) * 1.0 / count(*)) * 100,2) as pcnt_equipment_class_id,
    round((count(equipment_make_id) * 1.0 / count(*)) * 100,2) as pcnt_equipment_make_id,
    round((count(equipment_model_id) * 1.0 / count(*)) * 100,2) as pcnt_equipment_model_id,
    round((count(hours) * 1.0 / count(*)) * 100,2) as pcnt_hours,
    --round((count(location_id) * 1.0 / count(*)) * 100,2) as pcnt_location_id,
    --round((count(location_name) * 1.0 / count(*)) * 100,2) as pcnt_location_name,
    round((count(maintenance_group_id) * 1.0 / count(*)) * 100,2) as pcnt_maintenance_group_id,
    round((count(model) * 1.0 / count(*)) * 100,2) as pcnt_model,
    round((count(ca.name) * 1.0 / count(*)) * 100,2) as pcnt_name,
    round((count(odometer) * 1.0 / count(*)) * 100,2) as pcnt_odometer,
    round((count(photo_id) * 1.0 / count(*)) * 100,2) as pcnt_photo_id,
    round((count(placed_in_service) * 1.0 / count(*)) * 100,2) as pcnt_placed_in_service,
    round((count(serial_number) * 1.0 / count(*)) * 100,2) as pcnt_serial_number,
    round((count(tracker_id) * 1.0 / count(*)) * 100,2) as pcnt_tracker_id,
    --round((count(user_id) * 1.0 / count(*)) * 100,2) as pcnt_user_id,
    round((count(vin) * 1.0 / count(*)) * 100,2) as pcnt_vin,
    round((count(year) * 1.0 / count(*)) * 100,2)  as pcnt_year
from
  create_asset_command ca
where
  added_date between
  {% date_start date_filter %} and
  {% date_end date_filter %}
group by 1,2,3,4,5,6,7
        ;;
    }

    dimension: company {
      type: string
      sql: ${TABLE}."COMPANY" ;;
    }

    dimension: user {
      type: string
      sql: ${TABLE}."USER" ;;
    }

    dimension: asset_type {
      type: string
      sql: ${TABLE}."ASSET_TYPE" ;;
    }

    dimension: asset_owner {
      type: string
      sql: ${TABLE}."ASSET_OWNER" ;;
    }

    dimension: asset_add_type {
      type: string
      sql: ${TABLE}."ASSET_ADD_TYPE" ;;
    }

    dimension: possible_error_in_upload {
      type: string
      sql: ${TABLE}."POSSIBLE_ERROR_IN_UPLOAD" ;;
    }

    dimension_group: added_date {
      type: time
      sql: ${TABLE}."ADDED_DATE" ;;
    }

    # dimension: pcnt_asset_type_id {
    #   label: "Asset Type Completed %"
    #   type: number
    #   sql: ${TABLE}."PCNT_ASSET_TYPE_ID" ;;
    # }

    dimension: pcnt_branch_id {
      label: "Branch ID Completed %"
      type: number
      sql: ${TABLE}."PCNT_BRANCH_ID" ;;
    }

    dimension: pcnt_category_id {
      label: "Category ID Completed %"
      type: number
      sql: ${TABLE}."PCNT_CATEGORY_ID" ;;
    }

    # dimension: pcnt_company_id {
    #   label: "Company ID Completed %"
    #   type: number
    #   sql: ${TABLE}."PCNT_COMPANY_ID" ;;
    # }

    # dimension: pcnt_company_timezone {
    #   label: "Company Timezone Completed %"
    #   type: number
    #   sql: ${TABLE}."PCNT_COMPANY_TIMEZONE" ;;
    # }

    dimension: pcnt_custom_name {
      label: "Custom Name Completed %"
      type: number
      sql: ${TABLE}."PCNT_CUSTOM_NAME" ;;
    }

    dimension: pcnt_description {
      label: "Description Completed %"
      type: number
      sql: ${TABLE}."PCNT_DESCRIPTION" ;;
    }

    dimension: pcnt_dot_number_id {
      label: "DOT Number ID Completed %"
      type: number
      sql: ${TABLE}."PCNT_DOT_NUMBER_ID" ;;
    }

    dimension: pcnt_driver_name {
      label: "Driver Name Completed %"
      type: number
      sql: ${TABLE}."PCNT_DRIVER_NAME" ;;
    }

    dimension: pcnt_equipment_class_id {
      label: "Equipment Class ID Completed %"
      type: number
      sql: ${TABLE}."PCNT_EQUIPMENT_CLASS_ID" ;;
    }

    dimension: pcnt_equipment_make_id {
      label: "Equipment Make ID Completed %"
      type: number
      sql: ${TABLE}."PCNT_EQUIPMENT_MAKE_ID" ;;
    }

    dimension: pcnt_equipment_model_id {
      label: "Equipment Model Completed %"
      type: number
      sql: ${TABLE}."PCNT_EQUIPMENT_MODEL_ID" ;;
    }

    dimension: pcnt_hours {
      label: "Hours Completed %"
      type: number
      sql: ${TABLE}."PCNT_HOURS" ;;
    }

    # dimension: pcnt_location_id {
    #   label: "Location ID Completed %"
    #   type: number
    #   sql: ${TABLE}."PCNT_LOCATION_ID" ;;
    # }

    # dimension: pcnt_location_name {
    #   label: "Location Name Completed %"
    #   type: number
    #   sql: ${TABLE}."PCNT_LOCATION_NAME" ;;
    # }

    dimension: pcnt_maintenance_group_id {
      label: "Maintenance Group ID Completed %"
      type: number
      sql: ${TABLE}."PCNT_MAINTENANCE_GROUP_ID" ;;
    }

    dimension: pcnt_model {
      label: "Model Completed %"
      type: number
      sql: ${TABLE}."PCNT_MODEL" ;;
    }

    dimension: pcnt_name {
      label: "Name Completed %"
      type: number
      sql: ${TABLE}."PCNT_NAME" ;;
    }

    dimension: pcnt_odometer {
      label: "Odometer Completed %"
      type: number
      sql: ${TABLE}."PCNT_ODOMETER" ;;
    }

    dimension: pcnt_photo_id {
      label: "Photo ID Completed %"
      type: number
      sql: ${TABLE}."PCNT_PHOTO_ID" ;;
    }

    dimension: pcnt_placed_in_service {
      label: "Placed In Service Completed %"
      type: number
      sql: ${TABLE}."PCNT_PLACED_IN_SERVICE" ;;
    }

    dimension: pcnt_serial_number {
      label: "Serial Number Completed %"
      type: number
      sql: ${TABLE}."PCNT_SERIAL_NUMBER" ;;
    }

    dimension: pcnt_tracker_id {
      label: "Tracker ID Completed %"
      type: number
      sql: ${TABLE}."PCNT_TRACKER_ID" ;;
    }

    # dimension: pcnt_user_id {
    #   label: "User ID Completed %"
    #   type: number
    #   sql: ${TABLE}."PCNT_USER_ID" ;;
    # }

    dimension: pcnt_vin {
      label: "VIN Completed %"
      type: number
      sql: ${TABLE}."PCNT_VIN" ;;
    }

    dimension: pcnt_year {
      label: "Year Completed %"
      type: number
      sql: ${TABLE}."PCNT_YEAR" ;;
    }

    measure: avg_branch_id_pcnt {
      label: "Avg Branch ID Completion %"
      type: average
      sql: ${pcnt_branch_id} ;;
      value_format_name: decimal_2
    }

    measure: avg_category_id_pcnt {
      label: "Avg Category ID Completion %"
      type: average
      sql: ${pcnt_category_id} ;;
      value_format_name: decimal_2
    }

    measure: avg_custom_name_pcnt {
      label: "Avg Custom Name Completion %"
      type: average
      sql: ${pcnt_custom_name} ;;
      value_format_name: decimal_2
    }

    measure: avg_description_pcnt {
      label: "Avg Description Completion %"
      type: average
      sql: ${pcnt_description} ;;
      value_format_name: decimal_2
    }

    measure: avg_dot_number_id_pcnt {
      label: "Avg DOT Number ID Completion %"
      type: average
      sql: ${pcnt_dot_number_id} ;;
      value_format_name: decimal_2
    }

    measure: avg_driver_name_pcnt {
      label: "Avg Driver Name Completion %"
      type: average
      sql: ${pcnt_driver_name} ;;
      value_format_name: decimal_2
    }

    measure: avg_equipment_class_id_pcnt {
      label: "Avg Equipment Class ID Completion %"
      type: average
      sql: ${pcnt_equipment_class_id} ;;
      value_format_name: decimal_2
    }

    measure: avg_equipment_make_id_pcnt {
      label: "Avg Equipment Make ID Completion %"
      type: average
      sql: ${pcnt_equipment_make_id} ;;
      value_format_name: decimal_2
    }

    measure: avg_equipment_model_id_pcnt {
      label: "Avg Equipment Model ID Completion %"
      type: average
      sql: ${pcnt_equipment_model_id} ;;
      value_format_name: decimal_2
    }

    measure: avg_hours_pcnt {
      label: "Avg Hours Completion %"
      type: average
      sql: ${pcnt_hours} ;;
      value_format_name: decimal_2
    }

    measure: avg_maintenance_group_id_pcnt {
      label: "Avg Maintenance Group ID Completion %"
      type: average
      sql: ${pcnt_maintenance_group_id} ;;
      value_format_name: decimal_2
    }

    measure: avg_model_pcnt {
      label: "Avg Model Completion %"
      type: average
      sql: ${pcnt_model} ;;
      value_format_name: decimal_2
    }

    measure: avg_name_pcnt {
      label: "Avg Name Completion %"
      type: average
      sql: ${pcnt_name} ;;
      value_format_name: decimal_2
    }

    measure: avg_odometer_pcnt {
      label: "Avg Odometer Completion %"
      type: average
      sql: ${pcnt_odometer} ;;
      value_format_name: decimal_2
    }

    measure: avg_photo_id_pcnt {
      label: "Avg Photo ID Completion %"
      type: average
      sql: ${pcnt_photo_id} ;;
      value_format_name: decimal_2
    }

    measure: avg_placed_in_service_pcnt {
      label: "Avg Placed In Service Completion %"
      type: average
      sql: ${pcnt_placed_in_service} ;;
      value_format_name: decimal_2
    }

    measure: avg_serial_number_pcnt {
      label: "Avg Serial Number Completion %"
      type: average
      sql: ${pcnt_serial_number} ;;
      value_format_name: decimal_2
    }

    measure: avg_tracker_id_pcnt {
      label: "Avg Tracker ID Completion %"
      type: average
      sql: ${pcnt_tracker_id} ;;
      value_format_name: decimal_2
    }

    measure: avg_vin_pcnt {
      label: "Avg VIN Completion %"
      type: average
      sql: ${pcnt_vin} ;;
      value_format_name: decimal_2
    }

    measure: avg_year_pcnt {
      label: "Avg Year Completion %"
      type: average
      sql: ${pcnt_year} ;;
      value_format_name: decimal_2
    }

    filter: date_filter {
      type: date_time
    }
  }
