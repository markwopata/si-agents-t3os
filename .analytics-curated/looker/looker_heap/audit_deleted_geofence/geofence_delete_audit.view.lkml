
view: geofence_delete_audit {
  derived_table: {
    sql:
    with geofence_api_info as (
    select
          api.time,
          api.request_type,
          SPLIT_PART(api.endpoint_url, '/', 1) as endpoint_type,
          SPLIT_PART(api.endpoint_url, '/', 2) as endpoint_value,
          api.endpoint_url,
          u.identity,
          u.company_name
      from
          non_prod_business_data_vault.heap_t3_platform_production_heap.tbl_fleet_api_kernel_rest_response api
          JOIN non_prod_business_data_vault.heap_t3_platform_production_heap.tbl_users u on u.user_id = api.user_id
      where
          request_type = 'delete'
          AND SPLIT_PART(endpoint_url, '/', 1) = 'geofences'
      )
      select
        time,
        request_type,
        endpoint_type,
        endpoint_value,
        endpoint_url,
        g.name as geofence,
        identity,
        company_name,
        g.geofence_id
      from
        geofence_api_info gapi
        join es_warehouse.public.geofences g on g.geofence_id::text = gapi.endpoint_value::text
          ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension_group: time {
    type: time
    sql: ${TABLE}."TIME" ;;
  }

  dimension: request_type {
    type: string
    sql: ${TABLE}."REQUEST_TYPE" ;;
  }

  dimension: endpoint_type {
    type: string
    sql: ${TABLE}."ENDPOINT_TYPE" ;;
  }

  dimension: endpoint_value {
    type: string
    sql: ${TABLE}."ENDPOINT_VALUE" ;;
  }

  dimension: endpoint_url {
    type: string
    sql: ${TABLE}."ENDPOINT_URL" ;;
  }

  dimension: geofence {
    type: string
    sql: ${TABLE}."GEOFENCE" ;;
  }

  dimension: identity {
    label: "Identity - User Name (User ID)"
    type: string
    sql: ${TABLE}."IDENTITY" ;;
  }

  dimension: company_name {
    label: "Company"
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: geofence_id {
    type: number
    sql: ${TABLE}."GEOFENCE_ID" ;;
    value_format_name: id
  }

  dimension: time_formatted_date {
    group_label: "HTML Formatted Time"
    label: "Date"
    type: date
    sql: ${time_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: time_formatted_datetime {
    group_label: "HTML Formatted Time"
    label: "Date Time"
    type: date_time
    sql: convert_timezone('America/Chicago',${time_raw}) ;;
    html: {{ rendered_value | date: "%b %d, %Y %r"  }} CST;;
  }

  set: detail {
    fields: [
        time_time,
  request_type,
  endpoint_type,
  endpoint_value,
  endpoint_url,
  identity,
  company_name
    ]
  }
}
