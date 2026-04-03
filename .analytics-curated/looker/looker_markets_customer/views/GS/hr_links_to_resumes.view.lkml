view: hr_links_to_resumes {
  sql_table_name: "GS"."HR_LINKS_TO_RESUMES"
    ;;

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

  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
  }

  dimension: link_to_resume {
    type: string
    sql: ${TABLE}."LINK_TO_RESUME" ;;
  }

  dimension: link_to_resume_html {
    type: string
    html: <font color="blue "><u><a href ="{{link_to_resume._value}}"target="_blank">Link to Resume</a></font></u> ;;
    sql: ${link_to_resume} ;;
  }

  dimension: sales_rep_email {
    type: string
    sql: ${TABLE}."SALES_REP_EMAIL" ;;
  }

  dimension: sales_rep_name {
    type: string
    sql: ${TABLE}."SALES_REP_NAME" ;;
  }

  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [sales_rep_name]
  }
}
