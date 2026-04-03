view: coi_expiration_info {
  # # This is a view for COI expiration information.# sql_table_name: my_schema_name.tester
  derived_table: { sql:
    select
    COMPANY_DOCUMENTS.COMPANY_ID,
    COMPANY_DOCUMENT_TYPES.NAME as INS_TYPE,
    COMPANY_DOCUMENTS.COMPANY_DOCUMENT_TYPE_ID,
    CAST(COMPANY_DOCUMENTS.VALID_UNTIL as DATE) as INS_VALID_UNTIL,
    case when CAST(COMPANY_DOCUMENTS.VALID_UNTIL as DATE) < GETDATE() THEN 'YES' else 'NO' end as EXPIRED
  from ES_WAREHOUSE.PUBLIC.COMPANY_DOCUMENTS
  LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANY_DOCUMENT_TYPES
  ON COMPANY_DOCUMENT_TYPES.COMPANY_DOCUMENT_TYPE_ID = COMPANY_DOCUMENTS.COMPANY_DOCUMENT_TYPE_ID
  where COMPANY_DOCUMENTS.COMPANY_DOCUMENT_TYPE_ID IN (1,3) and COMPANY_DOCUMENTS.VOIDED != 'NO';;
  }

dimension: company_id {
  primary_key: yes
  type: number
  sql: ${TABLE}."COMPANY_ID" ;;
  }

dimension: insurance_type {
  type: string
  sql: ${TABLE}."INS_TYPE" ;;
  }

dimension_group: expiration_date {
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
  sql: CAST(${TABLE}."INS_VALID_UNTIL" AS TIMESTAMP_NTZ) ;;
  }

dimension: expired {
  type: yesno
  sql: ${TABLE}."EXPIRED" ;;
  }
}
