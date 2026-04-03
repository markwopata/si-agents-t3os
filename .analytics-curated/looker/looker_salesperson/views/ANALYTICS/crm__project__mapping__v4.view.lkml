view: crm__project__mapping__v4 {
  sql_table_name: "ANALYTICS"."WEBAPPS"."CRM__PROJECT__MAPPING__V4"
    ;;

  dimension: created_by {
    type: string
    sql: ${TABLE}."CREATED_BY" ;;
  }

  dimension: folder_id {
    type: string
    sql: ${TABLE}."FOLDER_ID" ;;
  }

  dimension: folder_name {
    type: string
    sql: ${TABLE}."FOLDER_NAME" ;;
  }

  dimension: folder_url {
    type: string
    sql: ${TABLE}."FOLDER_URL" ;;
  }

  dimension_group: last_update_timestamp {
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
    sql: ${TABLE}."LAST_UPDATE_TIMESTAMP" ;;
  }

  dimension: project_address {
    type: string
    sql: ${TABLE}."PROJECT_ADDRESS" ;;
  }

  dimension: project_city {
    type: string
    sql: ${TABLE}."PROJECT_CITY" ;;
  }

  dimension_group: project_date_start {
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
    sql: ${TABLE}."PROJECT_DATE_START" ;;
  }

  dimension: project_duration {
    type: string
    sql: ${TABLE}."PROJECT_DURATION" ;;
  }

  dimension: project_id {
    type: string
    sql:'PRJ'||${TABLE}."PROJECT_ID" ;;
  }


  dimension: project_name {
    type: string
    sql: ${TABLE}."PROJECT_NAME" ;;
  }

  dimension: project_state {
    type: string
    sql: ${TABLE}."PROJECT_STATE" ;;
  }

  dimension: project_type {
    type: string
    sql: ${TABLE}."PROJECT_TYPE" ;;
  }

  dimension: project_value {
    type: number
    sql: ${TABLE}."PROJECT_VALUE" ;;
  }

  dimension: project_zipcode {
    type: string
    sql: ${TABLE}."PROJECT_ZIPCODE" ;;
  }

  dimension: sales_representative_email_address {
    type: string
    sql: ${TABLE}."SALES_REPRESENTATIVE_EMAIL_ADDRESS" ;;
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
    sql: ${TABLE}."TIMESTAMP" ;;
  }

  measure: count {
    type: count
    drill_fields: [folder_name, project_name]
  }
}
