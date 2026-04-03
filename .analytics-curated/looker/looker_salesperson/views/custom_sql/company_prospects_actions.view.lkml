view: company_prospects_actions {

  derived_table: {
    sql:
     SELECT ECM.COMPANY_ID::VARCHAR(15000) AS COMPANY_PROSPECT_PROJECT_ID , ECM.COMPANY_NAME AS COMPANY_NAME, '' AS EMAIL,
ECM.FOLDER_URL AS FOLDER_URL, L.STREET_1 AS ADDRESS, L.CITY AS CITY, S.NAME AS STATE, L.ZIP_CODE::VARCHAR AS ZIPCODE
FROM ANALYTICS.WEBAPPS.CRM__EXISTING__COMPANIES__MAPPING__V4 AS ECM
LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANIES AS C
ON ECM.COMPANY_ID = C.COMPANY_ID
LEFT JOIN ES_WAREHOUSE.PUBLIC.LOCATIONS AS L
ON C.BILLING_LOCATION_ID = L.LOCATION_ID
LEFT JOIN ES_WAREHOUSE.PUBLIC.STATES AS S
ON L.STATE_ID = S.STATE_ID
UNION ALL
SELECT PROSPECT_ID::VARCHAR(15000) AS COMPANY_PROSPECT_PROJECT_ID , COMPANY_NAME AS COMPANY_NAME,
CREATED_BY  AS EMAIL, FOLDER_URL AS FOLDER_URL,
COMPANY_ADDRESS AS ADDRESS, COMPANY_CITY AS CITY, COMPANY_STATE AS STATE, COMPANY_ZIPCODE::VARCHAR AS ZIPCODE
FROM ANALYTICS.WEBAPPS.CRM__PROSPECTS__MAPPING__V4
UNION ALL
SELECT 'PRJ'||PROJECT_ID AS COMPANY_PROSPECT_PROJECT_ID , PROJECT_NAME AS COMPANY_NAME,
SALES_REPRESENTATIVE_EMAIL_ADDRESS AS EMAIL, FOLDER_URL AS FOLDER_URL, PROJECT_ADDRESS AS ADDRESS,
PROJECT_CITY AS CITY, PROJECT_STATE AS STATE, PROJECT_ZIPCODE AS ZIPCODE
FROM ANALYTICS.WEBAPPS.CRM__PROJECT__MAPPING__V4
    ;;
  }


 dimension: is_project {
    type: number
    sql:  case when left(${company_prospect_project_id},3) = 'PRJ' then  1
            when left(${company_prospect_project_id},1) = 'P' then 2
            when left(${company_prospect_project_id},1) != 'P' then 3 end ;;}

  dimension: company_prospect_project_id {
    type: string
    html:
    {% if is_project._value == 1 %}
    <font color="blue "><u><a href = "https://equipmentshare.looker.com/dashboards/327?Project%20ID={{ company_prospect_project_id._filterable_value | url_encode }}" target="_blank">{{ company_prospect_project_id._filterable_value }}</a></font></u>
    {% elsif is_project._value == 2 %}
    <font color="blue "><u><a href = "https://equipmentshare.looker.com/dashboards/275?Prospect%20ID={{ company_prospect_project_id._filterable_value | url_encode }}" target="_blank">{{ company_prospect_project_id._filterable_value }}</a></font></u>
    {% elsif is_project._value == 3 %}
    <font color="blue "><u><a href = "https://equipmentshare.looker.com/dashboards/28?Company%20Name={{ company_name._filterable_value | url_encode }}" target="_blank">{{ company_prospect_project_id._filterable_value }}</a></font></u>
    {% endif %} ;;
    sql: ${TABLE}."COMPANY_PROSPECT_PROJECT_ID" ;;}



  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}."EMAIL" ;;
  }

  dimension: folder_url {
    type: string
    sql: ${TABLE}."FOLDER_URL" ;;
  }

  dimension: address {
    type: string
    sql: ${TABLE}."ADDRESS" ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}."CITY" ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  dimension: zipcode {
    type: string
    sql: ${TABLE}."ZIPCODE" ;;}





  dimension: link_agg {
    label: "Links"
    required_fields: [sales_track_logins.fleet_login_link]
    sql: ${company_name} ;;    html:
          {% if  is_project._value == 2 %}
             <a href = "https://ba.equipmentshare.com/crm/tasks?Company%20Prospect%20ID={{ company_prospect_project_id._value | url_encode }}&Company%20Name={{ company_name._value | url_encode }}" target="_blank"><img src="https://icons.iconarchive.com/icons/oxygen-icons.org/oxygen/128/Actions-view-calendar-day-icon.png" width="16" height="16"> Create Calendar Event</a>
      &nbsp; &nbsp;
      <a href = "https://ba.equipmentshare.com/crm/lookup_prospect?Prospect%20ID={{ company_prospect_project_id._value | url_encode }}&Company%20Name={{ company_name._value | url_encode }}" target="_blank"><img src="https://icons.iconarchive.com/icons/oxygen-icons.org/oxygen/128/Actions-edit-redo-icon.png" width="16" height="16"> Update Prospect</a>
      &nbsp; &nbsp;
        <a href="{{ folder_url._value }}" target="_blank"><img src="https://icons.iconarchive.com/icons/marcus-roberto/google-play/16/Google-Drive-icon.png" width="16" height="16">Link to Drive Folder</a>
      &nbsp; &nbsp;
       <a href = "https://ba.equipmentshare.com/crm/prospect_note?Prospect%20ID={{ company_prospect_project_id._value | url_encode }}&Company%20Name={{ company_name._value | url_encode }}" target="_blank"><img src="https://icons.iconarchive.com/icons/tatice/cristal-intense/16/Notepad-Bloc-notes-icon.png" width="16" height="16"> Create Note</a>
      &nbsp; &nbsp;
     <a href = "https://equipmentshare.looker.com/dashboards/204?Prospect%20ID={{ company_prospect_project_id._value | url_encode }}&Company%20Name={{ company_name._value | url_encode }}" target="_blank"><img src="https://icons.iconarchive.com/icons/tatice/cristal-intense/16/Notepad-Bloc-notes-icon.png" width="16" height="16">View Notes</a>
      &nbsp; &nbsp;
       <a href = "https://ba.equipmentshare.com/crm/merge_prospect?Prospect%20ID={{ company_prospect_project_id._value | url_encode }}&Company%20Name={{ company_name._value | url_encode }}" target="_blank"><img src="https://icons.iconarchive.com/icons/fatcow/farm-fresh/32/arrow-merge-icon.png" width="16" height="16"> Merge Prospect</a>
      &nbsp; &nbsp;
       <a href = "https://ba.equipmentshare.com/crm/add_project?Company%20Prospect%20ID={{ company_prospect_project_id._value | url_encode }}&Company%20Name={{ company_name._value | url_encode }}" target="_blank"><img src="https://icons.iconarchive.com/icons/awicons/vista-artistic/128/add-icon.png" width="16" height="16"> Assign Prospect to Project</a>
      &nbsp; &nbsp;
       <a href = "https://ba.equipmentshare.com/crm/reassign_prospect?Created%20By={{ email._value | url_encode }}&Prospect%20ID={{ company_prospect_project_id._value | url_encode }}&Company%20Name={{ company_name._value | url_encode }}" target="_blank"><img src="https://icons.iconarchive.com/icons/iconsmind/outline/128/Data-Transfer-icon.png" width="16" height="16"> Reassign Prospect</a>
      &nbsp; &nbsp;
      <a href = "https://ba.equipmentshare.com/crm/prospects_quote_templates?Prospect%20ID={{ company_prospect_project_id._value | url_encode }}&Company%20Name={{ company_name._value | url_encode }}" target="_blank"><img src="https://icons.iconarchive.com/icons/papirus-team/papirus-apps/128/github-alonsoenrique-quotes-icon.png" width="16" height="16"> Create Quote</a>
      &nbsp; &nbsp;
       <a href = "https://www.google.com/maps/dir/?api=1&destination={{ address._value | url_encode }}+{{ city._value | url_encode }}+{{ state._value | url_encode }}+{{ zipcode._value | url_encode }}&travelmode=car" target="_blank"><img src="https://icons.iconarchive.com/icons/marcus-roberto/google-play/128/Google-Maps-icon.png" width="16" height="16"> Get Directions</a>
      &nbsp; &nbsp;
          {% elsif is_project._value == 3 %}
            <a href = "https://ba.equipmentshare.com/crm/tasks?Company%20Prospect%20ID={{ company_prospect_project_id._value | url_encode }}&Company%20Name={{ company_name._value | url_encode }}" target="_blank"><img src="https://icons.iconarchive.com/icons/oxygen-icons.org/oxygen/128/Actions-view-calendar-day-icon.png" width="16" height="16"> Create Calendar Event</a>
      &nbsp; &nbsp;
      <a href = "https://ba.equipmentshare.com/crm/existing_customer_homepage?Company%20ID={{ company_prospect_project_id._value | url_encode }}&Company%20Name={{ company_name._value  }}&email={{  _user_attributes['email'] }}" target="_blank"><img src="https://icons.iconarchive.com/icons/designbolts/seo/128/Homepage-Optimization-icon.png" width="16" height="16"> Add to Homepage</a>
      &nbsp; &nbsp;
      <a href="{{ folder_url._value }}" target="_blank"><img src="https://icons.iconarchive.com/icons/marcus-roberto/google-play/16/Google-Drive-icon.png" width="16" height="16">Link to Drive Folder</a>
      &nbsp; &nbsp;
       <a href = "https://ba.equipmentshare.com/crm/add_project?Company%20Prospect%20ID={{ company_prospect_project_id._value | url_encode }}&Company%20Name={{ company_name._value | url_encode }}" target="_blank"><img src="https://icons.iconarchive.com/icons/awicons/vista-artistic/128/add-icon.png" width="16" height="16"> Assign Existing Customer to Project</a>
      &nbsp; &nbsp;
      <a href = "https://ba.equipmentshare.com/crm/existing_customer_note?Company%20ID={{ company_prospect_project_id._value | url_encode }}&Company%20Name={{ company_name._value | url_encode }}"  target="_blank"><img src="https://icons.iconarchive.com/icons/tatice/cristal-intense/16/Notepad-Bloc-notes-icon.png" width="16" height="16"> Create Note</a>
      &nbsp; &nbsp;
      <a href = "https://equipmentshare.looker.com/dashboards/235?Company%20ID={{ company_prospect_project_id._value | url_encode }}&Customer%20Name={{ company_name._value | url_encode }}" target="_blank"><img src="https://icons.iconarchive.com/icons/tatice/cristal-intense/16/Notepad-Bloc-notes-icon.png" width="16" height="16"> View Notes</a>
      &nbsp; &nbsp;
      <a href = "https://ba.equipmentshare.com/crm/missed_rentals?Company%20Name={{ company_name._value | url_encode }}" target="_blank"><img src="https://icons.iconarchive.com/icons/google/noto-emoji-smileys/128/10052-frowning-face-icon.png" width="16" height="16"> Missed Rental</a>
      &nbsp; &nbsp;
      <a href = "{{ sales_track_logins.fleet_login_link._value }}" target="_blank"><img src="https://icons.iconarchive.com/icons/oxygen-icons.org/oxygen/128/Actions-edit-redo-icon.png" width="16" height="16"> T3 Link</a>
      &nbsp; &nbsp;
      <a href = "https://ba.equipmentshare.com/crm/existing_customer_quote_templates?Company%20ID={{ company_prospect_project_id._value | url_encode }}&Company%20Name={{ company_name._value | url_encode }}" target="_blank"><img src="https://icons.iconarchive.com/icons/papirus-team/papirus-apps/128/github-alonsoenrique-quotes-icon.png" width="16" height="16"> Create Quote</a>
      &nbsp; &nbsp;
      <a href = "https://www.google.com/maps/dir/?api=1&destination={{ address._value | url_encode }}+{{ city._value | url_encode }}+{{ state._value | url_encode }}+{{ zipcode._value | url_encode }}&travelmode=car" target="_blank"><img src="https://icons.iconarchive.com/icons/marcus-roberto/google-play/128/Google-Maps-icon.png" width="16" height="16"> Get Directions</a>
      &nbsp; &nbsp;
      {% elsif is_project._value == 1 %}
      <a href = "https://ba.equipmentshare.com/crm/tasks?Company%20Prospect%20ID={{ company_prospect_project_id._value | url_encode }}&Company%20Name={{ company_name._value | url_encode }}" target="_blank"><img src="https://icons.iconarchive.com/icons/oxygen-icons.org/oxygen/128/Actions-view-calendar-day-icon.png" width="16" height="16"> Create Calendar Event</a>
      &nbsp; &nbsp;
      <a href = "https://ba.equipmentshare.com/crm/lookup_project?Project%20ID={{ company_prospect_project_id._value | url_encode }}&Project%20Name={{ company_name._value | url_encode }}" target="_blank"><img src="https://icons.iconarchive.com/icons/oxygen-icons.org/oxygen/128/Actions-edit-redo-icon.png" width="16" height="16"> Update Project</a>
      &nbsp; &nbsp;
      <a href="{{ folder_url._value }}" target="_blank"><img src="https://icons.iconarchive.com/icons/marcus-roberto/google-play/16/Google-Drive-icon.png" width="16" height="16">Link to Drive Folder</a>
      &nbsp; &nbsp;
      <a href = "https://ba.equipmentshare.com/crm/project_note?Project%20ID={{ company_prospect_project_id._value | url_encode }}&Company%20Name={{ company_name._value | url_encode }}" target="_blank"><img src="https://icons.iconarchive.com/icons/tatice/cristal-intense/16/Notepad-Bloc-notes-icon.png" width="16" height="16"> Create Note</a>
      &nbsp; &nbsp;
     <a href = "https://equipmentshare.looker.com/dashboards/285?Project%20Name={{ company_name._value | url_encode }}" target="_blank"><img src="https://icons.iconarchive.com/icons/tatice/cristal-intense/16/Notepad-Bloc-notes-icon.png" width="16" height="16">View Notes</a>
      &nbsp; &nbsp;
       <a href = "https://ba.equipmentshare.com/crm/lookup_project?Project%20ID={{ company_prospect_project_id._value | url_encode }}&Project%20Name={{ company_name._value | url_encode }}" target="_blank"><img src="https://icons.iconarchive.com/icons/fatcow/farm-fresh/32/arrow-merge-icon.png" width="16" height="16"> Update Project</a>
      &nbsp; &nbsp;
      <a href = "https://ba.equipmentshare.com/crm/reassign_project?Created%20By={{ email._value | url_encode }}&Project%20ID={{ company_prospect_project_id._value | url_encode }}&Project%20Name={{ company_name._value | url_encode }}" target="_blank"><img src="https://icons.iconarchive.com/icons/iconsmind/outline/128/Data-Transfer-icon.png" width="16" height="16"> Reassign Project</a>
      &nbsp; &nbsp;
      <a href = "https://ba.equipmentshare.com/crm/project_quote_templates?Project%20ID={{ company_prospect_project_id._value | url_encode }}&Project%20Name={{ company_name._value | url_encode }}" target="_blank"><img src="https://icons.iconarchive.com/icons/papirus-team/papirus-apps/128/github-alonsoenrique-quotes-icon.png" width="16" height="16"> Create Quote</a>
      &nbsp; &nbsp;
       <a href = "https://www.google.com/maps/dir/?api=1&destination={{ address._value | url_encode }}+{{ city._value | url_encode }}+{{ state._value | url_encode }}+{{ zipcode._value | url_encode }}&travelmode=car" target="_blank"><img src="https://icons.iconarchive.com/icons/marcus-roberto/google-play/128/Google-Maps-icon.png" width="16" height="16"> Get Directions</a>
      &nbsp; &nbsp;
      {% endif %}
      ;;
  }


}
