view: asset_files_custom {
  derived_table: {
    sql: select af.asset_id, original_filename as filename, size_bytes, a.company_id, c.name as company_name
      from es_warehouse.public.asset_files af
      join es_warehouse.public.assets a on af.asset_id = a.asset_id
      join es_warehouse.public.companies c on c.company_id = a.company_id
      where a.company_id not in (420, 16184) ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: filename {
    type: string
    sql: ${TABLE}."FILENAME" ;;
  }

  dimension: size_bytes {
    type: number
    sql: ${TABLE}."SIZE_BYTES" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  set: detail {
    fields: [
      asset_id,
      filename,
      size_bytes,
      company_id,
      company_name
    ]
  }
}
