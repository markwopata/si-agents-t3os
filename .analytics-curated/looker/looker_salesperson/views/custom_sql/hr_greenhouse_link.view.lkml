view: hr_greenhouse_link {
  derived_table: {
    sql: with gh_email as (
          select last_application_id,
                 CANDIDATE_ID,
                 email_address
          from analytics.greenhouse.candidate_info_view
              qualify row_number() over (partition by email_address order by last_activity desc) = 1
      )
      select cd.employee_id,
             coalesce(cd.greenhouse_application_id, gh.last_application_id) greenhouse_application_id,
             gh.CANDIDATE_ID,
             'https://app.greenhouse.io/people/' || gh.CANDIDATE_ID || '?application_id=' || coalesce(cd.greenhouse_application_id, gh.last_application_id) || '#application' as greenhouse_link
      from analytics.payroll.company_directory cd
      left join gh_email gh on gh.EMAIL_ADDRESS = cd.PERSONAL_EMAIL
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }

  dimension: greenhouse_application_id {
    type: number
    sql: ${TABLE}."GREENHOUSE_APPLICATION_ID" ;;
  }

  dimension: candidate_id {
    type: number
    sql: ${TABLE}."CANDIDATE_ID" ;;
  }

  dimension: greenhouse_link {
    type: string
    sql: ${TABLE}."GREENHOUSE_LINK" ;;
  }

  dimension: link_to_greenhouse_html {
    type: string
    html: <font color="blue "><u><a href ="{{greenhouse_link._value}}"target="_blank">Link to Greenhouse</a></font></u> ;;
    sql: ${greenhouse_link} ;;
  }

  set: detail {
    fields: [employee_id, greenhouse_application_id, candidate_id, greenhouse_link]
  }
}
