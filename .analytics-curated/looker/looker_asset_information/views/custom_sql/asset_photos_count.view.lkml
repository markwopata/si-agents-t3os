view: asset_photos_count {
  derived_table: {
    sql: SELECT ap.asset_id, a.company_id, c.name as company_name, COUNT(*) AS photo_count
      FROM es_warehouse.public.asset_photos ap
      JOIN es_warehouse.public.assets a ON a.asset_id = ap.asset_id
      JOIN es_warehouse.public.companies c ON c.company_id = a.company_id
      WHERE a.company_id NOT IN (420, 16184)
      GROUP BY ap.asset_id, a.company_id, c.name
      HAVING COUNT(*) > 1 ORDER BY c.name DESC ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: photo_count {
    type: number
    sql: ${TABLE}."PHOTO_COUNT" ;;
  }

  set: detail {
    fields: [
      asset_id,
      company_id,
      company_name,
      photo_count
    ]
  }
}
