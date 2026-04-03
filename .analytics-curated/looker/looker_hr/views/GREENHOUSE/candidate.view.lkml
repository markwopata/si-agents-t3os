view: candidate {
  sql_table_name: "GREENHOUSE"."CANDIDATE"
    ;;

  dimension: candidate_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
  }

  dimension: _fivetran_deleted {
    type: yesno
    sql: ${TABLE}."_FIVETRAN_DELETED" ;;
  }

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

  dimension: company {
    type: string
    sql: ${TABLE}."COMPANY" ;;
  }

  dimension: coordinator_id {
    type: number
    sql: ${TABLE}."COORDINATOR_ID" ;;
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
    sql: CAST(${TABLE}."CREATED_AT" AS TIMESTAMP_NTZ) ;;
  }

  dimension: custom_address_1 {
    type: string
    sql: ${TABLE}."CUSTOM_ADDRESS_1" ;;
  }

  dimension: custom_address_2 {
    type: string
    sql: ${TABLE}."CUSTOM_ADDRESS_2" ;;
  }

  dimension: custom_anticipated_hire_date {
    type: string
    sql: ${TABLE}."CUSTOM_ANTICIPATED_HIRE_DATE" ;;
  }

  dimension: custom_city_state_zip_code {
    type: string
    sql: ${TABLE}."CUSTOM_CITY_STATE_ZIP_CODE" ;;
  }

  dimension: custom_desired_salary {
    type: string
    sql: ${TABLE}."CUSTOM_DESIRED_SALARY" ;;
  }

  dimension: custom_referrer_open_ended {
    type: string
    sql: ${TABLE}."CUSTOM_REFERRER_OPEN_ENDED" ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }

  dimension: is_private {
    type: yesno
    sql: ${TABLE}."IS_PRIVATE" ;;
  }

  dimension_group: last_activity {
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
    sql: CAST(${TABLE}."LAST_ACTIVITY" AS TIMESTAMP_NTZ) ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }

  dimension: full_name {
    type: string
    sql: concat(${first_name},' ',${last_name}) ;;
  }

  dimension: new_candidate_id {
    type: number
    sql: ${TABLE}."NEW_CANDIDATE_ID" ;;
  }

  dimension: photo_url {
    type: string
    sql: ${TABLE}."PHOTO_URL" ;;
  }

  dimension: recruiter_id {
    type: number
    sql: ${TABLE}."RECRUITER_ID" ;;
  }

  dimension: title {
    type: string
    sql: ${TABLE}."TITLE" ;;
  }

  dimension_group: updated {
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
    sql: CAST(${TABLE}."UPDATED_AT" AS TIMESTAMP_NTZ) ;;
  }

  dimension: application_url {
    type: string
    sql: 'https://app.greenhouse.io/people/' || ${candidate_id} || '?application_id=' || ${application.application_id} ||
           '&src=search#application'  ;;
  }

  dimension: link_to_application {
    type: string
    html: <font color="blue "><u><a href ="{{application_url._value}}"target="_blank">Link to Application</a></font></u> ;;
    sql: ${application_url} ;;
  }

  dimension: link_to_candidate_dash {
    type: string
    html:<font color="blue "><u><a href ="https://equipmentshare.looker.com/dashboards-next/255?Candidate+Name={{ value | url_encode }}&Job+Title="target="_blank">Link to Application</a></font></u> ;;
    sql:  ${full_name} ;;
  }

  dimension: candidate_name_link_to_candidate_dashboard {
    type: string
    sql: ${full_name} ;;
   html: <font color="blue "><u><a href="https://equipmentshare.looker.com/dashboards-next/255?Candidate+Name={{ value | url_encode }}&Job+Title=" target="_blank" title="Link to Candidate Dashboard">{{value}}</a> ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      candidate_id,
      first_name,
      last_name,
      activity.count,
      address.count,
      application.count,
      attachment.count,
      candidate_tag.count,
      education.count,
      email.count,
      email_address.count,
      employment.count,
      note.count,
      phone_number.count,
      scorecard.count,
      social_media_address.count,
      website_address.count
    ]
  }
}
