view: selection_of_all_assets {
  derived_table: {
    sql:
      select
        asset_id
      from
        assets
      where
        deleted = FALSE
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset_id_string {
    type: string
    sql: ${asset_id} ;;
  }

  set: detail {
    fields: [asset_id]
  }
}
