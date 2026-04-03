view: concur_invoice_comments {
  sql_table_name: "CONCUR_GOLD"."CONCUR_INVOICE_COMMENTS" ;;

  dimension: comment {
    type: string
    sql: ${TABLE}."COMMENT" ;;
  }
  dimension: fk_request_key {
    type: number
    sql: ${TABLE}."FK_REQUEST_KEY" ;;
  }
  dimension: id_vendor {
    type: string
    sql: ${TABLE}."ID_VENDOR" ;;
  }
  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }
  dimension: name_commenter {
    type: string
    sql: ${TABLE}."NAME_COMMENTER" ;;
  }
  dimension: name_request {
    type: string
    sql: ${TABLE}."NAME_REQUEST" ;;
  }
  dimension: po_number {
    type: string
    sql: ${TABLE}."PO_NUMBER" ;;
  }
  dimension: timestamp_comment {
    type: string
    sql: ${TABLE}."TIMESTAMP_COMMENT" ;;
  }
  measure: count {
    type: count
  }
}
