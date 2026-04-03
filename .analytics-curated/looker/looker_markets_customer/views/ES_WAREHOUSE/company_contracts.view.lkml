view: company_contracts {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."COMPANY_CONTRACTS" ;;
  drill_fields: [company_contract_id]

  dimension: company_contract_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."COMPANY_CONTRACT_ID" ;;
  }
  dimension_group: _es_load_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_LOAD_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }
  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."CREATED_DATE" ;;
  }
  dimension_group: date_signed {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_SIGNED" ;;
  }
  dimension: docusign_template_update_id {
    type: number
    sql: ${TABLE}."DOCUSIGN_TEMPLATE_UPDATE_ID" ;;
  }
  dimension: envelope_id {
    type: string
    sql: ${TABLE}."ENVELOPE_ID" ;;
  }
  dimension: signer_email {
    type: string
    sql: ${TABLE}."SIGNER_EMAIL" ;;
  }
  dimension: signer_id {
    type: number
    sql: ${TABLE}."SIGNER_ID" ;;
  }
  dimension: signer_name {
    type: string
    sql: ${TABLE}."SIGNER_NAME" ;;
  }
  dimension: status_id {
    type: string
    sql: ${TABLE}."STATUS_ID" ;;
  }
  dimension_group: updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."UPDATED_DATE" ;;
  }

  dimension: entry_start_date {
    group_label: "HTML Formatted Time"
    label: "Signed Date"
    type: date
    sql: ${date_signed_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  measure: count {
    type: count
    drill_fields: [company_contract_id, signer_name]
  }
}
