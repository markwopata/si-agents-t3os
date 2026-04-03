view: organizations_list_agg {
  derived_table: {
    sql: select * from business_intelligence.triage.stg_t3__organizations_list_agg
    where company_id = {{ _user_attributes['company_id'] }}::numeric;;
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

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  set: detail {
    fields: [
      asset_id,
      company_id,
      name
    ]
  }
}
