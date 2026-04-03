
view: geofence_name_count {
  derived_table: {
    sql: select name from es_warehouse.public.geofences where company_id not in (1854,10859,16184,420,155,23515) ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  # dimension: total {
  #   type: number
  #   sql: ${TABLE}."TOTAL" ;;
  # }

  set: detail {
    fields: [
        name
    ]
  }
}
