view: create_asset_column_totals {
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
, equipment_columns as (
select
  command_audit_id,
  parameters:asset_id as asset_id,
  concat(u.first_name, ' ', u.last_name) as user,
  c.name as company,
  case
      when parameters:asset_args:company_id::number = 1854 then 'ES Owned'
      else 'Non-ES'
  end as asset_owner,
  case
      when parameters:asset_args:asset_type_id::number = 1 then 'Equipment'
      when parameters:asset_args:asset_type_id::number = 3 then 'Trailer'
      when parameters:asset_args:asset_type_id::number = 4 then 'Attachment'
      when parameters:asset_args:asset_type_id::number = 5 then 'Bucket'
      when parameters:asset_args:asset_type_id::number = 6 then 'Small Tool'
  end as asset_type,
  case
      when bau.user_id is not null then 'Y'
      else 'N'
  end as possible_bulk_upload,
  bau.possible_error_in_upload,
  convert_timezone('America/Chicago', ca.date_created) as created_date,
  case when parameters:asset_args:asset_type_id is not null and parameters:asset_args:asset_type_id::text != 'null' then 1 else 0 end +
  case when parameters:asset_args:branch_id is not null and parameters:asset_args:branch_id::text != 'null'then 1 else 0 end +
  case when parameters:asset_args:category_id is not null and parameters:asset_args:category_id::text != 'null' then 1 else 0 end +
  case when parameters:asset_args:company_id is not null and parameters:asset_args:company_id::text != 'null' then 1 else 0 end +
  --case when parameters:asset_args:company_timezone is not null and parameters:asset_args:company_timezone::text != 'null' then 1 else 0 end +
  case when parameters:asset_args:custom_name is not null and parameters:asset_args:custom_name::text != 'null' and len(parameters:asset_args:custom_name) < 36 then 1 else 0 end +
  case when parameters:asset_args:description is not null and parameters:asset_args:description::text != 'null' then 1 else 0 end +
  --parameters:asset_args:dot_number_id
  --parameters:asset_args:driver_name
  case when parameters:asset_args:equipment_class_id is not null and parameters:asset_args:equipment_class_id::text != 'null' then 1 else 0 end +
  case when parameters:asset_args:equipment_make_id is not null and parameters:asset_args:equipment_make_id::text != 'null' then 1 else 0 end +
  case when parameters:asset_args:equipment_model_id is not null and parameters:asset_args:equipment_model_id::text != 'null' then 1 else 0 end +
  case when parameters:asset_args:hours is not null and parameters:asset_args:hours::text != 'null' then 1 else 0 end +
  case when parameters:asset_args:location_id is not null and parameters:asset_args:location_id::text != 'null' then 1 else 0 end +
  --parameters:asset_args:location_name
  case when parameters:asset_args:maintenance_group_id is not null and parameters:asset_args:maintenance_group_id::text != 'null' then 1 else 0 end +
  case when parameters:asset_args:model is not null and parameters:asset_args:model::text != 'null' then 1 else 0 end +
  case when parameters:asset_args:name is not null and parameters:asset_args:name::text != 'null' then 1 else 0 end +
  --parameters:asset_args:odometer
  case when parameters:asset_args:photo_id is not null and parameters:asset_args:photo_id::text != 'null' then 1 else 0 end +
  case when parameters:asset_args:placed_in_service is not null and parameters:asset_args:placed_in_service::text != 'null' then 1 else 0 end +
  case when parameters:asset_args:serial_number is not null and parameters:asset_args:serial_number::text != 'null' then 1 else 0 end +
  case when parameters:asset_args:tracker_id is not null and parameters:asset_args:tracker_id::text != 'null' then 1 else 0 end +
 -- case when parameters:asset_args:user_id is not null and parameters:asset_args:user_id::text != 'null' then 1 else 0 end +
  --parameters:asset_args:vin
  case when parameters:asset_args:year is not null and parameters:asset_args:year::text != 'null' then 1 else 0 end as columns_completed,
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
and parameters:asset_args:asset_type_id::number != 2
)
, vehicle_columns as (
select
  command_audit_id,
  parameters:asset_id as asset_id,
  concat(u.first_name, ' ', u.last_name) as user,
  c.name as company,
  case
      when parameters:asset_args:company_id::number = 1854 then 'ES Owned'
      else 'Non-ES'
  end as asset_owner,
  'Vehicle' as asset_type,
  case
      when bau.user_id is not null then 'Y'
      else 'N'
  end as possible_bulk_upload,
  bau.possible_error_in_upload,
  convert_timezone('America/Chicago', ca.date_created) as created_date,
  case when parameters:asset_args:asset_type_id is not null and parameters:asset_args:asset_type_id::text != 'null' then 1 else 0 end +
  case when parameters:asset_args:branch_id is not null and parameters:asset_args:branch_id::text != 'null'then 1 else 0 end +
  case when parameters:asset_args:category_id is not null and parameters:asset_args:category_id::text != 'null' then 1 else 0 end +
  case when parameters:asset_args:company_id is not null and parameters:asset_args:company_id::text != 'null' then 1 else 0 end +
  --case when parameters:asset_args:company_timezone is not null and parameters:asset_args:company_timezone::text != 'null' then 1 else 0 end +
  case when parameters:asset_args:custom_name is not null and parameters:asset_args:custom_name::text != 'null' and len(parameters:asset_args:custom_name) < 36 then 1 else 0 end +
  case when parameters:asset_args:description is not null and parameters:asset_args:description::text != 'null' then 1 else 0 end +
  case when parameters:asset_args:dot_number_id is not null and parameters:asset_args:dot_number_id::text != 'null' then 1 else 0 end +
  case when parameters:asset_args:driver_name is not null and parameters:asset_args:driver_name::text != 'null' then 1 else 0 end +
  case when parameters:asset_args:equipment_class_id is not null and parameters:asset_args:equipment_class_id::text != 'null' then 1 else 0 end +
  case when parameters:asset_args:equipment_make_id is not null and parameters:asset_args:equipment_make_id::text != 'null' then 1 else 0 end +
  case when parameters:asset_args:equipment_model_id is not null and parameters:asset_args:equipment_model_id::text != 'null' then 1 else 0 end +
  case when parameters:asset_args:hours is not null and parameters:asset_args:hours::text != 'null' then 1 else 0 end +
  case when parameters:asset_args:location_id is not null and parameters:asset_args:location_id::text != 'null' then 1 else 0 end +
  case when parameters:asset_args:location_name is not null and parameters:asset_args:location_name::text != 'null' then 1 else 0 end +
  case when parameters:asset_args:maintenance_group_id is not null and parameters:asset_args:maintenance_group_id::text != 'null' then 1 else 0 end +
  case when parameters:asset_args:model is not null and parameters:asset_args:model::text != 'null' then 1 else 0 end +
  case when parameters:asset_args:name is not null and parameters:asset_args:name::text != 'null' then 1 else 0 end +
  case when parameters:asset_args:odometer is not null and parameters:asset_args:odometer::text != 'null' then 1 else 0 end +
  case when parameters:asset_args:photo_id is not null and parameters:asset_args:photo_id::text != 'null' then 1 else 0 end +
  case when parameters:asset_args:placed_in_service is not null and parameters:asset_args:placed_in_service::text != 'null' then 1 else 0 end +
  case when parameters:asset_args:serial_number is not null and parameters:asset_args:serial_number::text != 'null' then 1 else 0 end +
  case when parameters:asset_args:tracker_id is not null and parameters:asset_args:tracker_id::text != 'null' then 1 else 0 end +
  --case when parameters:asset_args:user_id is not null and parameters:asset_args:user_id::text != 'null' then 1 else 0 end +
  case when parameters:asset_args:vin is not null and parameters:asset_args:vin::text != 'null' then 1 else 0 end +
  case when parameters:asset_args:year is not null and parameters:asset_args:year::text != 'null' then 1 else 0 end as columns_completed,
  datediff(seconds,lag(ca.date_created,1) over (partition by ca.user_id order by ca.date_created asc), ca.date_created) as time_diff
from command_audit ca
left join
    bulk_add_users bau on bau.user_id = ca.user_id and bau.added_date = ca.date_created::date
left join
    users u on ca.user_id = u.user_id
left join
    companies c on c.company_id = u.company_id
where convert_timezone('America/Chicago', ca.date_created) >= /*dateadd('month', -6, current_date)*/ date('2023-01-01')
and command = 'CreateAsset'
and parameters:asset_args:asset_type_id::number = 2
)
select
    ec.command_audit_id,
    ec.asset_id,
    ec.user,
    ec.company,
    ec.asset_owner,
    ec.asset_type,
    case
        when ec.possible_bulk_upload = 'Y' and ec.time_diff <= 1 then 'Bulk Asset Upload'
        else 'Normal Upload'
    end as asset_add_type,
    ec.possible_error_in_upload,
    ec.created_date,
    ec.columns_completed
from
    equipment_columns ec
where
  ec.created_date between
  {% date_start date_filter %} and
  {% date_end date_filter %}
union
select
    vc.command_audit_id,
    vc.asset_id,
    vc.user,
    vc.company,
    vc.asset_owner,
    vc.asset_type,
    case
        when vc.possible_bulk_upload = 'Y' and vc.time_diff <= 1 then 'Bulk Asset Upload'
        else 'Normal Upload'
    end as asset_add_type,
    vc.possible_error_in_upload,
    vc.created_date,
    vc.columns_completed
from
    vehicle_columns vc
where
  vc.created_date between
  {% date_start date_filter %} and
  {% date_end date_filter %}
            ;;
  }

  dimension: command_audit_id {
    type: number
    sql: ${TABLE}."COMMAND_AUDIT_ID" ;;
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

  dimension_group: created_date {
    type: time
    sql: ${TABLE}."CREATED_DATE" ;;
  }

  dimension: columns_completed {
    label: "Fields Completed"
    type: number
    sql: ${TABLE}."COLUMNS_COMPLETED" ;;
  }

  measure: asset_count {
    type: count_distinct
    sql: ${asset_id} ;;
    drill_fields: [detail*]
  }

  measure: max_columns_completed {
    type: max
    sql: ${columns_completed} ;;
  }

  measure: minimum_columns_completed {
    type: min
    sql: ${columns_completed} ;;
  }

  set: detail {
    fields: [
      asset_id,
      user,
      company,
      asset_owner,
      asset_type,
      asset_add_type,
      created_date_date
    ]
  }

  filter: date_filter {
    type: date_time
  }

}
