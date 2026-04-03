view: payment_application_reversal_reasons {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."PAYMENT_APPLICATION_REVERSAL_REASONS" ;;

dimension: payment_application_reversal_reason_id {
  type: string
  sql: ${TABLE}."PAYMENT_APPLICATION_REVERSAL_REASON_ID" ;;
}

dimension: active {
  type: string
  sql: ${TABLE}."ACTIVE" ;;
}

dimension: description {
  type: string
  label: "Reversal Reason"
  sql: ${TABLE}."DESCRIPTION" ;;
}


}
