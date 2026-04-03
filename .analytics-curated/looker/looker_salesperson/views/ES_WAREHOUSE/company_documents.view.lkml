view: company_documents {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."COMPANY_DOCUMENTS"
    ;;
  drill_fields: [company_document_id]

  dimension: company_document_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."COMPANY_DOCUMENT_ID" ;;
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

  dimension: company_document_type_id {
    type: number
    # hidden: yes
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
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: extended_data {
    type: string
    sql: ${TABLE}."EXTENDED_DATA" ;;
  }

  dimension: file_name {
    type: string
    sql: ${TABLE}."FILE_NAME" ;;
  }

  dimension: file_path {
    type: string
    sql: ${TABLE}."FILE_PATH" ;;
  }

  dimension: notes {
    type: string
    sql: ${TABLE}."NOTES" ;;
  }

  dimension: original_file_name {
    type: string
    sql: ${TABLE}."ORIGINAL_FILE_NAME" ;;
  }

  dimension_group: valid_from {
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
    sql: CAST(${TABLE}."VALID_FROM" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: valid_until {
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
    sql: CAST(${TABLE}."VALID_UNTIL" AS TIMESTAMP_NTZ) ;;
  }

  dimension: voided {
    type: yesno
    sql: ${TABLE}."VOIDED" ;;
  }

  dimension: date_before_today {
    type: yesno
    sql: ${valid_until_date} < current_date ;;
  }

  dimension: expiring_next_90_days {
    type: yesno
    sql: ${valid_until_date} between current_date() and current_date() + interval '90 day' ;;
  }

  # measure: expiring_icon {
  #   sql: ${expiring_next_90_days} ;;
  #   html: {% if value == 'yes'}
  #         <p>&#128196;</p>
  #         {% else %}
  #         <p>''</p>
  #         {% endif %} ;;
  # }

  measure: count {
    type: count
    drill_fields: [company_document_id, original_file_name, file_name, company_document_types.company_document_type_id, company_document_types.name]
  }
}
