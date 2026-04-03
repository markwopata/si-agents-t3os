view: prospects__mapping__v3 {
  sql_table_name: ANALYTICS.PROSPECTS.PROSPECTS__MAPPING__V3
    ;;

  dimension: company_address {
    type: string
    sql: ${TABLE}."COMPANY_ADDRESS" ;;
  }

  dimension: company_city {
    type: string
    sql: ${TABLE}."COMPANY_CITY" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: company_phone {
    type: string
    sql: ${TABLE}."COMPANY_PHONE" ;;
  }

  dimension: company_state {
    type: string
    sql: ${TABLE}."COMPANY_STATE" ;;
  }

  dimension: company_url {
    type: string
    sql: ${TABLE}."COMPANY_URL" ;;
  }

  dimension: company_zipcode {
    type: string
    sql: ${TABLE}."COMPANY_ZIPCODE" ;;
  }

  dimension: contact_email_1 {
    type: string
    sql: ${TABLE}."CONTACT_EMAIL_1" ;;
  }

  dimension: contact_email_2 {
    type: string
    sql: ${TABLE}."CONTACT_EMAIL_2" ;;
  }

  dimension: contact_email_3 {
    type: string
    sql: ${TABLE}."CONTACT_EMAIL_3" ;;
  }

  dimension: contact_name_1 {
    type: string
    sql: ${TABLE}."CONTACT_NAME_1" ;;
  }

  dimension: contact_name_2 {
    type: string
    sql: ${TABLE}."CONTACT_NAME_2" ;;
  }

  dimension: contact_name_3 {
    type: string
    sql: ${TABLE}."CONTACT_NAME_3" ;;
  }

  dimension: contact_phone_1 {
    type: string
    sql: ${TABLE}."CONTACT_PHONE_1" ;;
  }

  dimension: contact_phone_2 {
    type: string
    sql: ${TABLE}."CONTACT_PHONE_2" ;;
  }

  dimension: contact_phone_3 {
    type: string
    sql: ${TABLE}."CONTACT_PHONE_3" ;;
  }

  dimension: contact_type_1 {
    type: string
    sql: ${TABLE}."CONTACT_TYPE_1" ;;
  }

  dimension: contact_type_2 {
    type: string
    sql: ${TABLE}."CONTACT_TYPE_2" ;;
  }

  dimension: contact_type_3 {
    type: string
    sql: ${TABLE}."CONTACT_TYPE_3" ;;
  }

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

  dimension: prospect_id {
    type: string
    sql: ${TABLE}."PROSPECT_ID" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: sales_representative_email_address {
    type: string
    sql: ${TABLE}."SALES_REPRESENTATIVE_EMAIL_ADDRESS" ;;
  }

  dimension: serial_id {
    type: number
    sql: ${TABLE}."SERIAL_ID" ;;
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
    drill_fields: [folder_name, region_name, company_name]
  }

  dimension: merge_prospect {
    type: string
    html:  <font color="blue "><u><a href = "https://app.seekwell.io/form/2c42a2e1800149ed9f2811cccf0e4f31?timestamp={{ "now" | date: "%Y-%m-%d %H:%M" }}&prospect_id={{prospect_id._value }}&sales_representative_email_address={{  _user_attributes['email'] }}" target="_blank">Merge Prospect</a></font></u>;;
    sql: ${TABLE}.prospect_id  ;;
  }

  dimension: reassign_prospect {
    type: string
    html: <font color="blue "><u><a href = "https://app.seekwell.io/form/169d80bf8daf4565818258f9e60ca60b?prospect_id={{prospect_id._value }}&sales_representative_email_address={{  _user_attributes['email'] }}" target="_blank">Update Prospect</a></font></u>;;
    sql: ${TABLE}.prospect_id  ;;
  }

  dimension: create_note {
    type: string
    html:
    <font color="blue "><u><a href = "https://app.seekwell.io/form/9b513151952049c3931bca19b8968fdf?timestamp={{ "now" | date: "%Y-%m-%d %H:%M" }}&prospect_id={{prospect_id._value }}&sales_representative_email_address={{  _user_attributes['email'] }}" target="_blank">Create Note</a></font></u>;;
    sql: ${TABLE}.prospect_id  ;;}

  dimension: create_prospect {
    type: string
    html: <font color="blue "><u><a href = "https://docs.google.com/forms/d/e/1FAIpQLSeQ2ZbaOfmI2NoNhvWJWxtmVMT9ZfrMOGtpKOX-3BeZFKukDw/viewform?usp=pp_url&entry.1265378221={{  _user_attributes['email'] }}" target="_blank">Create Prospect</a></font></u> ;;
    sql: ${TABLE}.prospect_id  ;;
  }

  dimension: create_prospect_v2 {
    type: string
    html: <font color="blue "><u><a href = "https://app.seekwell.io/form/f9da7270cbaa44a6a1bfc0e846232256?sales_representative_email_address={{  _user_attributes['email'] }}" target="_blank">Create Prospect</a></font></u> ;;
    sql: ${prospect_id}  ;;
  }

  dimension: folder_url_link {
    type: string
    sql: ${TABLE}.folder_url ;;
    html:<font color="blue "><u><a href="{{ folder_url._value }}" target="_blank">Link to Drive Folder</a></font></u> ;;
  }

}
