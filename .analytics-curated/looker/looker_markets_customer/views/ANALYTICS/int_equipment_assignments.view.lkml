
view: int_equipment_assignments {
  sql_table_name: analytics.assets.int_equipment_assignments ;;


  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: equipment_assignment_id {
    type: string
    sql: ${TABLE}."EQUIPMENT_ASSIGNMENT_ID" ;;
  }

  dimension: asset_id {
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: rental_id {
    type: string
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: is_intercompany {
    type: yesno
    sql: ${TABLE}."IS_INTERCOMPANY" ;;
  }

  dimension: drop_off_delivery_id {
    type: string
    sql: ${TABLE}."DROP_OFF_DELIVERY_ID" ;;
  }

  dimension: return_delivery_id {
    type: string
    sql: ${TABLE}."RETURN_DELIVERY_ID" ;;
  }

  dimension_group: date_start {
    type: time
    sql: ${TABLE}."DATE_START" ;;
  }

  dimension_group: next_date_start {
    type: time
    sql: ${TABLE}."NEXT_DATE_START" ;;
  }

  dimension_group: date_end {
    type: time
    sql: ${TABLE}."DATE_END" ;;
  }

  dimension_group: date_end_cleaned {
    type: time
    sql: case when ${date_end_date} = '9999-12-31' then CURRENT_DATE() else ${date_end_date} end;;
  }

  dimension: is_current_on_rent {
    hidden: yes
    type: yesno
    sql: ${date_end_cleaned_date} = CURRENT_DATE() ;;
  }


  dimension: rental_dates_html {
    type: string
    sql: ${date_start_date} ;;
    html: <b>Rental Start:</b> {{date_start_date._rendered_value}}
      <br />
      <b>Rental End:</b>
      {% if is_current_on_rent._value == "Yes" %}
        On Rent
      {% else %}
        {{date_end_cleaned_date._rendered_value}}
      {% endif %} ;;
  }

  dimension_group: date_created {
    type: time
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension_group: date_updated {
    type: time
    sql: ${TABLE}."DATE_UPDATED" ;;
  }

  dimension: rental_duration {
    type: number
    sql: ${TABLE}."RENTAL_DURATION" ;;
    description: "Minutes between date_start and date_end"
  }

  dimension: is_last_assignment_on_day {
    type: yesno
    sql: ${TABLE}."IS_LAST_ASSIGNMENT_ON_DAY" ;;
  }

  dimension: days_diff {
    type: number
    sql: DATEDIFF('day', ${date_start_date}, ${date_end_cleaned_date});;
  }

  dimension_group: _es_update_timestamp {
    type: time
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }

  measure: avg_days_diff {
    type: average
    sql: ${days_diff};;
    value_format: "0"
  }

  set: detail {
    fields: [
        equipment_assignment_id,
  asset_id,
  rental_id,
  is_intercompany,
  drop_off_delivery_id,
  return_delivery_id,
  date_start_time,
  next_date_start_time,
  date_end_time,
  date_created_time,
  date_updated_time,
  rental_duration,
  is_last_assignment_on_day,
  _es_update_timestamp_time
    ]
  }
}
