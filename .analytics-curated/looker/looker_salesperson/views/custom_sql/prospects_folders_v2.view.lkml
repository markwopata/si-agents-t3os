view: prospects_folders_v2 {
  derived_table: {
    sql: select p.prospect_id as prospect_id, p.company_name as prospect_name,
      p.folder_url as folder_url, p.sales_representative_email_address as sales_representative_email_address , p.timestamp as timestamp
      from analytics.WEBAPPS.CRM__PROSPECTS__MAPPING__V4 as p
      --left join analytics.WEBAPPS.CRM__EXISTING__COMPANIES__MAPPING__V4 as pem
      --on p.prospect_id = pem.prospect_id
      --where pem.prospect_id is null
                               ;;
  }



  dimension: prospect_id {
    type: string
    sql: ${TABLE}.prospect_id ;;
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


  dimension: prospect_name {
    type: string
    sql: ${TABLE}.prospect_name ;;
    link: {
      label: "Prospect Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/133?Prospect%20Name={{ prospect_name._value | url_encode }}"
    }
  }


  dimension: folder_url {
    type: string
    sql: ${TABLE}.folder_url ;;
    html:<font color="blue "><u><a href="{{ folder_url._value }}" target="_blank">Link to Drive Folder</a></font></u> ;;
  }

  dimension: sales_representative_email_address {
    type: string
    sql: ${TABLE}.sales_representative_email_address ;;
  }

  dimension: is_prospect_note {
    type: yesno
    sql: left(${prospect_id},1) = 'P' ;;
  }

  dimension: merge_prospect {
    type: string
    html:
    {% if is_prospect_note._value == 'Yes' %}
    <font color="blue "><u><a href = "https://app.seekwell.io/form/2c42a2e1800149ed9f2811cccf0e4f31?timestamp={{ "now" | date: "%Y-%m-%d %H:%M" }}&prospect_id={{prospect_id._value }}&sales_representative_email_address={{  _user_attributes['email'] }}" target="_blank">Merge Prospect</a></font></u>
    {% else %}
    <font color="blue "><u><a href = "https://www.equipmentshare.com/" target="_blank"></a></font></u>
    {% endif %} ;;
    sql: ${prospect_id};;
  }


  dimension: reassign_prospect {
    type: string
    html:
    {% if is_prospect_note._value == 'Yes' %}
   <font color="blue "><u><a href = "https://app.seekwell.io/form/169d80bf8daf4565818258f9e60ca60b?prospect_id={{prospect_id._value }}&sales_representative_email_address={{  _user_attributes['email'] }}" target="_blank">Update Prospect</a></font></u>
    {% else %}
    <font color="blue "><u><a href = "https://www.equipmentshare.com/" target="_blank"></a></font></u>
    {% endif %} ;;
    sql: ${prospect_id};;
  }

  dimension: create_note {
    type: string
    html:
    {% if is_prospect_note._value == 'Yes' %}
    <font color="blue "><u><a href = "https://app.seekwell.io/form/9b513151952049c3931bca19b8968fdf?timestamp={{ "now" | date: "%Y-%m-%d %H:%M" }}&prospect_id={{prospect_id._value }}&sales_representative_email_address={{  _user_attributes['email'] }}" target="_blank">Create Note</a></font></u>
    {% else %}
    <font color="blue "><u><a href = "https://docs.google.com/forms/d/e/1FAIpQLSc9BH1zaMNFdfHcBWKVi6I3ib-6QHwcYjffYqd8zlhX1zYgvg/viewform?usp=pp_url&entry.503989311={{ prospect_id._value }}&entry.1734875336={{ users.passing_user_id_from_logged_in_looker_user._value }}&entry.626077242=Sales" target="_blank">Create Note</a></font></u>
    {% endif %} ;;
    sql:  ${prospect_id};;
  }

  dimension: company_prospect_lookup {
    type: string
    html:
    <font color="blue "><u><a href = "https://equipmentshare.looker.com/dashboards/132">Prospect and Companies Lookup Dashboard</a></font></u>
    ;;
    sql:  ${prospect_id};;
  }


  measure: count {
    type: count_distinct
    sql: ${prospect_id} ;;
    drill_fields: [prospect_id, prospect_name,timestamp_date,users.Full_Name,folder_url]
  }

}
