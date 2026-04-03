view: fleet_ops_lsd_board {
  sql_table_name: "ANALYTICS"."MONDAY"."FLEET_OPS_LSD_BOARD" ;;

  dimension: asset_year {
    type: string
    sql: ${TABLE}."ASSET_YEAR" ;;
  }
  dimension: assets_owner {
    type: string
    sql: ${TABLE}."ASSETS_OWNER" ;;
  }
  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }
  dimension: customer_quote {
    type: string
    sql: ${TABLE}."CUSTOMER_QUOTE" ;;
  }
  dimension: customer_quote_needed {
    type: string
    sql: ${TABLE}."CUSTOMER_QUOTE_NEEDED" ;;
  }
  dimension: customer_signed_quote {
    type: string
    sql: ${TABLE}."CUSTOMER_SIGNED_QUOTE" ;;
  }
  dimension_group: date_complete {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_COMPLETE" ;;
  }
  dimension_group: date_customer_quote_sent_to_yard {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_CUSTOMER_QUOTE_SENT_TO_YARD" ;;
  }
  dimension_group: date_of_incident {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_OF_INCIDENT" ;;
  }
  dimension: days_since_quote_sent {
    type: string
    sql: ${TABLE}."DAYS_SINCE_QUOTE_SENT" ;;
  }
  dimension: documents_and_photos {
    type: string
    sql: ${TABLE}."DOCUMENTS_AND_PHOTOS" ;;
    html: |
          {% assign urls = value | split: "," %}
          {% for u in urls %}
            {% assign url = u | strip %}
            {% if url != "" %}
              <a href="{{ url }}" target="_blank" rel="noopener">File {{ forloop.index }}</a>
              {% unless forloop.last %}<br>{% endunless %}
            {% endif %}
          {% endfor %}
        ;;
  }
  dimension: fleet_inbox {
    type: string
    sql: ${TABLE}."FLEET_INBOX" ;;
  }
  dimension: fmv_needed {
    type: string
    sql: ${TABLE}."FMV_NEEDED" ;;
  }
  dimension: fmv_quote {
    type: string
    sql: ${TABLE}."FMV_QUOTE" ;;
  }
  dimension: gm_email {
    type: string
    sql: ${TABLE}."GM_EMAIL" ;;
  }
  dimension: ins_file_notes {
    type: string
    sql: ${TABLE}."INS_FILE_NOTES" ;;
  }
  dimension: item_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."ITEM_ID" ;;
  }
  dimension: location_of_incident {
    type: string
    sql: ${TABLE}."LOCATION_OF_INCIDENT" ;;
  }
  dimension: lsd_insurance {
    type: string
    sql: ${TABLE}."LSD_INSURANCE" ;;
  }
  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }
  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }
  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }
  dimension: non_insurance_status {
    type: string
    sql: ${TABLE}."NON_INSURANCE_STATUS" ;;
  }
  dimension: overall_status {
    type: string
    sql: ${TABLE}."OVERALL_STATUS" ;;
  }
  dimension: person {
    type: string
    sql: ${TABLE}."PERSON" ;;
  }
  dimension_group: report {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."REPORT_DATE" ;;
  }
  dimension: sales_invoice_number {
    type: string
    sql: ${TABLE}."SALES_INVOICE_NUMBER" ;;
  }
  dimension: sales_invoice_status {
    type: string
    sql: ${TABLE}."SALES_INVOICE_STATUS" ;;
  }
  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }
  dimension: subitems {
    type: string
    sql: ${TABLE}."SUBITEMS" ;;
  }
  dimension: tam_email {
    type: string
    sql: ${TABLE}."TAM_EMAIL" ;;
  }
  dimension: today {
    type: string
    sql: ${TABLE}."TODAY" ;;
  }
  dimension: total_days {
    type: string
    sql: ${TABLE}."TOTAL_DAYS" ;;
  }
  dimension: type_of_loss {
    type: string
    sql: ${TABLE}."TYPE_OF_LOSS" ;;
  }
  dimension: yard_location {
    type: string
    sql: ${TABLE}."YARD_LOCATION" ;;
  }
  dimension: days_from_lsd_designation_to_quote {
    type: number
    sql: IFF(
          TRY_TO_DATE(${insurance_lsd_board.lsd_designation_date}) IS NULL
          OR TRY_TO_DATE(${TABLE}."DATE_CUSTOMER_QUOTE_SENT_TO_YARD") IS NULL,
          NULL,
          DATEDIFF(
            day,
            TRY_TO_DATE(${insurance_lsd_board.lsd_designation_date}),
            TRY_TO_DATE(${TABLE}."DATE_CUSTOMER_QUOTE_SENT_TO_YARD")
          )
        ) ;;
    drill_fields: [details*]
  }
    dimension: days_from_quote_to_billing_approved {
    type: number
    sql: IFF(
          TRY_TO_DATE(${TABLE}."DATE_CUSTOMER_QUOTE_SENT_TO_YARD") IS NULL
          OR TRY_TO_DATE(${v_dim_dates_bi.date_date}) IS NULL,
          NULL,
          DATEDIFF(
            day,
            TRY_TO_DATE(${TABLE}."DATE_CUSTOMER_QUOTE_SENT_TO_YARD"),
            COALESCE(TRY_TO_DATE(${v_dim_dates_bi.date_date}), CURRENT_DATE)
          )
        ) ;;
    drill_fields: [details*]
  }
  measure: avg_days_from_quote_to_billing_approved {
    type: average
    value_format_name: decimal_1
    sql: ${days_from_quote_to_billing_approved} ;;
    drill_fields: [details*]
  }
  measure: avg_days_from_lsd_designation_to_quote {
    type: average
    value_format_name: decimal_1
    sql: ${days_from_lsd_designation_to_quote} ;;
    drill_fields: [details*]
  }
  measure: count {
    type: count
    drill_fields: [details*]
  }

  set: details {
    fields: [
      lsd_insurance,
      serial_number,
      overall_status,
      assets_owner,
      yard_location,
      customer_name,
      type_of_loss,
      date_customer_quote_sent_to_yard_date
    ]
  }
}
