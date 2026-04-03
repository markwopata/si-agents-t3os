view: recent_main_menu {

  derived_table: {
    sql:
      SELECT DISTINCT  ID ,COMPANY_PROJECT_NAME, TYPE, MIN(TIMESTAMP) AS TIMESTAMP, LAST_RENTAL_DATE FROM (
      SELECT MIN(EXISTING_CUTOMER_ID) AS KEY, ID, COMPANY_PROJECT_NAME, TYPE, TIMESTAMP, LAST_RENTAL_DATE FROM (
SELECT P.SERIAL_ID AS EXISTING_CUTOMER_ID, P.PROSPECT_ID::VARCHAR AS ID, P.COMPANY_NAME AS COMPANY_PROJECT_NAME,
'Prospect' AS TYPE , P.TIMESTAMP AS TIMESTAMP, NULL AS LAST_RENTAL_DATE
FROM ANALYTICS.WEBAPPS.CRM__PROSPECTS__MAPPING__V4 AS P
WHERE SALES_REPRESENTATIVE_EMAIL_ADDRESS = '{{ _user_attributes['email'] }}'
--AND TIMESTAMP >= DATEADD(day,-7, current_date)
UNION ALL
SELECT C.EXISTING_CUTOMER_ID AS KEY, C.COMPANY_ID::VARCHAR AS ID, C.COMPANY_NAME AS COMPANY_PROJECT_NAME,
'Existing Customer' AS TYPE , C.TIMESTAMP AS TIMESTAMP, MAX(R.START_DATE::DATE) AS LAST_RENTAL_DATE
FROM ANALYTICS.WEBAPPS.CRM__EXISTING__CUSTOMER__HOMEPAGE__V4 AS C
LEFT JOIN ES_WAREHOUSE.PUBLIC.USERS AS U
ON C.COMPANY_ID = U.COMPANY_ID
LEFT JOIN ES_WAREHOUSE.PUBLIC.ORDERS AS O
ON U.USER_ID = O.USER_ID
LEFT JOIN ES_WAREHOUSE.PUBLIC.RENTALS AS R
ON R.ORDER_ID = O.ORDER_ID
WHERE EMAIL = '{{ _user_attributes['email'] }}'
--AND TIMESTAMP >= DATEADD(day,-7, current_date)
GROUP BY  C.EXISTING_CUTOMER_ID , C.COMPANY_ID::VARCHAR , C.COMPANY_NAME ,
TYPE  , C.TIMESTAMP
UNION ALL
SELECT D.DODGE_ID AS KEY, D.DR_NBR::VARCHAR AS ID, D.PROJECT AS COMPANY_PROJECT_NAME,
'Dodge Project' AS TYPE , D.TIMESTAMP AS TIMESTAMP, NULL AS LAST_RENTAL_DATE
FROM ANALYTICS.WEBAPPS.CRM__DODGE__HOMEPAGE__V4 AS D
WHERE EMAIL = '{{ _user_attributes['email'] }}'
--AND TIMESTAMP >= DATEADD(day,-7, current_date)
UNION ALL
SELECT PRJ.PROJECT_ID AS KEY, PRJ.PROJECT_ID::VARCHAR AS ID, PRJ.PROJECT_NAME AS COMPANY_PROJECT_NAME,
'Project' AS TYPE , PRJ.TIMESTAMP AS TIMESTAMP, NULL AS LAST_RENTAL_DATE
FROM ANALYTICS.WEBAPPS.CRM__PROJECT__MAPPING__V4 AS PRJ
WHERE SALES_REPRESENTATIVE_EMAIL_ADDRESS = '{{ _user_attributes['email'] }}'
AND TIMESTAMP >= DATEADD(day,-7, current_date)) AS X
--WHERE  X.TIMESTAMP >= DATEADD(day,-7, current_date)
GROUP BY EXISTING_CUTOMER_ID, ID, COMPANY_PROJECT_NAME, TYPE, TIMESTAMP, LAST_RENTAL_DATE
ORDER BY TIMESTAMP DESC) AS X
GROUP BY  ID ,COMPANY_PROJECT_NAME, TYPE,  LAST_RENTAL_DATE
ORDER BY TIMESTAMP DESC


    ;;
  }



  dimension: id {
    type: string
    sql: ${TABLE}.ID ;;
    html:
    <font color="blue "><u><a href = "https://equipmentshare.looker.com/dashboards/232?Company%20Prospect%20ID={{ id._filterable_value | url_encode }}" target="_blank">{{ id._filterable_value }}</a></font></u>;;
  }


dimension: is_project {
    type: number
    sql:  case when left(${id},3) = 'PRJ' then  1
            when left(${id},1) = 'P' then 2
            when left(${id},1) != 'P' then 3 end ;;}


  dimension: company_project_name {
    type: string
    sql: ${TABLE}.COMPANY_PROJECT_NAME ;;
  }

  dimension: type {
    type: string
    sql: ${TABLE}.TYPE ;;
  }

  dimension: userEmail {
    type:  string
    sql: ${TABLE}.SALES_REPRESENTATIVE_EMAIL_ADDRESS ;;
  }


  dimension: last_rental_date {
    type: date
    sql: ${TABLE}.LAST_RENTAL_DATE ;;
  }

  dimension: timestamp {
    type: date_time
    sql: ${TABLE}.TIMESTAMP ;;
  }

  dimension: link_agg {
    label: "Links"
    sql: ${company_project_name} ;;    html:

          {% if  is_project._value == 2 %}
             <a href = "https://ba.equipmentshare.com/crm/tasks?Company%20Prospect%20ID={{ id._value | url_encode }}&Company%20Name={{ company_project_name._value | url_encode }}" target="_blank"><img src="https://icons.iconarchive.com/icons/oxygen-icons.org/oxygen/128/Actions-view-calendar-day-icon.png" width="16" height="16"> Create Calendar Event</a>
      &nbsp; &nbsp;
      <a href = "https://ba.equipmentshare.com/crm/lookup_prospect?Prospect%20ID={{ id._value | url_encode }}&Company%20Name={{ company_project_name._value | url_encode }}" target="_blank"><img src="https://icons.iconarchive.com/icons/oxygen-icons.org/oxygen/128/Actions-edit-redo-icon.png" width="16" height="16"> Update Prospect</a>
      &nbsp; &nbsp;
        <a href="{{ company_prospects_actions.folder_url._value }}" target="_blank"><img src="https://icons.iconarchive.com/icons/marcus-roberto/google-play/16/Google-Drive-icon.png" width="16" height="16">Link to Drive Folder</a>
      &nbsp; &nbsp;
       <a href = "https://ba.equipmentshare.com/crm/prospect_note?Prospect%20ID={{ id._value | url_encode }}&Company%20Name={{ company_project_name._value | url_encode }}" target="_blank"><img src="https://icons.iconarchive.com/icons/tatice/cristal-intense/16/Notepad-Bloc-notes-icon.png" width="16" height="16"> Create Note</a>
      &nbsp; &nbsp;
     <a href = "https://equipmentshare.looker.com/dashboards/204?Prospect%20ID={{ id._value | url_encode }}&Company%20Name={{ company_project_name._value | url_encode }}" target="_blank"><img src="https://icons.iconarchive.com/icons/tatice/cristal-intense/16/Notepad-Bloc-notes-icon.png" width="16" height="16">View Notes</a>
      &nbsp; &nbsp;
       <a href = "https://ba.equipmentshare.com/crm/merge_prospect?Prospect%20ID={{ id._value | url_encode }}&Company%20Name={{ company_project_name._value | url_encode }}" target="_blank"><img src="https://icons.iconarchive.com/icons/fatcow/farm-fresh/32/arrow-merge-icon.png" width="16" height="16"> Merge Prospect</a>
      &nbsp; &nbsp;
       <a href = "https://ba.equipmentshare.com/crm/add_project?Company%20Prospect%20ID={{ id._value | url_encode }}&Company%20Name={{ company_project_name._value | url_encode }}" target="_blank"><img src="https://icons.iconarchive.com/icons/awicons/vista-artistic/128/add-icon.png" width="16" height="16"> Assign Prospect to Project</a>
      &nbsp; &nbsp;
       <a href = "https://ba.equipmentshare.com/crm/reassign_prospect?Created%20By={{ company_prospects_actions.email._value | url_encode }}&Prospect%20ID={{ id._value | url_encode }}&Company%20Name={{ company_project_name._value | url_encode }}" target="_blank"><img src="https://icons.iconarchive.com/icons/iconsmind/outline/128/Data-Transfer-icon.png" width="16" height="16"> Reassign Prospect</a>
      &nbsp; &nbsp;
      <a href = "https://ba.equipmentshare.com/crm/prospects_quote_templates?Prospect%20ID={{ id._value | url_encode }}&Company%20Name={{ company_project_name._value | url_encode }}" target="_blank"><img src="https://icons.iconarchive.com/icons/papirus-team/papirus-apps/128/github-alonsoenrique-quotes-icon.png" width="16" height="16"> Create Quote</a>
      &nbsp; &nbsp;
       <a href = "https://www.google.com/maps/dir/?api=1&destination={{ company_prospects_actions.address._value | url_encode }}+{{ company_prospects_actions.city._value | url_encode }}+{{ company_prospects_actions.state._value | url_encode }}+{{ company_prospects_actions.zipcode._value | url_encode }}&travelmode=car" target="_blank"><img src="https://icons.iconarchive.com/icons/marcus-roberto/google-play/128/Google-Maps-icon.png" width="16" height="16"> Get Directions</a>
      &nbsp; &nbsp;


      <a href = "https://ba.equipmentshare.com/crm/delete_recent?tableid={{ id._value | url_encode }}&createdby={{ company_prospects_actions.email._value | url_encode }}&type=2" target="_blank"><img src="https://icons.iconarchive.com/icons/awicons/vista-artistic/256/delete-icon.png" width="16" height="16"> Remove</a>


      &nbsp; &nbsp;



          {% elsif is_project._value == 3 %}
            <a href = "https://ba.equipmentshare.com/crm/tasks?Company%20Prospect%20ID={{ id._value | url_encode }}&Company%20Name={{ company_project_name._value | url_encode }}" target="_blank"><img src="https://icons.iconarchive.com/icons/oxygen-icons.org/oxygen/128/Actions-view-calendar-day-icon.png" width="16" height="16"> Create Calendar Event</a>
      &nbsp; &nbsp;
      <a href="{{ company_prospects_actions.folder_url._value }}" target="_blank"><img src="https://icons.iconarchive.com/icons/marcus-roberto/google-play/16/Google-Drive-icon.png" width="16" height="16">Link to Drive Folder</a>
      &nbsp; &nbsp;
       <a href = "https://ba.equipmentshare.com/crm/add_project?Company%20Prospect%20ID={{ id._value | url_encode }}&Company%20Name={{ company_project_name._value | url_encode }}" target="_blank"><img src="https://icons.iconarchive.com/icons/awicons/vista-artistic/128/add-icon.png" width="16" height="16"> Assign Existing Customer to Project</a>
      &nbsp; &nbsp;
      <a href = "https://ba.equipmentshare.com/crm/existing_customer_note?Company%20ID={{ id._value | url_encode }}&Company%20Name={{ company_project_name._value | url_encode }}"  target="_blank"><img src="https://icons.iconarchive.com/icons/tatice/cristal-intense/16/Notepad-Bloc-notes-icon.png" width="16" height="16"> Create Note</a>
      &nbsp; &nbsp;
      <a href = "https://equipmentshare.looker.com/dashboards/235?Company%20ID={{ id._value | url_encode }}&Customer%20Name={{ company_project_name._value | url_encode }}" target="_blank"><img src="https://icons.iconarchive.com/icons/tatice/cristal-intense/16/Notepad-Bloc-notes-icon.png" width="16" height="16"> View Notes</a>
      &nbsp; &nbsp;
      <a href = "{{ sales_track_logins.login_link._value }}" target="_blank"><img src="https://icons.iconarchive.com/icons/oxygen-icons.org/oxygen/128/Actions-edit-redo-icon.png" width="16" height="16"> T3 Link</a>
      &nbsp; &nbsp;
      <a href = "https://ba.equipmentshare.com/crm/missed_rentals?Company%20Name={{ company_project_name._value | url_encode }}" target="_blank"><img src="https://icons.iconarchive.com/icons/google/noto-emoji-smileys/128/10052-frowning-face-icon.png" width="16" height="16"> Missed Rental</a>
      &nbsp; &nbsp;
      <a href = "https://ba.equipmentshare.com/crm/existing_customer_quote_templates?Company%20ID={{ id._value | url_encode }}&Company%20Name={{ company_project_name._value | url_encode }}" target="_blank"><img src="https://icons.iconarchive.com/icons/papirus-team/papirus-apps/128/github-alonsoenrique-quotes-icon.png" width="16" height="16"> Create Quote</a>
      &nbsp; &nbsp;
      <a href = "https://www.google.com/maps/dir/?api=1&destination={{ company_prospects_actions.address._value | url_encode }}+{{ company_prospects_actions.city._value | url_encode }}+{{ company_prospects_actions.state._value | url_encode }}+{{ company_prospects_actions.zipcode._value | url_encode }}&travelmode=car" target="_blank"><img src="https://icons.iconarchive.com/icons/marcus-roberto/google-play/128/Google-Maps-icon.png" width="16" height="16"> Get Directions</a>
      &nbsp; &nbsp;


      <a href = "https://ba.equipmentshare.com/crm/delete_recent?tableid={{ id._value | url_encode }}&createdby=dne&type=3" target="_blank"><img src="https://icons.iconarchive.com/icons/awicons/vista-artistic/256/delete-icon.png" width="16" height="16"> Remove</a>


      &nbsp; &nbsp;



      {% elsif is_project._value == 1 %}
      <a href = "https://ba.equipmentshare.com/crm/tasks?Company%20Prospect%20ID={{ id._value | url_encode }}&Company%20Name={{ company_project_name._value | url_encode }}" target="_blank"><img src="https://icons.iconarchive.com/icons/oxygen-icons.org/oxygen/128/Actions-view-calendar-day-icon.png" width="16" height="16"> Create Calendar Event</a>
      &nbsp; &nbsp;
      <a href = "https://ba.equipmentshare.com/crm/lookup_project?Project%20ID={{ id._value | url_encode }}&Project%20Name={{ company_project_name._value | url_encode }}" target="_blank"><img src="https://icons.iconarchive.com/icons/oxygen-icons.org/oxygen/128/Actions-edit-redo-icon.png" width="16" height="16"> Update Project</a>
      &nbsp; &nbsp;
      <a href="{{ company_prospects_actions.folder_url._value }}" target="_blank"><img src="https://icons.iconarchive.com/icons/marcus-roberto/google-play/16/Google-Drive-icon.png" width="16" height="16">Link to Drive Folder</a>
      &nbsp; &nbsp;
      <a href = "https://ba.equipmentshare.com/crm/project_note?Project%20ID={{ id._value | url_encode }}&Company%20Name={{ company_project_name._value | url_encode }}" target="_blank"><img src="https://icons.iconarchive.com/icons/tatice/cristal-intense/16/Notepad-Bloc-notes-icon.png" width="16" height="16"> Create Note</a>
      &nbsp; &nbsp;
     <a href = "https://equipmentshare.looker.com/dashboards/285?Project%20Name={{ company_project_name._value | url_encode }}" target="_blank"><img src="https://icons.iconarchive.com/icons/tatice/cristal-intense/16/Notepad-Bloc-notes-icon.png" width="16" height="16">View Notes</a>
      &nbsp; &nbsp;
       <a href = "https://ba.equipmentshare.com/crm/lookup_project?Project%20ID={{ id._value | url_encode }}&Project%20Name={{ company_project_name._value | url_encode }}" target="_blank"><img src="https://icons.iconarchive.com/icons/fatcow/farm-fresh/32/arrow-merge-icon.png" width="16" height="16"> Update Project</a>
      &nbsp; &nbsp;
      <a href = "https://ba.equipmentshare.com/crm/reassign_project?Created%20By={{ company_prospects_actions.email._value | url_encode }}&Project%20ID={{ id._value | url_encode }}&Project%20Name={{ company_project_name._value | url_encode }}" target="_blank"><img src="https://icons.iconarchive.com/icons/iconsmind/outline/128/Data-Transfer-icon.png" width="16" height="16"> Reassign Project</a>
      &nbsp; &nbsp;
      <a href = "https://ba.equipmentshare.com/crm/project_quote_templates?Project%20ID={{ id._value | url_encode }}&Project%20Name={{ company_project_name._value | url_encode }}" target="_blank"><img src="https://icons.iconarchive.com/icons/papirus-team/papirus-apps/128/github-alonsoenrique-quotes-icon.png" width="16" height="16"> Create Quote</a>
      &nbsp; &nbsp;
       <a href = "https://www.google.com/maps/dir/?api=1&destination={{ company_prospects_actions.address._value | url_encode }}+{{ company_prospects_actions.city._value | url_encode }}+{{ company_prospects_actions.state._value | url_encode }}+{{ company_prospects_actions.zipcode._value | url_encode }}&travelmode=car" target="_blank"><img src="https://icons.iconarchive.com/icons/marcus-roberto/google-play/128/Google-Maps-icon.png" width="16" height="16"> Get Directions</a>
      &nbsp; &nbsp;



       <a href = "https://ba.equipmentshare.com/crm/delete_recent?tableid={{ id._value | url_encode }}&createdby={{ company_prospects_actions.email._value | url_encode }}&type=1" target="_blank"><img src="https://icons.iconarchive.com/icons/awicons/vista-artistic/256/delete-icon.png" width="16" height="16"> Remove</a>
      &nbsp; &nbsp;

      {% endif %}
      ;;
  }



  }
