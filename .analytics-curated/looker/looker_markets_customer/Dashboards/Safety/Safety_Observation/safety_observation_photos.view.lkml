view: safety_observation_photos {
  sql_table_name: "ANALYTICS"."BI_OPS"."SAFETY_OBSERVATION_PHOTOS" ;;

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: sor_id {
    type: number
    sql: ${TABLE}."SOR_ID" ;;
  }

  dimension: photo {
    type: string
    sql: ${TABLE}."PHOTO" ;;
    html:
      <p><img src={{value}} height=50 width=50></p>;;
  }

  set: detail {
    fields: [
      sor_id,
      photo
    ]
  }
}
