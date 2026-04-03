view: company_document_types {
  derived_table: {
    sql: with al_hapd_extra as (
  select *
  from
  (values (123456, 'AL/HAPD', '2024-02-09 09:07:00.000'))
  )

  select
  company_document_type_id,
  name,
  _es_update_timestamp
  from ES_WAREHOUSE.PUBLIC.COMPANY_DOCUMENT_TYPES

  UNION

  select
  column1 as COMPANY_DOCUMENT_TYPE_ID
  , column2 as NAME
  , column3 as _ES_UPDATE_TIMESTAMP
  from al_hapd_extra
    ;;
     }
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
