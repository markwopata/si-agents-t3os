view: approved_invoices_by_ap_user {

  sql_table_name: "CONCUR"."APPROVED_INVOICES_BY_AP_USER"
    ;;


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
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }

  dimension: ap_user_email {
    type: string
    sql: ${TABLE}."AP_USER_EMAIL" ;;
  }

  dimension: ap_user_name {
    type: string
    sql: ${TABLE}."AP_USER_NAME" ;;
  }

  dimension: approval_status {
    type: string
    sql: ${TABLE}."APPROVAL_STATUS" ;;
  }

  dimension_group: cognos {
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
    sql: ${TABLE}."COGNOS_DATE" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension_group: final_approval {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."FINAL_APPROVAL_DATE" ;;
  }

  dimension: header_po_number {
    type: string
    sql: ${TABLE}."HEADER_PO_NUMBER" ;;
  }

  dimension_group: invoice {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."INVOICE_DATE" ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }

  dimension_group: invoice_received {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."INVOICE_RECEIVED_DATE" ;;
  }

  dimension_group: last_submit {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."LAST_SUBMIT_DATE" ;;
  }

  dimension: request_currency {
    type: string
    sql: ${TABLE}."REQUEST_CURRENCY" ;;
  }

  dimension: request_id {
    type: string
    sql: ${TABLE}."REQUEST_ID" ;;
  }

  dimension: request_total {
    type: number
    sql: ${TABLE}."REQUEST_TOTAL" ;;
  }

  dimension: shipping_amount {
    type: number
    sql: ${TABLE}."SHIPPING_AMOUNT" ;;
  }

  dimension: tax_amount {
    type: number
    sql: ${TABLE}."TAX_AMOUNT" ;;
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension: fleet_non_fleet {
    type: string
    sql: CASE WHEN ${ap_user_name} in
('Kingsley, Bethany',
'Fulton, Cindy',
'Woodruff, Haley',
'Romero, Marilyn',
'Davenport, Mary',
'Ferguson, Rachel',
'Sobba, Robin',
'Lawe, Tracie'
) then 'fleet'

when ${ap_user_name} in
('Hartz, Andrea',
'Morales, Carlos Fiallo',
'Tubbs, Edith',
'Meketsy, Ellyn',
'Bonney, Lindsay',
'Falcone, Madison',
'Allen, Misty',
'Drummond, Mylin',
'Johnson, Raeshashan'
) then 'non_fleet'

else 'other' end;;
  }



  measure: count {
    type: count
    drill_fields: [ap_user_name]
  }

  }
