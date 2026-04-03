view: retail_quote_request_mapping {
  sql_table_name: "GS"."RETAIL_QUOTE_REQUEST_MAPPING"
    ;;

  dimension_group: _fivetran_synced {
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
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
  }

  dimension: additional_comments {
    type: string
    sql: ${TABLE}."ADDITIONAL_COMMENTS" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: customer_address_for_delivery {
    type: string
    sql: ${TABLE}."CUSTOMER_ADDRESS_FOR_DELIVERY" ;;
  }

  dimension: customer_contact_email {
    type: string
    sql: ${TABLE}."CUSTOMER_CONTACT_EMAIL" ;;
  }

  dimension: customer_contact_name {
    type: string
    sql: ${TABLE}."CUSTOMER_CONTACT_NAME" ;;
  }

  dimension: customer_contact_phone {
    type: string
    sql: ${TABLE}."CUSTOMER_CONTACT_PHONE" ;;
  }

  dimension: customer_or_prospect_id {
    type: string
    sql: ${TABLE}."CUSTOMER_OR_PROSPECT_ID" ;;
  }

  dimension: customer_or_prospect_name {
    type: string
    sql: ${TABLE}."CUSTOMER_OR_PROSPECT_NAME" ;;
  }

  dimension: email_address {
    type: string
    sql: TRIM(${TABLE}."EMAIL_ADDRESS") ;;
  }

  dimension: equipment_class {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS" ;;
  }

  dimension: hours {
    type: number
    sql: ${TABLE}."HOURS" ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: quote_ {
    type: number
    sql: ${TABLE}."QUOTE_" ;;
  }

  dimension: sale_price {
    type: number
    sql: ${TABLE}."SALE_PRICE" ;;
  }

  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }

  dimension: submitted_by {
    type: string
    sql: ${TABLE}."SUBMITTED_BY" ;;
  }

  dimension: current_year_month {
    type: yesno
    sql: date_trunc('month',${timestamp_raw})::DATE=date_trunc('month',current_timestamp)::DATE;;
  }

  dimension_group: timestamp {
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
    sql: CAST(${TABLE}."TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }


  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
  }

  measure: count {
    type: count
    drill_fields: [market_name, customer_or_prospect_name, customer_contact_name]
  }

  measure: number_of_assets {
    type: count_distinct
    sql: ${asset_id} ;;
    drill_fields: [timestamp_date, market_name, asset_id,serial_number,customer_contact_name]
  }

  measure: mtd_number_of_assets {
    type: count_distinct
    sql: ${asset_id} ;;
    filters: {
      field: current_year_month
      value: "Yes"
    }
    drill_fields: [timestamp_date, market_name, asset_id,serial_number,customer_contact_name]
  }

  dimension: retail_line_items {
    type: yesno
    sql: ${line_items.line_item_type_id} in (24,80,50,81) ;;
  }


  measure: number_of_assets_with_retail_rev {
    type: count_distinct
    sql: ${asset_id} ;;
    filters: {
      field: retail_line_items
      value: "Yes"
    }
    # filters: {
    #   field: current_year_month
    #   value: "Yes"
    # }
    drill_fields: [timestamp_date, market_name, asset_id,serial_number,customer_contact_name]
  }
}
