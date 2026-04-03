view: company_documents {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."COMPANY_DOCUMENTS" ;;
  drill_fields: [company_document_id]

  dimension: company_document_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."COMPANY_DOCUMENT_ID" ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: company_document_type_id {
    type: number
    sql: ${TABLE}."COMPANY_DOCUMENT_TYPE_ID" ;;
  }
  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }
  dimension: created_by_user_id {
    type: number
    sql: ${TABLE}."CREATED_BY_USER_ID" ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_reviewed {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_REVIEWED" ;;
  }
  dimension_group: date_updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_UPDATED" ;;
  }
  dimension: extended_data {
    type: string
    sql: ${TABLE}."EXTENDED_DATA" ;;
  }
  dimension: file_md5_hash {
    type: string
    sql: ${TABLE}."FILE_MD5_HASH" ;;
  }
  dimension: file_name {
    type: string
    sql: ${TABLE}."FILE_NAME" ;;
  }
  dimension: file_path {
    type: string
    sql: ${TABLE}."FILE_PATH" ;;
  }
  dimension: malware_scan_status {
    type: string
    sql: ${TABLE}."MALWARE_SCAN_STATUS" ;;
  }
  dimension: notes {
    type: string
    sql: ${TABLE}."NOTES" ;;
  }
  dimension: original_file_name {
    type: string
    sql: ${TABLE}."ORIGINAL_FILE_NAME" ;;
  }
  dimension: reviewed_by_user_id {
    type: number
    sql: ${TABLE}."REVIEWED_BY_USER_ID" ;;
  }
  dimension: s3_bucket {
    type: string
    sql: ${TABLE}."S3_BUCKET" ;;
  }
  dimension: status_id {
    type: number
    sql: ${TABLE}."STATUS_ID" ;;
  }
  dimension_group: valid_from {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."VALID_FROM" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: valid_until {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."VALID_UNTIL" AS TIMESTAMP_NTZ) ;;
  }
  dimension: max_valid_insurance_until {
    label: "Valid Until Date"
    type: date
    required_fields: [company_id]
    sql: (
          SELECT MAX(CAST(cd2.valid_until AS DATE))
          FROM "ES_WAREHOUSE"."PUBLIC"."COMPANY_DOCUMENTS" cd2
          WHERE cd2.company_id = ${company_id} and cd2.voided = 'FALSE'
        ) ;;
  }
  dimension: valid_insurance {
    type: yesno
    sql:current_date() <= ${max_valid_insurance_until}
  ;;
  }
  dimension: voided {
    type: yesno
    sql: ${TABLE}."VOIDED" ;;
  }
  measure: count {
    type: count
    drill_fields: [company_document_id, original_file_name, file_name]
  }
}
