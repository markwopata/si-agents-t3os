# view: admin_t3_mismatches {
  # # You can specify the table name if it's different from the view name:
  # sql_table_name: my_schema_name.tester ;;
  #
  # # Define your dimensions and measures here, like this:
  # dimension: user_id {
  #   description: "Unique ID for each user that has ordered"
  #   type: number
  #   sql: ${TABLE}.user_id ;;
  # }
  #
  # dimension: lifetime_orders {
  #   description: "The total number of orders for each user"
  #   type: number
  #   sql: ${TABLE}.lifetime_orders ;;
  # }
  #
  # dimension_group: most_recent_purchase {
  #   description: "The date when each user last ordered"
  #   type: time
  #   timeframes: [date, week, month, year]
  #   sql: ${TABLE}.most_recent_purchase_at ;;
  # }
  #
  # measure: total_lifetime_orders {
  #   description: "Use this for counting lifetime orders across many users"
  #   type: sum
  #   sql: ${lifetime_orders} ;;
  # }

 view: admin_t3_mismatches {

  derived_table: {
    sql:
with x as (
  select
    a.asset_id,

    -- RAW VALUES
    a.serial as serial_ft_raw,
    b.serial_number as serial_admin_raw,
    a.vin as vin_ft_raw,
    b.vin as vin_admin_raw,

    -- NORMALIZED VALUES (used for comparison)
    nullif(trim(a.serial), '') as serial_ft_norm,
    nullif(trim(b.serial_number), '') as serial_admin_norm,
    nullif(trim(a.vin), '') as vin_ft_norm,
    nullif(trim(b.vin), '') as vin_admin_norm,

    -- SPACE-MARKED VALUES (diagnostic only)
    regexp_replace(a.serial, '^(\\s+)|(\\s+)$', 'space') as serial_ft_spaces,
    regexp_replace(b.serial_number, '^(\\s+)|(\\s+)$', 'space') as serial_admin_spaces,
    regexp_replace(a.vin, '^(\\s+)|(\\s+)$', 'space') as vin_ft_spaces,
    regexp_replace(b.vin, '^(\\s+)|(\\s+)$', 'space') as vin_admin_spaces

  from es_warehouse.public.company_purchase_order_line_items a
  join es_warehouse.public.assets b
    on a.asset_id = b.asset_id
)

select
  asset_id as asset_id_ft_lines,

  -- SHOW SPACE-MARKED VALUES SO ISSUES ARE VISIBLE
  serial_ft_spaces as serial_ft_lines,
  serial_admin_spaces as serial_admin,
  vin_ft_spaces as ft_vin,
  vin_admin_spaces as admin_vin,

  case
    when serial_ft_norm is null and serial_admin_norm is null then 'mismatch'
    when serial_ft_norm is distinct from serial_admin_norm then 'mismatch'
    else 'match'
  end as serial_status,

  case
    when vin_ft_norm is null and vin_admin_norm is null then 'mismatch'
    when vin_ft_norm is distinct from vin_admin_norm then 'mismatch'
    else 'match'
  end as vin_status,

  case
    when vin_ft_norm is null and serial_admin_norm is null then 'mismatch'
    when vin_ft_norm is distinct from serial_admin_norm then 'mismatch'
    else 'match'
  end as vin_serial_status

from x

where serial_status <> 'match' and vin_status <> 'match' and vin_serial_status <> 'match'
      ;;
  }
#
#   # Define your dimensions and measures here, like this:
#   dimension: user_id {
#     description: "Unique ID for each user that has ordered"
#     type: number
#     sql: ${TABLE}.user_id ;;
#   }
#
  dimension: asset_id_ft_lines {
    label: "Asset ID FT"
    type: string
    sql: ${TABLE}.asset_id_ft_lines ;;
  }
  dimension: serial_ft_lines {
    label: "Serial FT"
    type: string
    sql: ${TABLE}.serial_ft_lines ;;
  }
  dimension: serial_admin {
    label: "Serial Admin"
    type: string
    sql: ${TABLE}.serial_admin ;;
  }

  dimension: vin_ft_lines {
    label: "Vin FT"
    type: string
    sql: ${TABLE}.ft_vin ;;
  }
  dimension: admin_vin {
    label: "Vin Admin"
    type: string
    sql: ${TABLE}.admin_vin ;;
  }
  dimension: serial_status {
    label: "Serial to Serial"
    type: string
    sql: ${TABLE}.serial_status ;;
  }
  dimension: vin_status {
    label: "Vin to Vin"
    type: string
    sql: ${TABLE}.vin_status ;;
  }
  dimension: vin_serial_status {
    label: "Vin FT to Admin Serial"
    type: string
    sql: ${TABLE}.vin_serial_status ;;
  }
#
#   dimension_group: most_recent_purchase {
#     description: "The date when each user last ordered"
#     type: time
#     timeframes: [date, week, month, year]
#     sql: ${TABLE}.most_recent_purchase_at ;;
#   }
#
#   measure: total_lifetime_orders {
#     description: "Use this for counting lifetime orders across many users"
#     type: sum
#     sql: ${lifetime_orders} ;;
#   }
 }
