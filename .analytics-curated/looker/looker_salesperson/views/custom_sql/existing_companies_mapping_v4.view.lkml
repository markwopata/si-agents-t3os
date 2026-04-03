view: existing_companies_mapping_query_v4 {
  derived_table: {
    sql: with testing as (
      select
        company_id,
        user_id
      from
        analytics.gs.national_accounts
      )
      select
        ex.company_id  AS company_id,
        ex.company_name  AS company_name,
        ex.folder_url  AS folder_url,
        u.email_address as email_address
      FROM analytics.prospects.existing__companies__mapping__v4  AS ex
      LEFT JOIN testing  AS t
      ON (ex.company_id) = (t.company_id)
      LEFT JOIN ES_WAREHOUSE."PUBLIC".users  AS u
      ON (t.user_id) = (u.user_id)
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
    type: number
    sql: ${TABLE}.email_address ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}.company_name ;;
    link: {
      label: "Customer Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/101?Company%20Name={{ company_name._value | url_encode }}"
    }
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
    sql: ${TABLE}.company_id ;;
    html:<font color="blue "><u><a href="{{ folder_url._value }}" target="_blank">Link to Track</a></font></u> ;;
  }

  dimension: create_task {
    type: string
    html:
    <font color="blue "><u><a href = "http://127.0.0.1:5000/prospects/existing_customer_tasks?Company%20ID={{ company_id._value | url_encode }}&Company%20Name={{ company_name._value | url_encode }}" target="_blank">Create Task</a></font></u>;;
    sql: ${TABLE}.company_id  ;;}
}
