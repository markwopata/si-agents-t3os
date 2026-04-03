view: collections_actuals {
  sql_table_name: "ANALYTICS"."TREASURY"."COLLECTIONS_ACTUALS_PAYMENTS" ;;

################## PRIMARY KEY ##################
  dimension: key {
    type: string
    primary_key: yes
    sql: ${TABLE}."MONTH_"||'-'||${TABLE}."INVOICE_NO" ;;
  }

################## DATES ##################

  dimension_group: month_ {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."MONTH_" ;; }

  #dimension: month_num {
  #  type: number
  #  sql: MONTH(${TABLE}."MONTH_") ;;
  #}

  dimension: due_date {
    type: date
    sql: ${TABLE}."DUE_DATE" ;;
  }

  #dimension: sent_to_legal_month {
  #  type: date
  #  sql: ${TABLE}."SENT_TO_LEGAL_MONTH" ;;
  #}

  #dimension: returned_from_legal_month {
  #  type: date
  #  sql: ${TABLE}."RETURNED_FROM_LEGAL_MONTH" ;;
  #}

  dimension: due_date_formatted {
    group_label: "HTML Formatted Date"
    label: "Due Date"
    type: date
    sql: ${due_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }



  ################## DIMENSIONS ##################

  dimension: invoice_no {
    type: string
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  #dimension: asset_id {
  #  type: string
  #  sql: ${TABLE}."ASSET_ID" ;;
  #}

  dimension: salesperson_user_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: salesperson_name {
    type: string
    sql: ${TABLE}."SALESPERSON_NAME" ;;
  }

  dimension: customer_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }

  dimension: customer_name {
     type: string
     sql: ${TABLE}."CUSTOMER_NAME" ;;
   }

  dimension: branch_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: branch_name {
    type: string
    sql: ${TABLE}."BRANCH_NAME" ;;
  }

  dimension: region_district {
    type: string
    sql: ${TABLE}."REGION_DISTRICT" ;;
  }

  #dimension: collector {
  #  type: string
  #  sql: ${TABLE}."COLLECTOR" ;;
  #}

  #dimension: legal_flag {
  #  type: string
  #  sql: ${TABLE}."LEGAL_FLAG" ;;
  #}

  #dimension: age {
  #  type: number
  #  sql: ${TABLE}."AGE" ;;
  #}

  #dimension: own_program {
  #  type: number
  #  sql: ${TABLE}."OWN_PROGRAM" ;;
  #}

################## MEASURES ##################

  measure: collections {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."PAYMENT_AMOUNT" ;;
    drill_fields: [invoice_detail*]
  }



  set: invoice_detail {
    fields: [branch_name, salesperson_name, invoice_no, due_date_formatted]
  }

}
