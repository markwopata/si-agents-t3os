view: line_item_types {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."LINE_ITEM_TYPES" ;;


  dimension: line_item_type_id {
    type: number
    sql: ${TABLE}."LINE_ITEM_TYPE_ID" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: stackable {
    type: yesno
    sql: ${TABLE}."STACKABLE" ;;
  }

  dimension: tax_code_id {
    type: number
    sql: ${TABLE}."TAX_CODE_ID" ;;
  }

  dimension: invoice_display_name {
    type: string
    sql: ${TABLE}."INVOICE_DISPLAY_NAME" ;;
  }

  dimension: active {
    type:  yesno
    sql: ${TABLE}."ACTIVE" ;;
  }

  dimension: fixed_amount {
    type:  number
    sql: ${TABLE}."FIXED_AMOUNT" ;;
  }



}
