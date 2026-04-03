view: existing_companies_mapping_query {
  derived_table: {
    sql: select
        ex.company_id  AS company_id,
        ex.company_name  AS company_name,
        ex.folder_url  AS folder_url,
        u.email_address as email_address,
        L.location_id as location_id,
        u.user_id as user_id
      FROM ANALYTICS.PROSPECTS.EXISTING_COMPANIES_MAPPING  AS ex
      LEFT JOIN ES_WAREHOUSE."PUBLIC".users  AS u
      ON (ex.COMPANY_ID) = (u.COMPANY_ID)
      LEFT JOIN ES_WAREHOUSE."PUBLIC".COMPANIES  AS C
      ON ex.company_id = c.company_id
       LEFT JOIN ES_WAREHOUSE."PUBLIC".LOCATIONS  AS L
      ON L.location_id = c.billing_location_id
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}.company_id ;;
  }

  dimension: email_address {
    type: string
    sql: ${TABLE}.email_address ;;
  }

  dimension: location_id {
    type: number
    sql: ${TABLE}.location_id ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}.user_id ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}.company_name ;;
    html:
    <font color="blue "><u><a href = "https://equipmentshare.looker.com/dashboards/28?Company%20Name={{ company_name._filterable_value | url_encode }}" target="_blank">{{ company_name._filterable_value }}</a></font></u>;;
    }


  dimension: folder_url {
    type: string
    sql: ${TABLE}.folder_url ;;
    html:<font color="blue "><u><a href="{{ folder_url._value }}" target="_blank">Link to Drive Folder</a></font></u> ;;
  }

  dimension: submit_note {
    type: string
    html: <font color="blue "><u><a href = "https://docs.google.com/forms/d/e/1FAIpQLSc9BH1zaMNFdfHcBWKVi6I3ib-6QHwcYjffYqd8zlhX1zYgvg/viewform?usp=pp_url&entry.503989311={{ company_id._value }}&entry.1734875336={{ users.passing_user_id_from_logged_in_looker_user._value }}&entry.626077242=Accounts+Receivable" target="_blank">Submit Note</a></font></u> ;;
    sql: ${company_id} ;;
  }

  set: detail {
    fields: [company_id, company_name, folder_url]
  }

  dimension: folder_url_link {
    type: string
    sql: ${TABLE}.folder_url ;;
    html:<font color="blue "><u><a href="{{ folder_url._value }}" target="_blank">Link to Drive Folder</a></font></u> ;;
  }

  dimension: admin_link {
    type: string
    sql: ${TABLE}.company_id ;;
    html:<font color="blue "><u><a href="https://admin.equipmentshare.com/#/home/companies/{{ company_id._value | url_encode }}" target="_blank">Link to Admin</a></font></u> ;;
  }

  dimension: track_link {
    type: string
    html:<font color="blue "><u><a href="{{ sales_track_logins.fleet_login_link._value }}" target="_blank">Link to Track</a></font></u> ;;
    sql: ${company_id}  ;;
  }

  dimension: create_task {
    type: string
    html:
    <font color="blue "><u><a href = "https://staging-ba.equipmentshare.com/crm/tasks?Company%20Prospect%20ID={{ company_id._value | url_encode }}&Company%20Name={{ company_name._value | url_encode }}" target="_blank">Create Calendar Event</a></font></u>;;
    sql: ${TABLE}.company_id  ;;}

  dimension: get_directions {
    type: string
    sql: ${TABLE}.company_id ;;
    html:<font color="blue "><u><a href="https://www.google.com/maps/dir/?api=1&destination={{ locations.street_1._value | url_encode }}+{{ locations.city._value | url_encode }}+{{ states.abbreviation._value | url_encode }}+{{ locations.zip_code._value | url_encode }}&travelmode=car" target="_blank">Get Directions</a></font></u> ;;
  }

  dimension: link_agg {
    label: "Links"
    sql: ${TABLE}.company_id ;;
    html: {% if company_id._value != null %}
          <a href = "https://staging-ba.equipmentshare.com/crm/existing_customer_homepage?Company%20ID={{ company_id._value | url_encode }}&Company%20Name={{ company_name._value  }}&email={{  _user_attributes['email'] }}" target="_blank"><img src="https://icons.iconarchive.com/icons/designbolts/seo/128/Homepage-Optimization-icon.png" width="16" height="16"> Add to Homepage</a>
          {% endif %}
          &nbsp; &nbsp;
           {% if company_id._value != null %}
          <a href = "https://admin.equipmentshare.com/#/home/companies/{{ company_id._value | url_encode }}" target="_blank"><img src="https://icons.iconarchive.com/icons/oxygen-icons.org/oxygen/128/Actions-document-save-all-icon.png" width="16" height="16"> Admin Link</a>
          {% endif %}
          &nbsp; &nbsp;
          {% if company_id._value != null %}
          <a href = "{{ sales_track_logins.login_link._value }}" target="_blank"><img src="https://icons.iconarchive.com/icons/oxygen-icons.org/oxygen/128/Actions-edit-redo-icon.png" width="16" height="16"> Track Link</a>
          {% endif %}
          &nbsp; &nbsp;
          {% if company_id._value != null %}
          <a href = "{{ folder_url._value }}" target="_blank"><img src="https://icons.iconarchive.com/icons/marcus-roberto/google-play/16/Google-Drive-icon.png" width="16" height="16"> Link to Drive</a>
          {% endif %}
          &nbsp; &nbsp;
           {% if company_id._value != null %}
          <a href = "https://docs.google.com/forms/d/e/1FAIpQLSc9BH1zaMNFdfHcBWKVi6I3ib-6QHwcYjffYqd8zlhX1zYgvg/viewform?usp=pp_url&entry.503989311={{ company_id._value }}&entry.1734875336={{ users.passing_user_id_from_logged_in_looker_user._value }}&entry.626077242=Accounts+Receivable" target="_blank"><img src="https://icons.iconarchive.com/icons/tatice/cristal-intense/16/Notepad-Bloc-notes-icon.png" width="16" height="16"> Create Note</a>
          {% endif %}
          &nbsp; &nbsp;
           {% if company_id._value != null %}
          <a href = "https://staging-ba.equipmentshare.com/crm/existing_customer_note?Company%20ID={{ company_id._value | url_encode }}&Company%20Name={{ companies.name._value | url_encode }}" target="_blank"><img src="https://icons.iconarchive.com/icons/tatice/cristal-intense/16/Notepad-Bloc-notes-icon.png" width="16" height="16"> View Notes</a>
          {% endif %}
          &nbsp; &nbsp;
          {% if company_id._value != null %}
          <a href = "https://staging-ba.equipmentshare.com/crm/tasks?Company%20Prospect%20ID={{ company_id._value | url_encode }}&Company%20Name={{ company_name._value | url_encode }}" target="_blank"><img src="https://icons.iconarchive.com/icons/oxygen-icons.org/oxygen/128/Actions-view-calendar-day-icon.png" width="16" height="16"> Create Calendar Event</a>
          {% endif %}
          &nbsp; &nbsp;
           {% if company_id._value != null %}
          <a href = "https://www.google.com/maps/dir/?api=1&destination={{ locations.street_1._value | url_encode }}+{{ locations.city._value | url_encode }}+{{ states.abbreviation._value | url_encode }}+{{ locations.zip_code._value | url_encode }}&travelmode=car" target="_blank"><img src="https://icons.iconarchive.com/icons/marcus-roberto/google-play/128/Google-Maps-icon.png" width="16" height="16"> Get Directions</a>
          {% endif %}
          &nbsp; &nbsp;
           {% if company_id._value != null %}
          <a href = "https://staging-ba.equipmentshare.com/crm/existing_customer_quote_templates?Company%20ID={{ company_id._value | url_encode }}&Company%20Name={{ company_name._value | url_encode }}" target="_blank"><img src="https://icons.iconarchive.com/icons/papirus-team/papirus-apps/128/github-alonsoenrique-quotes-icon.png" width="16" height="16"> Create Quote</a>
          {% endif %}
           &nbsp; &nbsp;
          ;;
  }

}
