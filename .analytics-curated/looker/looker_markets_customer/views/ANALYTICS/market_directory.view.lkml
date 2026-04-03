view: market_directory {
  sql_table_name: "MARKET_DATA"."MARKET_DIRECTORY"
    ;;

  dimension: contract_signed {
    type: yesno
    sql: ${TABLE}."CONTRACT_SIGNED" ;;
    html:

    {% if value == 'Yes' %}

    <p style="color: black; background-color: lightgreen; font-size:100%; text-align:center">{{ rendered_value }}</p>

    {% else %}

    <p style="color: black; background-color: #F86767; font-size:100%; text-align:center">{{ rendered_value }}</p>

    {% endif %}

    ;;
  }

  dimension: district_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."DISTRICT_ID" ;;
  }

  dimension: due_diligence_complete {
    type: yesno
    sql: ${TABLE}."DUE_DILIGENCE_COMPLETE" ;;
    html:

    {% if value == 'Yes' %}

    <p style="color: black; background-color: lightgreen; font-size:100%; text-align:center">{{ rendered_value }}</p>

    {% else %}

    <p style="color: black; background-color: #F86767; font-size:100%; text-align:center">{{ rendered_value }}</p>

    {% endif %}

    ;;
  }

  dimension: duns_number {
    type: string
    sql: ${TABLE}."DUNS_NUMBER" ;;
  }

  dimension: hr_all_offers_made {
    type: yesno
    sql: ${TABLE}."HR_ALL_OFFERS_MADE" ;;
    html:

    {% if value == 'Yes' %}

    <p style="color: black; background-color: lightgreen; font-size:100%; text-align:center">{{ rendered_value }}</p>

    {% else %}

    <p style="color: black; background-color: #F86767; font-size:100%; text-align:center">{{ rendered_value }}</p>

    {% endif %}

    ;;

  }

  dimension: hr_gm_offers_made {
    type: yesno
    sql: ${TABLE}."HR_GM_OFFERS_MADE" ;;
    html:

    {% if value == 'Yes' %}

    <p style="color: black; background-color: lightgreen; font-size:100%; text-align:center">{{ rendered_value }}</p>

    {% else %}

    <p style="color: black; background-color: #F86767; font-size:100%; text-align:center">{{ rendered_value }}</p>

    {% endif %}

    ;;
  }

  dimension: hr_positions_filled {
    type: yesno
    sql: ${TABLE}."HR_POSITIONS_FILLED" ;;
    html:

    {% if value == 'Yes' %}

    <p style="color: black; background-color: lightgreen; font-size:100%; text-align:center">{{ rendered_value }}</p>

    {% else %}

    <p style="color: black; background-color: #F86767; font-size:100%; text-align:center">{{ rendered_value }}</p>

    {% endif %}

    ;;
  }

  dimension: hr_positions_posted {
    type: yesno
    sql: ${TABLE}."HR_POSITIONS_POSTED" ;;
    html:

    {% if value == 'Yes' %}

    <p style="color: black; background-color: lightgreen; font-size:100%; text-align:center">{{ rendered_value }}</p>

    {% else %}

    <p style="color: black; background-color: #F86767; font-size:100%; text-align:center">{{ rendered_value }}</p>

    {% endif %}

    ;;
  }

  dimension: hr_sales_offers_made {
    type: yesno
    sql: ${TABLE}."HR_SALES_OFFERS_MADE" ;;
    html:

    {% if value == 'Yes' %}

    <p style="color: black; background-color: lightgreen; font-size:100%; text-align:center">{{ rendered_value }}</p>

    {% else %}

    <p style="color: black; background-color: #F86767; font-size:100%; text-align:center">{{ rendered_value }}</p>

    {% endif %}

    ;;
  }

  dimension: loi_signed {
    type: yesno
    sql: ${TABLE}."LOI_SIGNED" ;;
    html:

    {% if value == 'Yes' %}

    <p style="color: black; background-color: lightgreen; font-size:100%; text-align:center">{{ rendered_value }}</p>

    {% else %}

    <p style="color: black; background-color: #F86767; font-size:100%; text-align:center">{{ rendered_value }}</p>

    {% endif %}

    ;;
  }

  dimension: market_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."MARKET_ID" ;;
    drill_fields: [detail_dashboard]

  }

  dimension: market_status {
    type: string
    sql: ${TABLE}."MARKET_STATUS" ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension_group: occupancy {
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
    sql: ${TABLE}."OCCUPANCY_DATE" ;;
  }

  dimension_group: open {
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
    sql: ${TABLE}."OPEN_DATE" ;;
  }

  dimension: poc_email {
    type: string
    label: "POC Email"
    sql: ${TABLE}."POC_EMAIL" ;;
  }

  dimension: poc_phone_number {
    type: string
    label: "POC Phone Number"
    sql: ${TABLE}."POC_PHONE_NUMBER" ;;
  }

  dimension: point_of_contact {
    type: string
    sql: ${TABLE}."POINT_OF_CONTACT" ;;
  }

  dimension: property_owner {
    type: string
    sql: ${TABLE}."PROPERTY_OWNER" ;;
  }

  dimension_group: real_estate_acquisition {
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
    sql: ${TABLE}."REAL_ESTATE_ACQUISITION_DATE" ;;
  }

  dimension: region_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."REGION_ID" ;;
  }

  dimension: rent_own {
    type: string
    sql: ${TABLE}."RENT_OWN" ;;
  }

  dimension: service_manager {
    type: string
    sql: ${TABLE}."SERVICE_MANAGER" ;;
  }

  dimension: paycor_name {
    type: string
    sql: ${TABLE}."PAYCOR_NAME" ;;
  }

  dimension: service_manager_email {
    type: string
    sql: ${TABLE}."SERVICE_MANAGER_EMAIL" ;;
  }

  dimension: service_trainer {
    type: string
    sql: ${TABLE}."SERVICE_TRAINER" ;;
  }

  dimension: deleted {
    type: yesno
    sql: ${TABLE}."DELETED" ;;
  }

  dimension_group: target_acquisition {
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
    sql: ${TABLE}."TARGET_ACQUISITION_DATE" ;;
  }

  dimension: target_acquisition_qtr {
    type: string
    sql: concat(year(${TABLE}."TARGET_ACQUISITION_DATE"), '-Q',quarter(${TABLE}."TARGET_ACQUISITION_DATE")) ;;
  }

  dimension: detail_dashboard {
    type: string
    sql: ${TABLE}.market_id ;;
    html: <font color="blue "><u><a href="https://equipmentshare.looker.com/dashboards/218?Market%20ID={{market_id._value}}" target="_blank">{{ market_id._value }}</a></font></u> ;;
  }

  measure: count_of_markets {
    type: count_distinct
    sql: ${market_id} ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
