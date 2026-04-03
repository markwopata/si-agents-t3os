view: company_document_types {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."COMPANY_DOCUMENT_TYPES"
    ;;
  drill_fields: [company_document_type_id]

  dimension: company_document_type_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."COMPANY_DOCUMENT_TYPE_ID" ;;
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

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  measure: count {
    type: count
    drill_fields: [company_document_type_id, name, company_documents.count]
  }
}
