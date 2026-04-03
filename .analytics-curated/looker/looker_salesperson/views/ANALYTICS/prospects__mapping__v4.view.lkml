view: prospects__mapping__v4 {
  sql_table_name: "ANALYTICS"."WEBAPPS"."CRM__PROSPECTS__MAPPING__V4"
    ;;

  dimension: company_address {
    type: string
    sql: ${TABLE}."COMPANY_ADDRESS" ;;
  }

  dimension: company_city {
    type: string
    sql: ${TABLE}."COMPANY_CITY" ;;
  }

    dimension: company_name_view_prospects {
      type: string
      sql: ${TABLE}.COMPANY_NAME ;;
      html:
      <font color="blue "><u><a href = "https://equipmentshare.looker.com/dashboards/206?Company%20Name={{ company_name_view_prospects._filterable_value | url_encode }}" target="_blank">{{ company_name_view_prospects._filterable_value }}</a></font></u>;;
    }

  dimension: company_name_prospect_actions {
    type: string
    sql: ${TABLE}.COMPANY_NAME ;;
    html:
      <font color="blue "><u><a href = "https://equipmentshare.looker.com/dashboards/229?Company%20Name={{ company_name_prospect_actions._filterable_value | url_encode }}" target="_blank">{{ company_name_prospect_actions._filterable_value }}</a></font></u>;;
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

  dimension: timestamp {
    type: date
    sql: ${TABLE}."TIMESTAMP" ;;
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
      year,
      day_of_month
    ]
    sql: ${TABLE}.timestamp ;;
  }

  #measure: count {
    #type: count
    #drill_fields: [company_name_view_prospects, folder_name, region_name]
  #}

  measure: count_sm {
    type: count_distinct
    sql: ${prospect_id} ;;
    drill_fields: [prospect_id, company_name_view_prospects, timestamp_date,users.Full_Name,folder_url]
  }


  dimension: create_note {
    type: string
    html:
    <font color="blue "><u><a href = "https://staging-ba.equipmentshare.com/crm/prospect_note?Prospect%20ID={{ prospect_id._value | url_encode }}&Company%20Name={{ company_name_view_prospects._value | url_encode }}" target="_blank">Create Note</a></font></u>;;
    sql: ${TABLE}.prospect_id  ;;}

  dimension: update_prospect {
    type: string
    html:
    <font color="blue "><u><a href = "https://staging-ba.equipmentshare.com/crm/lookup_prospect?Prospect%20ID={{ prospect_id._value | url_encode }}&Company%20Name={{ company_name_view_prospects._value | url_encode }}" target="_blank">Update Prospect</a></font></u>;;
    sql: ${TABLE}.prospect_id  ;;}

  dimension: merge_prospect {
    type: string
    html:
    <font color="blue "><u><a href = "https://staging-ba.equipmentshare.com/crm/merge_prospect?Prospect%20ID={{ prospect_id._value | url_encode }}&Company%20Name={{ company_name_view_prospects._value | url_encode }}" target="_blank">Merge Prospect</a></font></u>;;
    sql: ${TABLE}.prospect_id  ;;}

 dimension: reassign_prospect {
  type: string
  html:
    <font color="blue "><u><a href = "https://staging-ba.equipmentshare.com/crm/reassign_prospect?Prospect%20ID={{ prospect_id._value | url_encode }}&Company%20Name={{ company_name_view_prospects._value | url_encode }}&Sales%20Representative%20Email%20Address={{ sales_representative_email_address._value | url_encode }}" target="_blank">Reassign Prospect</a></font></u>;;
  sql: ${TABLE}.prospect_id  ;;}

  dimension: quote_templates {
    type: string
    html:
    <font color="blue "><u><a href = "https://staging-ba.equipmentshare.com/crm/prospects_quote_templates?Prospect%20ID={{ prospect_id._value | url_encode }}&Company%20Name={{ company_name_view_prospects._value | url_encode }}" target="_blank">Create Quote</a></font></u>;;
    sql: ${TABLE}.prospect_id  ;;}

  dimension:view_notes {
    type: string
   # html:
  #  <font color="blue "><u><a href = "http://127.0.0.1:5000/prospects/view_notes?Prospect%20ID={{ prospect_id._value | url_encode }}&Company%20Name={{ company_name._value | url_encode }}" target="_blank">View Notes</a></font></u>;;
    html: <font color="blue "><u><a href = "https://equipmentshare.looker.com/dashboards/204?Prospect%20ID={{ prospect_id._value | url_encode }}&Company%20Name={{ company_name_view_prospects._value | url_encode }}" target="_blank">View Notes</a></font></u>;;
   sql: ${TABLE}.prospect_id  ;;}

  dimension: create_task {
    type: string
    html:
    <font color="blue "><u><a href = "https://staging-ba.equipmentshare.com/crm/tasks?Company%20Prospect%20ID={{ prospect_id._value | url_encode }}&Company%20Name={{ company_name_view_prospects._value | url_encode }}" target="_blank">Create Calendar Event</a></font></u>;;
    sql: ${TABLE}.prospect_id  ;;}

  dimension: get_directions {
    type: string
    sql: ${TABLE}.prospect_id ;;
    html:<font color="blue "><u><a href="https://www.google.com/maps/dir/?api=1&destination={{ company_address._value | url_encode }}+{{ company_city._value | url_encode }}+{{ company_state._value | url_encode }}+{{ company_zipcode._value | url_encode }}&travelmode=car" target="_blank">Get Directions</a></font></u> ;;
  }

  dimension: folder_url_link {
    type: string
    sql: ${TABLE}.folder_url ;;
    html:<font color="blue "><u><a href="{{ folder_url._value }}" target="_blank">Link to Drive Folder</a></font></u> ;;
  }


  dimension: link_agg {
    label: "Links"
    sql: ${TABLE}."PROSPECT_ID" ;;
    html: {% if prospect_id._value != null %}
          <a href = "{{ folder_url_link._value }}" target="_blank"><img src="https://icons.iconarchive.com/icons/marcus-roberto/google-play/16/Google-Drive-icon.png" width="16" height="16"> Link to Drive Folder</a>
          {% endif %}
          &nbsp; &nbsp;
          {% if prospect_id._value != null %}
          <a href = "https://staging-ba.equipmentshare.com/crm/prospect_note?Prospect%20ID={{ prospect_id._value | url_encode }}&Company%20Name={{ company_name_view_prospects._value | url_encode }}" target="_blank"><img src="https://icons.iconarchive.com/icons/tatice/cristal-intense/16/Notepad-Bloc-notes-icon.png" width="16" height="16"> Create Note</a>
          {% endif %}
          &nbsp; &nbsp;
          {% if prospect_id._value != null %}
          <a href = "https://staging-ba.equipmentshare.com/crm/lookup_prospect?Prospect%20ID={{ prospect_id._value | url_encode }}&Company%20Name={{ company_name_view_prospects._value | url_encode }}" target="_blank"><img src="https://icons.iconarchive.com/icons/oxygen-icons.org/oxygen/128/Actions-edit-redo-icon.png" width="16" height="16"> Update Prospect</a>
          {% endif %}
          &nbsp; &nbsp;
          {% if prospect_id._value != null %}
          <a href = "https://staging-ba.equipmentshare.com/crm/merge_prospect?Prospect%20ID={{ prospect_id._value | url_encode }}&Company%20Name={{ company_name_view_prospects._value | url_encode }}" target="_blank"><img src="https://icons.iconarchive.com/icons/fatcow/farm-fresh/32/arrow-merge-icon.png" width="16" height="16"> Merge Prospect</a>
          {% endif %}
          &nbsp; &nbsp;
          {% if prospect_id._value != null %}
          <a href = "https://staging-ba.equipmentshare.com/crm/reassign_prospect?Prospect%20ID={{ prospect_id._value | url_encode }}&Company%20Name={{ company_name_view_prospects._value | url_encode }}&Sales%20Representative%20Email%20Address={{ sales_representative_email_address._value | url_encode }}" target="_blank"><img src="https://icons.iconarchive.com/icons/iconsmind/outline/128/Data-Transfer-icon.png" width="16" height="16"> Reassign Prospect</a>
          {% endif %}
          &nbsp; &nbsp;
          {% if prospect_id._value != null %}
          <a href = "https://staging-ba.equipmentshare.com/crm/prospects_quote_templates?Prospect%20ID={{ prospect_id._value | url_encode }}&Company%20Name={{ company_name_view_prospects._value | url_encode }}" target="_blank"><img src="https://icons.iconarchive.com/icons/papirus-team/papirus-apps/128/github-alonsoenrique-quotes-icon.png" width="16" height="16"> Create Quote</a>
          {% endif %}
           &nbsp; &nbsp;
          {% if prospect_id._value != null %}
          <a href = "https://equipmentshare.looker.com/dashboards/204?Prospect%20ID={{ prospect_id._value | url_encode }}&Company%20Name={{ company_name_view_prospects._value | url_encode }}" target="_blank"><img src="https://icons.iconarchive.com/icons/tatice/cristal-intense/16/Notepad-Bloc-notes-icon.png" width="16" height="16"> View Notes</a>
          {% endif %}
          &nbsp; &nbsp;
          {% if prospect_id._value != null %}
          <a href = "https://staging-ba.equipmentshare.com/crm/tasks?Company%20Prospect%20ID={{ prospect_id._value | url_encode }}&Company%20Name={{ company_name_view_prospects._value | url_encode }}" target="_blank"><img src="https://icons.iconarchive.com/icons/oxygen-icons.org/oxygen/128/Actions-view-calendar-day-icon.png" width="16" height="16"> Create Calendar Event</a>
          {% endif %}
          &nbsp; &nbsp;
          {% if prospect_id._value != null %}
          <a href = "https://www.google.com/maps/dir/?api=1&destination={{ company_address._value | url_encode }}+{{ company_city._value | url_encode }}+{{ company_state._value | url_encode }}+{{ company_zipcode._value | url_encode }}&travelmode=car" target="_blank"><img src="https://icons.iconarchive.com/icons/marcus-roberto/google-play/128/Google-Maps-icon.png" width="16" height="16"> Get Directions</a>
          {% endif %}
          ;;
  }



}
