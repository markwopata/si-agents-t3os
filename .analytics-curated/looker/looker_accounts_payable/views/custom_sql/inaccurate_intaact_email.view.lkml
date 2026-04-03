#X# Conversion failed: failed to parse YAML.  Check for pipes on newlines


view: inaccurate_intaact_email {
  derived_table: {
    sql: select info.description as name,
    info.contactkey as sage_id,
    cd.employee_id,
    c.email1 as intaact_email,
    cd.work_email as directory_email
      from analytics.intacct.userinfo as info
      JOIN analytics.intacct.contact as c ON info.CONTACTKEY = c.RECORDNO
      join analytics.payroll.company_directory as cd ON c.EMAIL1 = cd.work_email
      where cd.work_email is NULL ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: sage_id {
    type: number
    sql: ${TABLE}."SAGE_ID" ;;
  }

  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }

  dimension: intaact_email {
    type: string
    sql: ${TABLE}."INTAACT_EMAIL" ;;
  }

  dimension: directory_email {
    type: string
    sql: ${TABLE}."DIRECTORY_EMAIL" ;;
  }

  set: detail {
    fields: [
        name,
  sage_id,
  employee_id,
  intaact_email,
  directory_email
    ]
  }
}
