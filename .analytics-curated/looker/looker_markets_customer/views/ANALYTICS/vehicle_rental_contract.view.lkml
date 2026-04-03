view: vehicle_rental_contract {
  sql_table_name: "PUBLIC"."VEHICLE_RENTAL_CONTRACT"
    ;;

  dimension: agreement_id {
    type: string
    sql: ${TABLE}."AGREEMENT_ID" ;;
    primary_key: yes
  }

  dimension: agreement_name {
    type: string
    sql: ${TABLE}."AGREEMENT_NAME" ;;
  }

  dimension: agreement_number {
    type: number
    sql: ${TABLE}."AGREEMENT_NUMBER" ;;
  }

  dimension: agreement_status {
    type: string
    sql: ${TABLE}."AGREEMENT_STATUS" ;;
  }

  dimension: billing_address {
    type: string
    sql: ${TABLE}."BILLING_ADDRESS" ;;
  }

  dimension: branch_email {
    type: string
    sql: ${TABLE}."BRANCH_EMAIL" ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}."CITY" ;;
  }

  dimension: company_email {
    type: string
    sql: ${TABLE}."COMPANY_EMAIL" ;;
  }

  dimension_group: created {
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
    sql: ${TABLE}."CREATED_DATE" ;;
  }

  dimension: display_date {
    type: string
    sql: ${TABLE}."DISPLAY_DATE" ;;
  }

  dimension: etag {
    type: string
    sql: ${TABLE}."ETAG" ;;
  }

  dimension: fax {
    type: string
    sql: ${TABLE}."FAX" ;;
  }

  dimension_group: last_checked {
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
    sql: ${TABLE}."LAST_CHECKED_DATE" ;;
  }

  dimension_group: last_event {
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
    sql: ${TABLE}."LAST_EVENT_DATE" ;;
  }

  dimension: lessee_name {
    type: string
    sql: ${TABLE}."LESSEE_NAME" ;;
  }

  dimension: order_id {
    type: number
    value_format: "0"
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension: pdf_download_state {
    type: string
    sql: ${TABLE}."PDF_DOWNLOAD_STATE" ;;
  }

  dimension: pdf_url {
    type:  string
    html: <font color="blue "><u><a href="{{ vehicle_rental_contract.pdf_url._value }}" target="_blank">Contract PDF</a></font></u> ;;
    sql: ${TABLE}."PDF_URL" ;;
  }

  dimension: phone {
    type: string
    sql: ${TABLE}."PHONE" ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  dimension: transient_document_id {
    type: string
    sql: ${TABLE}."TRANSIENT_DOCUMENT_ID" ;;
  }

  dimension: usdot {
    type: string
    sql: ${TABLE}."USDOT" ;;
  }

  dimension: user_email {
    type: string
    sql: ${TABLE}."USER_EMAIL" ;;
  }

  dimension: user_name {
    type: string
    sql: ${TABLE}."USER_NAME" ;;
  }

  dimension: zip {
    type: zipcode
    sql: ${TABLE}."ZIP" ;;
  }

  measure: order_count {
    type: count_distinct
    sql: ${agreement_id} ;;
  }

  measure: dashboard_link {
    type:  string
    sql:  'https://equipmentshare.looker.com/dashboards-next/202' ;;
    html: <u><a href="{{value}}" target="_blank">On-Road Rental Dashboard</a></u> ;;
  }
}
