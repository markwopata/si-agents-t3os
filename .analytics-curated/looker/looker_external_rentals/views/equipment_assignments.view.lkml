view: equipment_assignments {
  sql_table_name: "PUBLIC"."EQUIPMENT_ASSIGNMENTS"
    ;;
  drill_fields: [equipment_assignment_id]

  dimension: equipment_assignment_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."EQUIPMENT_ASSIGNMENT_ID" ;;
  }

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension_group: date_created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: date_updated {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: drop_off_delivery_id {
    type: number
    sql: ${TABLE}."DROP_OFF_DELIVERY_ID" ;;
  }

  dimension_group: end {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."END_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: rental_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."RENTAL_ID" ;;
    value_format_name: id
  }

  dimension: return_delivery_id {
    type: number
    sql: ${TABLE}."RETURN_DELIVERY_ID" ;;
  }

  dimension_group: start {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."START_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: scheduled_off_rent_date {
    type: date
    sql: ${end_date} ;;
  }

  measure: count {
    type: count
    drill_fields: [equipment_assignment_id, rentals.rental_id]
  }

  measure: on_rent_count {
    type: count
    drill_fields: [on_rent_rental_kpi*]
  }

  dimension: rental_status {
    type: string
    sql: case when ${end_date} <= current_date then 'Off Rent' else 'On Rent' end ;;
  }

  dimension: asset_reserved {
    type: yesno
    sql: ${end_date} is null and ${start_raw} > current_timestamp ;;
  }

  measure: reservation_count {
    type: count
    filters: [asset_reserved: "Yes"]
  }

  set: on_rent_rental_kpi {
    fields: [rentals.rental_id, assets.custom_name_make_model, locations.location_groups, purchase_orders.name, assets.asset_class, users.ordered_by, start_date, scheduled_off_rent_date, admin_cycle.end_this_rental_cycle_date, delivery_location.delivery_address, remaining_rental_cost.to_date_rental_spend]
  }
}
