view: v_real_estate_leads {
  sql_table_name: "JOTFORM"."V_REAL_ESTATE_LEADS"
    ;;

  dimension: real_estate_leads_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."REAL_ESTATE_LEADS_ID" ;;
  }

  dimension: address {
    type: string
    sql: ${TABLE}."ADDRESS" ;;
  }

  dimension_group: date_updated {
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
    sql: ${TABLE}."DATE_UPDATED" ;;
  }

  dimension: requester_first_name {
    type: string
    sql: ${TABLE}."REQUESTER_FIRST_NAME" ;;
  }

  dimension: requester_last_name {
    type: string
    sql: ${TABLE}."REQUESTER_LAST_NAME" ;;
  }

  dimension: jotform_url {
    type: string
    sql: ${TABLE}."JOTFORM_URL" ;;
    link: {
      label: "Jotform Link"
      url: "{{jotform_url}}"
    }
  }

  dimension: form_id {
    type: number
    sql: ${TABLE}."FORM_ID" ;;
  }

  dimension: list_price {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}."LIST_PRICE" ;;
  }

  dimension: note {
    type: string
    sql: ${TABLE}."NOTE" ;;
  }

  dimension: region_district {
    type: string
    sql: ${TABLE}."REGION_DISTRICT" ;;
  }

  dimension: division {
    type: string
    sql: ${TABLE}."DIVISION" ;;
  }


  dimension: site_type {
    type: string
    sql: ${TABLE}."SITE_TYPE" ;;
  }

  dimension: market {
    type: string
    sql: ${TABLE}."MARKET" ;;
  }

  dimension: acreage {
    type: string
    sql: ${TABLE}."ACREAGE" ;;
  }

  dimension: square_feet {
    type: string
    sql: ${TABLE}."SQUARE_FEET" ;;
  }

  dimension: distance_to_city_center {
    type: string
    sql: ${TABLE}."DISTANCE_TO_CITY_CENTER" ;;
  }

  dimension: submission_id {
    type: number
    sql: ${TABLE}."SUBMISSION_ID" ;;
  }

  dimension: count_address {
    type: number
    sql: ${TABLE}."COUNT_ADDRESS" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
