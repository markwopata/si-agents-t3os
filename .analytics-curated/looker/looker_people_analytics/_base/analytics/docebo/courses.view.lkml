view: courses {
  sql_table_name: "ANALYTICS"."DOCEBO"."COURSES" ;;

  dimension: _es_update_timestamp {
    type: date_raw
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }
  dimension: available_seats {
    type: string
    sql: ${TABLE}."AVAILABLE_SEATS" ;;
  }
  dimension: available_seats_course {
    type: number
    sql: ${TABLE}."AVAILABLE_SEATS_COURSE" ;;
  }
  dimension: can_rate {
    type: yesno
    sql: ${TABLE}."CAN_RATE" ;;
  }
  dimension: can_self_unenroll {
    type: yesno
    sql: ${TABLE}."CAN_SELF_UNENROLL" ;;
  }
  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }
  dimension: code {
    type: string
    sql: ${TABLE}."CODE" ;;
  }
  dimension: course_type {
    type: string
    sql: ${TABLE}."COURSE_TYPE" ;;
  }
  dimension: credits {
    type: number
    sql: ${TABLE}."CREDITS" ;;
  }
  dimension: current_rating {
    type: number
    sql: ${TABLE}."CURRENT_RATING" ;;
  }
  dimension: date_last_updated {
    type: date_raw
    sql: ${TABLE}."DATE_LAST_UPDATED" ;;
  }
  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }
  dimension: duration {
    type: number
    sql: ${TABLE}."DURATION" ;;
  }
  dimension: end {
    type: date_raw
    sql: ${TABLE}."END_DATE" ;;
  }
  dimension: enrollment_policy {
    type: number
    sql: ${TABLE}."ENROLLMENT_POLICY" ;;
  }
  dimension: id_course {
    type: number
    sql: ${TABLE}."ID_COURSE" ;;
  }
  dimension: image {
    type: string
    sql: ${TABLE}."IMAGE" ;;
  }
  dimension: img_url {
    type: string
    sql: ${TABLE}."IMG_URL" ;;
  }
  dimension: is_new {
    type: string
    sql: ${TABLE}."IS_NEW" ;;
  }
  dimension: is_opened {
    type: string
    sql: ${TABLE}."IS_OPENED" ;;
  }
  dimension: language {
    type: string
    sql: ${TABLE}."LANGUAGE" ;;
  }
  dimension: language_label {
    type: string
    sql: ${TABLE}."LANGUAGE_LABEL" ;;
  }
  dimension: max_attempts {
    type: string
    sql: ${TABLE}."MAX_ATTEMPTS" ;;
  }
  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }
  dimension: price {
    type: string
    sql: ${TABLE}."PRICE" ;;
  }
  dimension: rating_option {
    type: string
    sql: ${TABLE}."RATING_OPTION" ;;
  }
  dimension: selling {
    type: yesno
    sql: ${TABLE}."SELLING" ;;
  }
  dimension: slug_name {
    type: string
    sql: ${TABLE}."SLUG_NAME" ;;
  }
  dimension: start {
    type: date_raw
    sql: ${TABLE}."START_DATE" ;;
  }
  dimension: uidcourse {
    type: string
    sql: ${TABLE}."UIDCOURSE" ;;
  }
  measure: count {
    type: count
    drill_fields: [slug_name, name]
  }
}
